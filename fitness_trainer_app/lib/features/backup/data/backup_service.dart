import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_models.dart';

/// Hand-rolled JSON backup / restore and CSV export.
///
/// No extra packages (per the project constraint): JSON is [dart:convert] and
/// the CSV writer is a few lines below. The whole database is small, so every
/// export reads all rows and every import runs inside a single transaction.
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  static const _appMarker = 'procalendar';
  static const _formatVersion = 1;

  // ---------------------------------------------------------------- export

  Future<String> exportJson() async {
    final payload = <String, dynamic>{
      'app': _appMarker,
      'format': _formatVersion,
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'clients': [for (final c in await db.getAllClients()) _clientMap(c)],
      'tags': [for (final t in await db.getAllTags()) _tagMap(t)],
      'clientTags': [
        for (final ct in await db.getAllClientTags()) _clientTagMap(ct),
      ],
      'templates': [
        for (final t in await db.getAllTemplates()) _templateMap(t),
      ],
      'plans': [for (final p in await db.getAllPlans()) _planMap(p)],
      'attendance': [
        for (final a in await db.getAllAttendance()) _attendanceMap(a),
      ],
      'settings': [
        for (final s in await db.getAllSettings()) _settingMap(s),
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  // ---------------------------------------------------------------- import

  /// Validates a backup without touching the database. Throws [FormatException]
  /// when the content is not a Pro Calendar backup.
  BackupCounts previewCounts(String raw) {
    final payload = _decode(raw.trim());
    _validateHeader(payload);
    return _parse(payload).counts;
  }

  Future<BackupImportResult> importJson(
    String raw, {
    required BackupImportMode mode,
  }) async {
    final payload = _decode(raw.trim());
    _validateHeader(payload);
    final data = _parse(payload);
    final total = data.counts;

    late BackupCounts added;
    await db.transaction(() async {
      if (mode == BackupImportMode.replace) {
        await _wipe();
        await _insertAll(data, InsertMode.insertOrReplace);
        added = total;
      } else {
        added = await _merge(data);
      }
    });

    return BackupImportResult(mode: mode, added: added, total: total);
  }

  /// Adds missing rows only: parents are inserted first, conflicting ids are
  /// skipped, so current data is never overwritten and foreign keys still
  /// resolve (a skipped parent simply already exists).
  Future<BackupCounts> _merge(_ParsedBackup data) async {
    final clientIds = (await db.select(db.clients).get()).map((r) => r.id).toSet();
    final tagIds = (await db.select(db.tags).get()).map((r) => r.id).toSet();
    final templateIds = (await db.select(db.planTemplates).get()).map((r) => r.id).toSet();
    final planIds = (await db.select(db.clientPlans).get()).map((r) => r.id).toSet();
    final attendanceIds = (await db.select(db.attendance).get()).map((r) => r.id).toSet();
    final clientTagKeys = (await db.select(db.clientTags).get())
        .map((r) => '${r.clientId}:${r.tagId}')
        .toSet();
    final settingKeys = (await db.select(db.appSettings).get()).map((r) => r.key).toSet();

    await _insertAll(data, InsertMode.insertOrIgnore);

    int added(List<Map<String, dynamic>> rows, bool Function(Map<String, dynamic>) exists) =>
        rows.where((row) => !exists(row)).length;

    return BackupCounts(
      clients: added(data.clients, (m) => clientIds.contains(_asInt(m['id']))),
      tags: added(data.tags, (m) => tagIds.contains(_asInt(m['id']))),
      templates: added(data.templates, (m) => templateIds.contains(_asInt(m['id']))),
      plans: added(data.plans, (m) => planIds.contains(_asInt(m['id']))),
      attendance: added(data.attendance, (m) => attendanceIds.contains(_asInt(m['id']))),
      clientTags: added(
        data.clientTags,
        (m) => clientTagKeys.contains('${_asInt(m['clientId'])}:${_asInt(m['tagId'])}'),
      ),
      settings: added(data.settings, (m) => settingKeys.contains(m['key'])),
    );
  }

  Future<void> _wipe() async {
    await db.delete(db.attendance).go();
    await db.delete(db.clientTags).go();
    await db.delete(db.clientPlans).go();
    await db.delete(db.clients).go();
    await db.delete(db.planTemplates).go();
    await db.delete(db.tags).go();
    await db.delete(db.appSettings).go();
  }

  Future<void> _insertAll(_ParsedBackup data, InsertMode mode) async {
    await db.batch((batch) {
      batch.insertAll(db.clients, data.clients.map(_clientCompanion), mode: mode);
      batch.insertAll(db.tags, data.tags.map(_tagCompanion), mode: mode);
      batch.insertAll(db.planTemplates, data.templates.map(_templateCompanion), mode: mode);
      batch.insertAll(db.clientTags, data.clientTags.map(_clientTagCompanion), mode: mode);
      batch.insertAll(db.clientPlans, data.plans.map(_planCompanion), mode: mode);
      batch.insertAll(db.attendance, data.attendance.map(_attendanceCompanion), mode: mode);
      batch.insertAll(db.appSettings, data.settings.map(_settingCompanion), mode: mode);
    });
  }

  // ------------------------------------------------------------------- CSV

  /// UTF-8 BOM so Excel renders Persian names correctly.
  Future<String> exportClientsCsv() async {
    final clients = await db.getAllClients();
    return _csv([
      ['id', 'name', 'contact', 'note', 'bonusSessions', 'createdAt'],
      for (final c in clients)
        ['${c.id}', c.name, c.contact ?? '', c.note, '${c.bonusSessions}', c.createdAt],
    ]);
  }

  Future<String> exportPlansCsv() async {
    final clientNames = {
      for (final c in await db.getAllClients()) c.id: c.name,
    };
    final templateNames = {
      for (final t in await db.getAllTemplates()) t.id: t.name,
    };
    final plans = await db.getAllPlans();
    return _csv([
      ['id', 'clientId', 'clientName', 'templateId', 'templateName', 'startDate', 'sessions', 'days', 'remaining', 'status', 'createdAt'],
      for (final p in plans)
        [
          '${p.id}',
          '${p.clientId}',
          clientNames[p.clientId] ?? '',
          '${p.templateId}',
          templateNames[p.templateId] ?? '',
          p.startDate ?? '',
          '${p.sessions}',
          '${p.days}',
          '${p.remaining}',
          p.status,
          p.createdAt,
        ],
    ]);
  }

  Future<String> exportAttendanceCsv() async {
    final clientNames = {
      for (final c in await db.getAllClients()) c.id: c.name,
    };
    final attendance = await db.getAllAttendance();
    return _csv([
      ['id', 'clientId', 'clientName', 'planId', 'date', 'status', 'createdAt'],
      for (final a in attendance)
        [
          '${a.id}',
          '${a.clientId}',
          clientNames[a.clientId] ?? '',
          a.planId == null ? '' : '${a.planId}',
          a.date,
          a.status,
          a.createdAt,
        ],
    ]);
  }

  static String _csv(List<List<String>> rows) {
    final buffer = StringBuffer('\uFEFF');
    for (final row in rows) {
      buffer.write(row.map(_csvField).join(','));
      buffer.write('\r\n');
    }
    return buffer.toString();
  }

  static String _csvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// `20260918-1530`, used to build unique export file names.
  static String timestampSuffix([DateTime? now]) {
    final d = now ?? DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}';
  }

  // --------------------------------------------------------------- parsing

  static Map<String, dynamic> _decode(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('invalid JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('backup root is not an object');
    }
    return decoded;
  }

  void _validateHeader(Map<String, dynamic> payload) {
    final marker = payload['app'];
    if (marker != null && marker != _appMarker) {
      throw const FormatException('not a Pro Calendar backup');
    }
    final version = payload['schemaVersion'];
    if (version is! int) {
      throw const FormatException('missing schemaVersion');
    }
    if (version > db.schemaVersion) {
      throw FormatException(
        'backup schema v$version is newer than supported v${db.schemaVersion}',
      );
    }
  }

  static _ParsedBackup _parse(Map<String, dynamic> payload) => _ParsedBackup(
        clients: _rows(payload, 'clients'),
        tags: _rows(payload, 'tags'),
        clientTags: _rows(payload, 'clientTags'),
        templates: _rows(payload, 'templates'),
        plans: _rows(payload, 'plans'),
        attendance: _rows(payload, 'attendance'),
        settings: _rows(payload, 'settings'),
      );

  static List<Map<String, dynamic>> _rows(
    Map<String, dynamic> payload,
    String key,
  ) {
    final value = payload[key];
    if (value == null) return const [];
    if (value is! List) {
      throw FormatException('"$key" is not a list');
    }
    return value.map((row) {
      if (row is! Map<String, dynamic>) {
        throw FormatException('"$key" contains a non-object row');
      }
      return row;
    }).toList();
  }

  // ------------------------------------------------------ value converters

  static int? _asInt(dynamic value) => value is num ? value.toInt() : null;

  static Value<int> _idValue(dynamic value) =>
      value is num ? Value(value.toInt()) : const Value.absent();

  static Value<int> _intValue(dynamic value, [int fallback = 0]) =>
      Value(value is num ? value.toInt() : fallback);

  static Value<int?> _nullableIntValue(dynamic value) =>
      value is num ? Value(value.toInt()) : const Value.absent();

  static Value<String> _stringValue(dynamic value, [String fallback = '']) =>
      Value(value is String ? value : fallback);

  static Value<String?> _nullableStringValue(dynamic value) =>
      value is String ? Value(value) : const Value.absent();

  // ------------------------------------------------------- row <-> JSON

  static Map<String, dynamic> _clientMap(Client c) => {
        'id': c.id,
        'name': c.name,
        'contact': c.contact,
        'note': c.note,
        'bonusSessions': c.bonusSessions,
        'createdAt': c.createdAt,
      };

  static Map<String, dynamic> _tagMap(Tag t) => {
        'id': t.id,
        'name': t.name,
        'emoji': t.emoji,
        'color': t.color,
      };

  static Map<String, dynamic> _clientTagMap(ClientTag ct) => {
        'clientId': ct.clientId,
        'tagId': ct.tagId,
      };

  static Map<String, dynamic> _templateMap(PlanTemplate t) => {
        'id': t.id,
        'name': t.name,
        'sessions': t.sessions,
        'days': t.days,
      };

  static Map<String, dynamic> _planMap(ClientPlan p) => {
        'id': p.id,
        'clientId': p.clientId,
        'templateId': p.templateId,
        'startDate': p.startDate,
        'sessions': p.sessions,
        'days': p.days,
        'remaining': p.remaining,
        'status': p.status,
        'queueOrder': p.queueOrder,
        'createdAt': p.createdAt,
      };

  static Map<String, dynamic> _attendanceMap(AttendanceData a) => {
        'id': a.id,
        'clientId': a.clientId,
        'planId': a.planId,
        'date': a.date,
        'status': a.status,
        'createdAt': a.createdAt,
      };

  static Map<String, dynamic> _settingMap(AppSetting s) => {
        'key': s.key,
        'value': s.value,
      };

  static ClientsCompanion _clientCompanion(Map<String, dynamic> m) =>
      ClientsCompanion(
        id: _idValue(m['id']),
        name: _stringValue(m['name']),
        contact: _nullableStringValue(m['contact']),
        note: _stringValue(m['note']),
        bonusSessions: _intValue(m['bonusSessions']),
        createdAt: _stringValue(m['createdAt']),
      );

  static TagsCompanion _tagCompanion(Map<String, dynamic> m) => TagsCompanion(
        id: _idValue(m['id']),
        name: _stringValue(m['name']),
        emoji: _stringValue(m['emoji']),
        color: _intValue(m['color'], 0xFF88A36B),
      );

  static ClientTagsCompanion _clientTagCompanion(Map<String, dynamic> m) =>
      ClientTagsCompanion(
        clientId: _intValue(m['clientId']),
        tagId: _intValue(m['tagId']),
      );

  static PlanTemplatesCompanion _templateCompanion(Map<String, dynamic> m) =>
      PlanTemplatesCompanion(
        id: _idValue(m['id']),
        name: _stringValue(m['name']),
        sessions: _intValue(m['sessions']),
        days: _intValue(m['days']),
      );

  static ClientPlansCompanion _planCompanion(Map<String, dynamic> m) =>
      ClientPlansCompanion(
        id: _idValue(m['id']),
        clientId: _intValue(m['clientId']),
        templateId: _intValue(m['templateId']),
        startDate: _nullableStringValue(m['startDate']),
        sessions: _intValue(m['sessions']),
        days: _intValue(m['days']),
        remaining: _intValue(m['remaining']),
        status: _stringValue(m['status'], 'active'),
        queueOrder: _nullableIntValue(m['queueOrder']),
        createdAt: _stringValue(m['createdAt']),
      );

  static AttendanceCompanion _attendanceCompanion(Map<String, dynamic> m) =>
      AttendanceCompanion(
        id: _idValue(m['id']),
        clientId: _intValue(m['clientId']),
        planId: _nullableIntValue(m['planId']),
        date: _stringValue(m['date']),
        status: _stringValue(m['status']),
        createdAt: _stringValue(m['createdAt']),
      );

  static AppSettingsCompanion _settingCompanion(Map<String, dynamic> m) =>
      AppSettingsCompanion(
        key: _stringValue(m['key']),
        value: _stringValue(m['value']),
      );
}

class _ParsedBackup {
  _ParsedBackup({
    required this.clients,
    required this.tags,
    required this.clientTags,
    required this.templates,
    required this.plans,
    required this.attendance,
    required this.settings,
  });

  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> clientTags;
  final List<Map<String, dynamic>> templates;
  final List<Map<String, dynamic>> plans;
  final List<Map<String, dynamic>> attendance;
  final List<Map<String, dynamic>> settings;

  BackupCounts get counts => BackupCounts(
        clients: clients.length,
        tags: tags.length,
        clientTags: clientTags.length,
        templates: templates.length,
        plans: plans.length,
        attendance: attendance.length,
        settings: settings.length,
      );
}
