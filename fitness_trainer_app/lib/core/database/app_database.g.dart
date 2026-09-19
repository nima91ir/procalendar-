// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bonusSessionsMeta = const VerificationMeta(
    'bonusSessions',
  );
  @override
  late final GeneratedColumn<int> bonusSessions = GeneratedColumn<int>(
    'bonus_sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contact,
    note,
    bonusSessions,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('bonus_sessions')) {
      context.handle(
        _bonusSessionsMeta,
        bonusSessions.isAcceptableOrUnknown(
          data['bonus_sessions']!,
          _bonusSessionsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      bonusSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_sessions'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final int id;
  final String name;
  final String? contact;
  final String note;
  final int bonusSessions;
  final String createdAt;
  const Client({
    required this.id,
    required this.name,
    this.contact,
    required this.note,
    required this.bonusSessions,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    map['note'] = Variable<String>(note);
    map['bonus_sessions'] = Variable<int>(bonusSessions);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      note: Value(note),
      bonusSessions: Value(bonusSessions),
      createdAt: Value(createdAt),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
      note: serializer.fromJson<String>(json['note']),
      bonusSessions: serializer.fromJson<int>(json['bonusSessions']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String?>(contact),
      'note': serializer.toJson<String>(note),
      'bonusSessions': serializer.toJson<int>(bonusSessions),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Client copyWith({
    int? id,
    String? name,
    Value<String?> contact = const Value.absent(),
    String? note,
    int? bonusSessions,
    String? createdAt,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    contact: contact.present ? contact.value : this.contact,
    note: note ?? this.note,
    bonusSessions: bonusSessions ?? this.bonusSessions,
    createdAt: createdAt ?? this.createdAt,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      note: data.note.present ? data.note.value : this.note,
      bonusSessions: data.bonusSessions.present
          ? data.bonusSessions.value
          : this.bonusSessions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('note: $note, ')
          ..write('bonusSessions: $bonusSessions, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, contact, note, bonusSessions, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.note == this.note &&
          other.bonusSessions == this.bonusSessions &&
          other.createdAt == this.createdAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contact;
  final Value<String> note;
  final Value<int> bonusSessions;
  final Value<String> createdAt;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.note = const Value.absent(),
    this.bonusSessions = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contact = const Value.absent(),
    this.note = const Value.absent(),
    this.bonusSessions = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Client> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<String>? note,
    Expression<int>? bonusSessions,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (note != null) 'note': note,
      if (bonusSessions != null) 'bonus_sessions': bonusSessions,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contact,
    Value<String>? note,
    Value<int>? bonusSessions,
    Value<String>? createdAt,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      note: note ?? this.note,
      bonusSessions: bonusSessions ?? this.bonusSessions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (bonusSessions.present) {
      map['bonus_sessions'] = Variable<int>(bonusSessions.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('note: $note, ')
          ..write('bonusSessions: $bonusSessions, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF88A36B),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final String emoji;
  final int color;
  const Tag({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
    };
  }

  Tag copyWith({int? id, String? name, String? emoji, int? color}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $ClientTagsTable extends ClientTags
    with TableInfo<$ClientTagsTable, ClientTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [clientId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId, tagId};
  @override
  ClientTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientTag(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ClientTagsTable createAlias(String alias) {
    return $ClientTagsTable(attachedDatabase, alias);
  }
}

class ClientTag extends DataClass implements Insertable<ClientTag> {
  final int clientId;
  final int tagId;
  const ClientTag({required this.clientId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<int>(clientId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  ClientTagsCompanion toCompanion(bool nullToAbsent) {
    return ClientTagsCompanion(clientId: Value(clientId), tagId: Value(tagId));
  }

  factory ClientTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientTag(
      clientId: serializer.fromJson<int>(json['clientId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<int>(clientId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  ClientTag copyWith({int? clientId, int? tagId}) => ClientTag(
    clientId: clientId ?? this.clientId,
    tagId: tagId ?? this.tagId,
  );
  ClientTag copyWithCompanion(ClientTagsCompanion data) {
    return ClientTag(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientTag(')
          ..write('clientId: $clientId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientTag &&
          other.clientId == this.clientId &&
          other.tagId == this.tagId);
}

class ClientTagsCompanion extends UpdateCompanion<ClientTag> {
  final Value<int> clientId;
  final Value<int> tagId;
  final Value<int> rowid;
  const ClientTagsCompanion({
    this.clientId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientTagsCompanion.insert({
    required int clientId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       tagId = Value(tagId);
  static Insertable<ClientTag> custom({
    Expression<int>? clientId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientTagsCompanion copyWith({
    Value<int>? clientId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return ClientTagsCompanion(
      clientId: clientId ?? this.clientId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientTagsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanTemplatesTable extends PlanTemplates
    with TableInfo<$PlanTemplatesTable, PlanTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionsMeta = const VerificationMeta(
    'sessions',
  );
  @override
  late final GeneratedColumn<int> sessions = GeneratedColumn<int>(
    'sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sessions, days];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sessions')) {
      context.handle(
        _sessionsMeta,
        sessions.isAcceptableOrUnknown(data['sessions']!, _sessionsMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionsMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
    );
  }

  @override
  $PlanTemplatesTable createAlias(String alias) {
    return $PlanTemplatesTable(attachedDatabase, alias);
  }
}

class PlanTemplate extends DataClass implements Insertable<PlanTemplate> {
  final int id;
  final String name;
  final int sessions;
  final int days;
  const PlanTemplate({
    required this.id,
    required this.name,
    required this.sessions,
    required this.days,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sessions'] = Variable<int>(sessions);
    map['days'] = Variable<int>(days);
    return map;
  }

  PlanTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PlanTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      sessions: Value(sessions),
      days: Value(days),
    );
  }

  factory PlanTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTemplate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sessions: serializer.fromJson<int>(json['sessions']),
      days: serializer.fromJson<int>(json['days']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sessions': serializer.toJson<int>(sessions),
      'days': serializer.toJson<int>(days),
    };
  }

  PlanTemplate copyWith({int? id, String? name, int? sessions, int? days}) =>
      PlanTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        sessions: sessions ?? this.sessions,
        days: days ?? this.days,
      );
  PlanTemplate copyWithCompanion(PlanTemplatesCompanion data) {
    return PlanTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sessions: data.sessions.present ? data.sessions.value : this.sessions,
      days: data.days.present ? data.days.value : this.days,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sessions: $sessions, ')
          ..write('days: $days')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sessions, days);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.sessions == this.sessions &&
          other.days == this.days);
}

class PlanTemplatesCompanion extends UpdateCompanion<PlanTemplate> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sessions;
  final Value<int> days;
  const PlanTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sessions = const Value.absent(),
    this.days = const Value.absent(),
  });
  PlanTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int sessions,
    required int days,
  }) : name = Value(name),
       sessions = Value(sessions),
       days = Value(days);
  static Insertable<PlanTemplate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sessions,
    Expression<int>? days,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sessions != null) 'sessions': sessions,
      if (days != null) 'days': days,
    });
  }

  PlanTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sessions,
    Value<int>? days,
  }) {
    return PlanTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sessions: sessions ?? this.sessions,
      days: days ?? this.days,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sessions.present) {
      map['sessions'] = Variable<int>(sessions.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sessions: $sessions, ')
          ..write('days: $days')
          ..write(')'))
        .toString();
  }
}

class $ClientPlansTable extends ClientPlans
    with TableInfo<$ClientPlansTable, ClientPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_templates (id)',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionsMeta = const VerificationMeta(
    'sessions',
  );
  @override
  late final GeneratedColumn<int> sessions = GeneratedColumn<int>(
    'sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sharePercentMeta = const VerificationMeta(
    'sharePercent',
  );
  @override
  late final GeneratedColumn<int> sharePercent = GeneratedColumn<int>(
    'share_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<int> remaining = GeneratedColumn<int>(
    'remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _queueOrderMeta = const VerificationMeta(
    'queueOrder',
  );
  @override
  late final GeneratedColumn<int> queueOrder = GeneratedColumn<int>(
    'queue_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    templateId,
    startDate,
    sessions,
    days,
    price,
    sharePercent,
    remaining,
    status,
    queueOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('sessions')) {
      context.handle(
        _sessionsMeta,
        sessions.isAcceptableOrUnknown(data['sessions']!, _sessionsMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionsMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('share_percent')) {
      context.handle(
        _sharePercentMeta,
        sharePercent.isAcceptableOrUnknown(
          data['share_percent']!,
          _sharePercentMeta,
        ),
      );
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    } else if (isInserting) {
      context.missing(_remainingMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('queue_order')) {
      context.handle(
        _queueOrderMeta,
        queueOrder.isAcceptableOrUnknown(data['queue_order']!, _queueOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      ),
      sessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      sharePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_percent'],
      )!,
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      queueOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_order'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClientPlansTable createAlias(String alias) {
    return $ClientPlansTable(attachedDatabase, alias);
  }
}

class ClientPlan extends DataClass implements Insertable<ClientPlan> {
  final int id;
  final int clientId;
  final int templateId;
  final String? startDate;
  final int sessions;
  final int days;
  final int price;
  final int sharePercent;
  final int remaining;
  final String status;
  final int? queueOrder;
  final String createdAt;
  const ClientPlan({
    required this.id,
    required this.clientId,
    required this.templateId,
    this.startDate,
    required this.sessions,
    required this.days,
    required this.price,
    required this.sharePercent,
    required this.remaining,
    required this.status,
    this.queueOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<int>(clientId);
    map['template_id'] = Variable<int>(templateId);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    map['sessions'] = Variable<int>(sessions);
    map['days'] = Variable<int>(days);
    map['price'] = Variable<int>(price);
    map['share_percent'] = Variable<int>(sharePercent);
    map['remaining'] = Variable<int>(remaining);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || queueOrder != null) {
      map['queue_order'] = Variable<int>(queueOrder);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ClientPlansCompanion toCompanion(bool nullToAbsent) {
    return ClientPlansCompanion(
      id: Value(id),
      clientId: Value(clientId),
      templateId: Value(templateId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      sessions: Value(sessions),
      days: Value(days),
      price: Value(price),
      sharePercent: Value(sharePercent),
      remaining: Value(remaining),
      status: Value(status),
      queueOrder: queueOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(queueOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ClientPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientPlan(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<int>(json['clientId']),
      templateId: serializer.fromJson<int>(json['templateId']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      sessions: serializer.fromJson<int>(json['sessions']),
      days: serializer.fromJson<int>(json['days']),
      price: serializer.fromJson<int>(json['price']),
      sharePercent: serializer.fromJson<int>(json['sharePercent']),
      remaining: serializer.fromJson<int>(json['remaining']),
      status: serializer.fromJson<String>(json['status']),
      queueOrder: serializer.fromJson<int?>(json['queueOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<int>(clientId),
      'templateId': serializer.toJson<int>(templateId),
      'startDate': serializer.toJson<String?>(startDate),
      'sessions': serializer.toJson<int>(sessions),
      'days': serializer.toJson<int>(days),
      'price': serializer.toJson<int>(price),
      'sharePercent': serializer.toJson<int>(sharePercent),
      'remaining': serializer.toJson<int>(remaining),
      'status': serializer.toJson<String>(status),
      'queueOrder': serializer.toJson<int?>(queueOrder),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ClientPlan copyWith({
    int? id,
    int? clientId,
    int? templateId,
    Value<String?> startDate = const Value.absent(),
    int? sessions,
    int? days,
    int? price,
    int? sharePercent,
    int? remaining,
    String? status,
    Value<int?> queueOrder = const Value.absent(),
    String? createdAt,
  }) => ClientPlan(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    templateId: templateId ?? this.templateId,
    startDate: startDate.present ? startDate.value : this.startDate,
    sessions: sessions ?? this.sessions,
    days: days ?? this.days,
    price: price ?? this.price,
    sharePercent: sharePercent ?? this.sharePercent,
    remaining: remaining ?? this.remaining,
    status: status ?? this.status,
    queueOrder: queueOrder.present ? queueOrder.value : this.queueOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  ClientPlan copyWithCompanion(ClientPlansCompanion data) {
    return ClientPlan(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      sessions: data.sessions.present ? data.sessions.value : this.sessions,
      days: data.days.present ? data.days.value : this.days,
      price: data.price.present ? data.price.value : this.price,
      sharePercent: data.sharePercent.present
          ? data.sharePercent.value
          : this.sharePercent,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      status: data.status.present ? data.status.value : this.status,
      queueOrder: data.queueOrder.present
          ? data.queueOrder.value
          : this.queueOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientPlan(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('templateId: $templateId, ')
          ..write('startDate: $startDate, ')
          ..write('sessions: $sessions, ')
          ..write('days: $days, ')
          ..write('price: $price, ')
          ..write('sharePercent: $sharePercent, ')
          ..write('remaining: $remaining, ')
          ..write('status: $status, ')
          ..write('queueOrder: $queueOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    templateId,
    startDate,
    sessions,
    days,
    price,
    sharePercent,
    remaining,
    status,
    queueOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientPlan &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.templateId == this.templateId &&
          other.startDate == this.startDate &&
          other.sessions == this.sessions &&
          other.days == this.days &&
          other.price == this.price &&
          other.sharePercent == this.sharePercent &&
          other.remaining == this.remaining &&
          other.status == this.status &&
          other.queueOrder == this.queueOrder &&
          other.createdAt == this.createdAt);
}

class ClientPlansCompanion extends UpdateCompanion<ClientPlan> {
  final Value<int> id;
  final Value<int> clientId;
  final Value<int> templateId;
  final Value<String?> startDate;
  final Value<int> sessions;
  final Value<int> days;
  final Value<int> price;
  final Value<int> sharePercent;
  final Value<int> remaining;
  final Value<String> status;
  final Value<int?> queueOrder;
  final Value<String> createdAt;
  const ClientPlansCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.sessions = const Value.absent(),
    this.days = const Value.absent(),
    this.price = const Value.absent(),
    this.sharePercent = const Value.absent(),
    this.remaining = const Value.absent(),
    this.status = const Value.absent(),
    this.queueOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientPlansCompanion.insert({
    this.id = const Value.absent(),
    required int clientId,
    required int templateId,
    this.startDate = const Value.absent(),
    required int sessions,
    required int days,
    this.price = const Value.absent(),
    this.sharePercent = const Value.absent(),
    required int remaining,
    this.status = const Value.absent(),
    this.queueOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : clientId = Value(clientId),
       templateId = Value(templateId),
       sessions = Value(sessions),
       days = Value(days),
       remaining = Value(remaining);
  static Insertable<ClientPlan> custom({
    Expression<int>? id,
    Expression<int>? clientId,
    Expression<int>? templateId,
    Expression<String>? startDate,
    Expression<int>? sessions,
    Expression<int>? days,
    Expression<int>? price,
    Expression<int>? sharePercent,
    Expression<int>? remaining,
    Expression<String>? status,
    Expression<int>? queueOrder,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (templateId != null) 'template_id': templateId,
      if (startDate != null) 'start_date': startDate,
      if (sessions != null) 'sessions': sessions,
      if (days != null) 'days': days,
      if (price != null) 'price': price,
      if (sharePercent != null) 'share_percent': sharePercent,
      if (remaining != null) 'remaining': remaining,
      if (status != null) 'status': status,
      if (queueOrder != null) 'queue_order': queueOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? clientId,
    Value<int>? templateId,
    Value<String?>? startDate,
    Value<int>? sessions,
    Value<int>? days,
    Value<int>? price,
    Value<int>? sharePercent,
    Value<int>? remaining,
    Value<String>? status,
    Value<int?>? queueOrder,
    Value<String>? createdAt,
  }) {
    return ClientPlansCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      templateId: templateId ?? this.templateId,
      startDate: startDate ?? this.startDate,
      sessions: sessions ?? this.sessions,
      days: days ?? this.days,
      price: price ?? this.price,
      sharePercent: sharePercent ?? this.sharePercent,
      remaining: remaining ?? this.remaining,
      status: status ?? this.status,
      queueOrder: queueOrder ?? this.queueOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (sessions.present) {
      map['sessions'] = Variable<int>(sessions.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (sharePercent.present) {
      map['share_percent'] = Variable<int>(sharePercent.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<int>(remaining.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (queueOrder.present) {
      map['queue_order'] = Variable<int>(queueOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientPlansCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('templateId: $templateId, ')
          ..write('startDate: $startDate, ')
          ..write('sessions: $sessions, ')
          ..write('days: $days, ')
          ..write('price: $price, ')
          ..write('sharePercent: $sharePercent, ')
          ..write('remaining: $remaining, ')
          ..write('status: $status, ')
          ..write('queueOrder: $queueOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    planId,
    date,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final int id;
  final int clientId;
  final int? planId;
  final String date;
  final String status;
  final String createdAt;
  const AttendanceData({
    required this.id,
    required this.clientId,
    this.planId,
    required this.date,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<int>(clientId);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      clientId: Value(clientId),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      date: Value(date),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory AttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<int>(json['clientId']),
      planId: serializer.fromJson<int?>(json['planId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<int>(clientId),
      'planId': serializer.toJson<int?>(planId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  AttendanceData copyWith({
    int? id,
    int? clientId,
    Value<int?> planId = const Value.absent(),
    String? date,
    String? status,
    String? createdAt,
  }) => AttendanceData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    planId: planId.present ? planId.value : this.planId,
    date: date ?? this.date,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      planId: data.planId.present ? data.planId.value : this.planId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clientId, planId, date, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.planId == this.planId &&
          other.date == this.date &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<int> id;
  final Value<int> clientId;
  final Value<int?> planId;
  final Value<String> date;
  final Value<String> status;
  final Value<String> createdAt;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.planId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int clientId,
    this.planId = const Value.absent(),
    required String date,
    required String status,
    this.createdAt = const Value.absent(),
  }) : clientId = Value(clientId),
       date = Value(date),
       status = Value(status);
  static Insertable<AttendanceData> custom({
    Expression<int>? id,
    Expression<int>? clientId,
    Expression<int>? planId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (planId != null) 'plan_id': planId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AttendanceCompanion copyWith({
    Value<int>? id,
    Value<int>? clientId,
    Value<int?>? planId,
    Value<String>? date,
    Value<String>? status,
    Value<String>? createdAt,
  }) {
    return AttendanceCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES client_plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    planId,
    type,
    category,
    amount,
    date,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      ),
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int? clientId;
  final int? planId;
  final String type;
  final String category;
  final int amount;
  final String date;
  final String note;
  final String createdAt;
  const Transaction({
    required this.id,
    this.clientId,
    this.planId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<int>(clientId);
    }
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    map['date'] = Variable<String>(date);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      type: Value(type),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<int?>(json['clientId']),
      planId: serializer.fromJson<int?>(json['planId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      date: serializer.fromJson<String>(json['date']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<int?>(clientId),
      'planId': serializer.toJson<int?>(planId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'date': serializer.toJson<String>(date),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Transaction copyWith({
    int? id,
    Value<int?> clientId = const Value.absent(),
    Value<int?> planId = const Value.absent(),
    String? type,
    String? category,
    int? amount,
    String? date,
    String? note,
    String? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    clientId: clientId.present ? clientId.value : this.clientId,
    planId: planId.present ? planId.value : this.planId,
    type: type ?? this.type,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      planId: data.planId.present ? data.planId.value : this.planId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('planId: $planId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    planId,
    type,
    category,
    amount,
    date,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.planId == this.planId &&
          other.type == this.type &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int?> clientId;
  final Value<int?> planId;
  final Value<String> type;
  final Value<String> category;
  final Value<int> amount;
  final Value<String> date;
  final Value<String> note;
  final Value<String> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.planId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.planId = const Value.absent(),
    required String type,
    required String category,
    required int amount,
    required String date,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       category = Value(category),
       amount = Value(amount),
       date = Value(date);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? clientId,
    Expression<int>? planId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<String>? date,
    Expression<String>? note,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (planId != null) 'plan_id': planId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? clientId,
    Value<int?>? planId,
    Value<String>? type,
    Value<String>? category,
    Value<int>? amount,
    Value<String>? date,
    Value<String>? note,
    Value<String>? createdAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      planId: planId ?? this.planId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('planId: $planId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ClientTagsTable clientTags = $ClientTagsTable(this);
  late final $PlanTemplatesTable planTemplates = $PlanTemplatesTable(this);
  late final $ClientPlansTable clientPlans = $ClientPlansTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    tags,
    clientTags,
    planTemplates,
    clientPlans,
    attendance,
    appSettings,
    transactions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('client_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('client_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('client_plans', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'client_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> contact,
  Value<String> note,
  Value<int> bonusSessions,
  Value<String> createdAt,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> contact,
  Value<String> note,
  Value<int> bonusSessions,
  Value<String> createdAt,
});

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClientTagsTable, List<ClientTag>>
  _clientTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clientTags,
    aliasName: 'clients__id__client_tags__client_id',
  );

  $$ClientTagsTableProcessedTableManager get clientTagsRefs {
    final manager = $$ClientTagsTableTableManager(
      $_db,
      $_db.clientTags,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClientPlansTable, List<ClientPlan>>
  _clientPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clientPlans,
    aliasName: 'clients__id__client_plans__client_id',
  );

  $$ClientPlansTableProcessedTableManager get clientPlansRefs {
    final manager = $$ClientPlansTableTableManager(
      $_db,
      $_db.clientPlans,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceTable, List<AttendanceData>>
  _attendanceRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendance,
    aliasName: 'clients__id__attendance__client_id',
  );

  $$AttendanceTableProcessedTableManager get attendanceRefs {
    final manager = $$AttendanceTableTableManager(
      $_db,
      $_db.attendance,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'clients__id__transactions__client_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusSessions => $composableBuilder(
    column: $table.bonusSessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clientTagsRefs(
    Expression<bool> Function($$ClientTagsTableFilterComposer f) f,
  ) {
    final $$ClientTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableFilterComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clientPlansRefs(
    Expression<bool> Function($$ClientPlansTableFilterComposer f) f,
  ) {
    final $$ClientPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableFilterComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceRefs(
    Expression<bool> Function($$AttendanceTableFilterComposer f) f,
  ) {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceTableFilterComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusSessions => $composableBuilder(
    column: $table.bonusSessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get bonusSessions => $composableBuilder(
    column: $table.bonusSessions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> clientTagsRefs<T extends Object>(
    Expression<T> Function($$ClientTagsTableAnnotationComposer a) f,
  ) {
    final $$ClientTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clientPlansRefs<T extends Object>(
    Expression<T> Function($$ClientPlansTableAnnotationComposer a) f,
  ) {
    final $$ClientPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceRefs<T extends Object>(
    Expression<T> Function($$AttendanceTableAnnotationComposer a) f,
  ) {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceTableAnnotationComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({
            bool clientTagsRefs,
            bool clientPlansRefs,
            bool attendanceRefs,
            bool transactionsRefs,
          })
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contact = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> bonusSessions = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                contact: contact,
                note: note,
                bonusSessions: bonusSessions,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contact = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> bonusSessions = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                contact: contact,
                note: note,
                bonusSessions: bonusSessions,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientsTable, Client>(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientTagsRefs = false,
                clientPlansRefs = false,
                attendanceRefs = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clientTagsRefs) db.clientTags,
                    if (clientPlansRefs) db.clientPlans,
                    if (attendanceRefs) db.attendance,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clientTagsRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          ClientTag
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._clientTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).clientTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (clientPlansRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          ClientPlan
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._clientPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).clientPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          AttendanceData
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._attendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({
        bool clientTagsRefs,
        bool clientPlansRefs,
        bool attendanceRefs,
        bool transactionsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> emoji,
  Value<int> color,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> emoji,
  Value<int> color,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClientTagsTable, List<ClientTag>>
  _clientTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clientTags,
    aliasName: 'tags__id__client_tags__tag_id',
  );

  $$ClientTagsTableProcessedTableManager get clientTagsRefs {
    final manager = $$ClientTagsTableTableManager(
      $_db,
      $_db.clientTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clientTagsRefs(
    Expression<bool> Function($$ClientTagsTableFilterComposer f) f,
  ) {
    final $$ClientTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableFilterComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> clientTagsRefs<T extends Object>(
    Expression<T> Function($$ClientTagsTableAnnotationComposer a) f,
  ) {
    final $$ClientTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.clientTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool clientTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<int> color = const Value.absent(),
          }) => TagsCompanion(id: id, name: name, emoji: emoji, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> emoji = const Value.absent(),
                Value<int> color = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (clientTagsRefs) db.clientTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clientTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, ClientTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._clientTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).clientTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool clientTagsRefs})
    >;
typedef $$ClientTagsTableCreateCompanionBuilder = ClientTagsCompanion Function({
  required int clientId,
  required int tagId,
  Value<int> rowid,
});
typedef $$ClientTagsTableUpdateCompanionBuilder = ClientTagsCompanion Function({
  Value<int> clientId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$ClientTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientTagsTable, ClientTag> {
  $$ClientTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias('client_tags__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<int>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('client_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClientTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientTagsTable> {
  $$ClientTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientTagsTable> {
  $$ClientTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientTagsTable> {
  $$ClientTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientTagsTable,
          ClientTag,
          $$ClientTagsTableFilterComposer,
          $$ClientTagsTableOrderingComposer,
          $$ClientTagsTableAnnotationComposer,
          $$ClientTagsTableCreateCompanionBuilder,
          $$ClientTagsTableUpdateCompanionBuilder,
          (ClientTag, $$ClientTagsTableReferences),
          ClientTag,
          PrefetchHooks Function({bool clientId, bool tagId})
        > {
  $$ClientTagsTableTableManager(_$AppDatabase db, $ClientTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> clientId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientTagsCompanion(
                clientId: clientId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int clientId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => ClientTagsCompanion.insert(
                clientId: clientId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientTagsTable, ClientTag>(table),
                  $$ClientTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clientId,
                        referencedTable: $$ClientTagsTableReferences
                            ._clientIdTable(db),
                        referencedColumn: $$ClientTagsTableReferences
                            ._clientIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$ClientTagsTableReferences
                            ._tagIdTable(db),
                        referencedColumn: $$ClientTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClientTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientTagsTable,
      ClientTag,
      $$ClientTagsTableFilterComposer,
      $$ClientTagsTableOrderingComposer,
      $$ClientTagsTableAnnotationComposer,
      $$ClientTagsTableCreateCompanionBuilder,
      $$ClientTagsTableUpdateCompanionBuilder,
      (ClientTag, $$ClientTagsTableReferences),
      ClientTag,
      PrefetchHooks Function({bool clientId, bool tagId})
    >;
typedef $$PlanTemplatesTableCreateCompanionBuilder =
    PlanTemplatesCompanion Function({
      Value<int> id,
      required String name,
      required int sessions,
      required int days,
    });
typedef $$PlanTemplatesTableUpdateCompanionBuilder =
    PlanTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sessions,
      Value<int> days,
    });

final class $$PlanTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $PlanTemplatesTable, PlanTemplate> {
  $$PlanTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ClientPlansTable, List<ClientPlan>>
  _clientPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clientPlans,
    aliasName: 'plan_templates__id__client_plans__template_id',
  );

  $$ClientPlansTableProcessedTableManager get clientPlansRefs {
    final manager = $$ClientPlansTableTableManager(
      $_db,
      $_db.clientPlans,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTemplatesTable> {
  $$PlanTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessions => $composableBuilder(
    column: $table.sessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clientPlansRefs(
    Expression<bool> Function($$ClientPlansTableFilterComposer f) f,
  ) {
    final $$ClientPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableFilterComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTemplatesTable> {
  $$PlanTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessions => $composableBuilder(
    column: $table.sessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTemplatesTable> {
  $$PlanTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sessions =>
      $composableBuilder(column: $table.sessions, builder: (column) => column);

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  Expression<T> clientPlansRefs<T extends Object>(
    Expression<T> Function($$ClientPlansTableAnnotationComposer a) f,
  ) {
    final $$ClientPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanTemplatesTable,
          PlanTemplate,
          $$PlanTemplatesTableFilterComposer,
          $$PlanTemplatesTableOrderingComposer,
          $$PlanTemplatesTableAnnotationComposer,
          $$PlanTemplatesTableCreateCompanionBuilder,
          $$PlanTemplatesTableUpdateCompanionBuilder,
          (PlanTemplate, $$PlanTemplatesTableReferences),
          PlanTemplate,
          PrefetchHooks Function({bool clientPlansRefs})
        > {
  $$PlanTemplatesTableTableManager(_$AppDatabase db, $PlanTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sessions = const Value.absent(),
                Value<int> days = const Value.absent(),
              }) => PlanTemplatesCompanion(
                id: id,
                name: name,
                sessions: sessions,
                days: days,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int sessions,
                required int days,
              }) => PlanTemplatesCompanion.insert(
                id: id,
                name: name,
                sessions: sessions,
                days: days,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanTemplatesTable, PlanTemplate>(table),
                  $$PlanTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientPlansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (clientPlansRefs) db.clientPlans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clientPlansRefs)
                    await $_getPrefetchedData<
                      PlanTemplate,
                      $PlanTemplatesTable,
                      ClientPlan
                    >(
                      currentTable: table,
                      referencedTable: $$PlanTemplatesTableReferences
                          ._clientPlansRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlanTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).clientPlansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlanTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanTemplatesTable,
      PlanTemplate,
      $$PlanTemplatesTableFilterComposer,
      $$PlanTemplatesTableOrderingComposer,
      $$PlanTemplatesTableAnnotationComposer,
      $$PlanTemplatesTableCreateCompanionBuilder,
      $$PlanTemplatesTableUpdateCompanionBuilder,
      (PlanTemplate, $$PlanTemplatesTableReferences),
      PlanTemplate,
      PrefetchHooks Function({bool clientPlansRefs})
    >;
typedef $$ClientPlansTableCreateCompanionBuilder =
    ClientPlansCompanion Function({
      Value<int> id,
      required int clientId,
      required int templateId,
      Value<String?> startDate,
      required int sessions,
      required int days,
      Value<int> price,
      Value<int> sharePercent,
      required int remaining,
      Value<String> status,
      Value<int?> queueOrder,
      Value<String> createdAt,
    });
typedef $$ClientPlansTableUpdateCompanionBuilder =
    ClientPlansCompanion Function({
      Value<int> id,
      Value<int> clientId,
      Value<int> templateId,
      Value<String?> startDate,
      Value<int> sessions,
      Value<int> days,
      Value<int> price,
      Value<int> sharePercent,
      Value<int> remaining,
      Value<String> status,
      Value<int?> queueOrder,
      Value<String> createdAt,
    });

final class $$ClientPlansTableReferences
    extends BaseReferences<_$AppDatabase, $ClientPlansTable, ClientPlan> {
  $$ClientPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias('client_plans__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<int>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlanTemplatesTable _templateIdTable(_$AppDatabase db) => db
      .planTemplates
      .createAlias('client_plans__template_id__plan_templates__id');

  $$PlanTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$PlanTemplatesTableTableManager(
      $_db,
      $_db.planTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'client_plans__id__transactions__plan_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientPlansTableFilterComposer
    extends Composer<_$AppDatabase, $ClientPlansTable> {
  $$ClientPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessions => $composableBuilder(
    column: $table.sessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sharePercent => $composableBuilder(
    column: $table.sharePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queueOrder => $composableBuilder(
    column: $table.queueOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanTemplatesTableFilterComposer get templateId {
    final $$PlanTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.planTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.planTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientPlansTable> {
  $$ClientPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessions => $composableBuilder(
    column: $table.sessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sharePercent => $composableBuilder(
    column: $table.sharePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queueOrder => $composableBuilder(
    column: $table.queueOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanTemplatesTableOrderingComposer get templateId {
    final $$PlanTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.planTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.planTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientPlansTable> {
  $$ClientPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get sessions =>
      $composableBuilder(column: $table.sessions, builder: (column) => column);

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get sharePercent => $composableBuilder(
    column: $table.sharePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get queueOrder => $composableBuilder(
    column: $table.queueOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanTemplatesTableAnnotationComposer get templateId {
    final $$PlanTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.planTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.planTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientPlansTable,
          ClientPlan,
          $$ClientPlansTableFilterComposer,
          $$ClientPlansTableOrderingComposer,
          $$ClientPlansTableAnnotationComposer,
          $$ClientPlansTableCreateCompanionBuilder,
          $$ClientPlansTableUpdateCompanionBuilder,
          (ClientPlan, $$ClientPlansTableReferences),
          ClientPlan,
          PrefetchHooks Function({
            bool clientId,
            bool templateId,
            bool transactionsRefs,
          })
        > {
  $$ClientPlansTableTableManager(_$AppDatabase db, $ClientPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clientId = const Value.absent(),
                Value<int> templateId = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<int> sessions = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<int> sharePercent = const Value.absent(),
                Value<int> remaining = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> queueOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ClientPlansCompanion(
                id: id,
                clientId: clientId,
                templateId: templateId,
                startDate: startDate,
                sessions: sessions,
                days: days,
                price: price,
                sharePercent: sharePercent,
                remaining: remaining,
                status: status,
                queueOrder: queueOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clientId,
                required int templateId,
                Value<String?> startDate = const Value.absent(),
                required int sessions,
                required int days,
                Value<int> price = const Value.absent(),
                Value<int> sharePercent = const Value.absent(),
                required int remaining,
                Value<String> status = const Value.absent(),
                Value<int?> queueOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ClientPlansCompanion.insert(
                id: id,
                clientId: clientId,
                templateId: templateId,
                startDate: startDate,
                sessions: sessions,
                days: days,
                price: price,
                sharePercent: sharePercent,
                remaining: remaining,
                status: status,
                queueOrder: queueOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientPlansTable, ClientPlan>(table),
                  $$ClientPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                templateId = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clientId,
                            referencedTable: $$ClientPlansTableReferences
                                ._clientIdTable(db),
                            referencedColumn: $$ClientPlansTableReferences
                                ._clientIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (templateId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.templateId,
                            referencedTable: $$ClientPlansTableReferences
                                ._templateIdTable(db),
                            referencedColumn: $$ClientPlansTableReferences
                                ._templateIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          ClientPlan,
                          $ClientPlansTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ClientPlansTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientPlansTable,
      ClientPlan,
      $$ClientPlansTableFilterComposer,
      $$ClientPlansTableOrderingComposer,
      $$ClientPlansTableAnnotationComposer,
      $$ClientPlansTableCreateCompanionBuilder,
      $$ClientPlansTableUpdateCompanionBuilder,
      (ClientPlan, $$ClientPlansTableReferences),
      ClientPlan,
      PrefetchHooks Function({
        bool clientId,
        bool templateId,
        bool transactionsRefs,
      })
    >;
typedef $$AttendanceTableCreateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  required int clientId,
  Value<int?> planId,
  required String date,
  required String status,
  Value<String> createdAt,
});
typedef $$AttendanceTableUpdateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  Value<int> clientId,
  Value<int?> planId,
  Value<String> date,
  Value<String> status,
  Value<String> createdAt,
});

final class $$AttendanceTableReferences
    extends BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData> {
  $$AttendanceTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias('attendance__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<int>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceTable,
          AttendanceData,
          $$AttendanceTableFilterComposer,
          $$AttendanceTableOrderingComposer,
          $$AttendanceTableAnnotationComposer,
          $$AttendanceTableCreateCompanionBuilder,
          $$AttendanceTableUpdateCompanionBuilder,
          (AttendanceData, $$AttendanceTableReferences),
          AttendanceData,
          PrefetchHooks Function({bool clientId})
        > {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clientId = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => AttendanceCompanion(
                id: id,
                clientId: clientId,
                planId: planId,
                date: date,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clientId,
                Value<int?> planId = const Value.absent(),
                required String date,
                required String status,
                Value<String> createdAt = const Value.absent(),
              }) => AttendanceCompanion.insert(
                id: id,
                clientId: clientId,
                planId: planId,
                date: date,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceTable, AttendanceData>(table),
                  $$AttendanceTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clientId,
                        referencedTable: $$AttendanceTableReferences
                            ._clientIdTable(db),
                        referencedColumn: $$AttendanceTableReferences
                            ._clientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceTable,
      AttendanceData,
      $$AttendanceTableFilterComposer,
      $$AttendanceTableOrderingComposer,
      $$AttendanceTableAnnotationComposer,
      $$AttendanceTableCreateCompanionBuilder,
      $$AttendanceTableUpdateCompanionBuilder,
      (AttendanceData, $$AttendanceTableReferences),
      AttendanceData,
      PrefetchHooks Function({bool clientId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int?> clientId,
      Value<int?> planId,
      required String type,
      required String category,
      required int amount,
      required String date,
      Value<String> note,
      Value<String> createdAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int?> clientId,
      Value<int?> planId,
      Value<String> type,
      Value<String> category,
      Value<int> amount,
      Value<String> date,
      Value<String> note,
      Value<String> createdAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias('transactions__client_id__clients__id');

  $$ClientsTableProcessedTableManager? get clientId {
    final $_column = $_itemColumn<int>('client_id');
    if ($_column == null) return null;
    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClientPlansTable _planIdTable(_$AppDatabase db) =>
      db.clientPlans.createAlias('transactions__plan_id__client_plans__id');

  $$ClientPlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $$ClientPlansTableTableManager(
      $_db,
      $_db.clientPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientPlansTableFilterComposer get planId {
    final $$ClientPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableFilterComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientPlansTableOrderingComposer get planId {
    final $$ClientPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableOrderingComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientPlansTableAnnotationComposer get planId {
    final $$ClientPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.clientPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.clientPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool clientId, bool planId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> clientId = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                clientId: clientId,
                planId: planId,
                type: type,
                category: category,
                amount: amount,
                date: date,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> clientId = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                required String type,
                required String category,
                required int amount,
                required String date,
                Value<String> note = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                clientId: clientId,
                planId: planId,
                type: type,
                category: category,
                amount: amount,
                date: date,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, Transaction>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false, planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clientId,
                        referencedTable: $$TransactionsTableReferences
                            ._clientIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._clientIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (planId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.planId,
                        referencedTable: $$TransactionsTableReferences
                            ._planIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._planIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool clientId, bool planId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ClientTagsTableTableManager get clientTags =>
      $$ClientTagsTableTableManager(_db, _db.clientTags);
  $$PlanTemplatesTableTableManager get planTemplates =>
      $$PlanTemplatesTableTableManager(_db, _db.planTemplates);
  $$ClientPlansTableTableManager get clientPlans =>
      $$ClientPlansTableTableManager(_db, _db.clientPlans);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
