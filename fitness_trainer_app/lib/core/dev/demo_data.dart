import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_session_service.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';

/// Development-only data seeder so the app can be exercised (attendance,
/// session consumption, queue promotion, dashboard alerts) without typing
/// everything by hand.
///
/// Only wired into the UI behind `kDebugMode`, so it can never ship.
class DemoDataService {
  final ClientsService clientsService;
  final TagsService tagsService;
  final TemplatesService templatesService;
  final PlansService plansService;
  final AttendanceSessionService attendanceSessionService;

  DemoDataService({
    required this.clientsService,
    required this.tagsService,
    required this.templatesService,
    required this.plansService,
    required this.attendanceSessionService,
  });

  /// Jalali `yyyy/MM/dd` for [days] ago, using the same format as
  /// `jalaliToday()`.
  static String _daysAgo(int days) {
    final date = DateTime.now().subtract(Duration(days: days));
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Future<String> seed() async {
    // Templates
    final basicId = await templatesService.createTemplate('برنامه مبتدی', 8, 30);
    final proId = await templatesService.createTemplate('برنامه حرفه‌ای', 12, 45);
    final intensiveId = await templatesService.createTemplate('برنامه فشرده', 24, 90);

    // Tags
    final beginnerTag = await tagsService.createTag('مبتدی', emoji: '🌱', color: 0xFF88A36B);
    final weightLossTag = await tagsService.createTag('کاهش وزن', emoji: '🔥', color: 0xFF8B4A3E);
    final vipTag = await tagsService.createTag('ویژه', emoji: '⭐', color: 0xFFFFB74D);

    // Clients
    final saraId = await clientsService.createClient('سارا محمدی', contact: '09120000001', note: 'سه روز در هفته');
    final aliId = await clientsService.createClient('علی رضایی', contact: '09120000002', bonusSessions: 3);
    final minaId = await clientsService.createClient('مینا کریمی', contact: '09120000003');
    final rezaId = await clientsService.createClient('رضا احمدی', contact: '09120000004', note: 'برنامه فشرده');

    await tagsService.assignTagToClient(saraId, weightLossTag);
    await tagsService.assignTagToClient(saraId, beginnerTag);
    await tagsService.assignTagToClient(aliId, vipTag);
    await tagsService.assignTagToClient(rezaId, vipTag);

    // Plans: Sara gets an active plan plus a queued one (so queue promotion
    // stays observable), Reza a long plan that is nearly finished (low-session
    // alert), Mina a normal plan, and Ali deliberately has no plan so his
    // bonus sessions get consumed instead.
    await plansService.assignPlan(saraId, basicId, 8, 30);
    await plansService.assignPlan(saraId, proId, 12, 45);
    await plansService.assignPlan(rezaId, intensiveId, 24, 90);
    await plansService.assignPlan(minaId, proId, 12, 45);

    // Attendance (this consumes plan sessions / bonus sessions).
    // Sara: 7 records of 8 -> 1 session left (low-session alert).
    for (final day in [1, 3, 5, 8, 10, 12]) {
      await attendanceSessionService.markAttendance(saraId, _daysAgo(day), 'present');
    }
    await attendanceSessionService.markAttendance(saraId, _daysAgo(2), 'absent');
    // Reza: 22 of 24 -> 2 sessions left (low-session alert).
    for (var day = 1; day <= 22; day++) {
      await attendanceSessionService.markAttendance(rezaId, _daysAgo(day), 'present');
    }
    // Mina: one session.
    await attendanceSessionService.markAttendance(minaId, _daysAgo(4), 'present');
    // Ali: no plan, so one bonus session is consumed (2 left).
    await attendanceSessionService.markAttendance(aliId, _daysAgo(1), 'present');

    return 'داده نمونه اضافه شد: ۴ مشتری، ۳ قالب، ۳ برچسب و ۳۱ رکورد حضور';
  }
}

final demoDataServiceProvider = Provider<DemoDataService>((ref) {
  return DemoDataService(
    clientsService: ref.watch(clientsServiceProvider),
    tagsService: ref.watch(tagsServiceProvider),
    templatesService: ref.watch(templatesServiceProvider),
    plansService: ref.watch(plansServiceProvider),
    attendanceSessionService: ref.watch(attendanceSessionServiceProvider),
  );
});