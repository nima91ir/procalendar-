import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';

class PastAttendanceScreen extends ConsumerWidget {
  final int clientId;
  const PastAttendanceScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(clientAttendanceProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: const Text('سوابق حضور و غیاب')),
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (records) {
          if (records.isEmpty) {
            return const AppEmptyState(icon: Icons.history, title: 'هنوز سابقه‌ای ثبت نشده');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isPresent = record.isPresent;
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  leading: Icon(
                    isPresent ? Icons.check_circle : Icons.cancel,
                    color: isPresent ? AppColors.present : AppColors.absent,
                  ),
                  title: Text(formatJalaliLong(record.date)),
                  trailing: AppPill(
                    label: isPresent ? 'حاضر' : 'غایب',
                    color: isPresent ? AppColors.successSoft : AppColors.errorSoft,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
