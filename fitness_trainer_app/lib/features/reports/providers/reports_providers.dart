import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/features/reports/data/reports_service.dart';

final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService();
});