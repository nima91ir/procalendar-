import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/utils/plan_dates.dart';
import 'package:fitness_trainer_app/core/utils/thousands_input_formatter.dart';
import 'package:fitness_trainer_app/core/widgets/app_charts.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/tags/presentation/widgets/client_tag_picker.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class ClientDetailScreen extends ConsumerWidget {
  final int clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  String _statusLabel(String status, AppStrings s) => switch (status) {
        'active' => s.statusActive,
        'frozen' => s.statusFrozen,
        'queued' => s.statusQueued,
        _ => s.statusExpired,
      };

  Color _statusColor(String status, AppTones t) => switch (status) {
        'active' => t.success,
        'frozen' => t.frozen,
        'queued' => t.queued,
        _ => t.error,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final lang = ref.watch(languageProvider);
    final clientsAsync = ref.watch(allClientsProvider);
    final plansAsync = ref.watch(clientPlansProvider(clientId));
    final templatesAsync = ref.watch(allTemplatesProvider);
    final tagsAsync = ref.watch(clientTagsProvider(clientId));

    // Was `firstWhere(..., orElse: () => clients.first)`, which silently
    // showed a *different* client when the id no longer existed.
    final client = clientsAsync.value?.where((c) => c.id == clientId).firstOrNull;
    final clientName = client?.name ?? s.clientNotFound;
    final templates = templatesAsync.value;
    final clientTags = tagsAsync.value ?? const <domain.Tag>[];

    String templateLabel(int templateId) =>
        templates?.where((t) => t.id == templateId).firstOrNull?.name ?? '${s.addPlan} #$templateId';

    Future<void> deleteClient() async {
      final confirmed = await AppConfirmDialog.show(
        context,
        title: s.deleteClientTitle,
        message: s.deleteClientMessage(clientName),
        confirmLabel: s.delete,
      );
      if (!confirmed) return;
      await ref.read(clientsServiceProvider).deleteClient(clientId);
      ref.invalidateAppData();
      if (context.mounted) Navigator.pop(context, true);
    }

    Future<void> editTags() async {
      final service = ref.read(tagsServiceProvider);
      final current = (await service.getClientTagIds(clientId)).toSet();
      if (!context.mounted) return;
      final selected = await showClientTagPicker(context, ref, current);
      if (selected == null) return;
      for (final id in selected.difference(current)) {
        await service.assignTagToClient(clientId, id);
      }
      for (final id in current.difference(selected)) {
        await service.removeTagFromClient(clientId, id);
      }
      ref.invalidate(clientTagsProvider(clientId));
      ref.invalidateAppData();
    }

    /// Moves the client's bonus-session counter by [delta] (clamped at 0).
    /// The profile owns this now: the quick +/− stepper used to sit on the
    /// client card, where a mis-tap silently changed the counter.
    Future<void> adjustBonus(int current, int delta) async {
      final messenger = ScaffoldMessenger.of(context);
      final s = AppStrings.of(context);
      final next = (current + delta).clamp(0, 9999);
      if (next == current) return;
      await ref.read(clientsServiceProvider).updateClientBonus(clientId, next);
      ref.invalidateAppData();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(delta > 0 ? s.bonusAdded : s.bonusRemoved)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.name ?? s.clientNotFound),
        actions: [
          IconButton(
            tooltip: s.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final changed = await Navigator.pushNamed(context, '${AppRoutes.editClient}/$clientId');
              if (changed == true) {
                ref.invalidate(allClientsProvider);
              }
            },
          ),
          IconButton(
            tooltip: s.deleteClientTitle,
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (client == null) return;
              deleteClient();
            },
          ),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (clients) {
          if (client == null) {
            return const AppEmptyState(icon: Icons.person_off_outlined, title: '');
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppHeroHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withValues(alpha: 0.22),
                          child: Text(
                            client.name.isNotEmpty ? client.name[0] : '؟',
                            style: AppTypography.headlineLarge.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.name, style: AppTypography.titleLarge),
                              if (client.contact != null && client.contact!.isNotEmpty)
                                Text(client.contact!, style: AppTypography.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (client.bonusSessions > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      _HeroChip(
                        icon: Icons.card_giftcard,
                        label: s.clientsWithBonus(client.bonusSessions),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final tag in clientTags)
                          _HeroChip(
                            icon: tag.emoji.isNotEmpty ? null : Icons.label,
                            label: tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name,
                            onTap: () => editTags(),
                          ),
                        _HeroChip(
                          icon: Icons.add,
                          label: s.addTag,
                          onTap: () => editTags(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _CollapsibleSection(
                title: s.contactInfo,
                initiallyExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: s.phoneNumber, value: client.contact ?? s.notProvided),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(label: s.note, value: client.note.isNotEmpty ? client.note : s.notProvided),
                    const SizedBox(height: AppSpacing.sm),
                    // Same layout as _InfoRow, but with the +/− stepper that
                    // used to live on the client card.
                    Row(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
                          child: Text(s.bonusSessionsLabel, style: AppTypography.bodySmall),
                        ),
                        Expanded(
                          child: Text(s.clientsWithBonus(client.bonusSessions), style: AppTypography.bodyLarge),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: s.bonusRemoved,
                          onPressed: client.bonusSessions > 0 ? () => adjustBonus(client.bonusSessions, -1) : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: client.bonusSessions > 0 ? t.onSurfaceVar : t.surfaceVariant,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: s.bonusAdded,
                          onPressed: () => adjustBonus(client.bonusSessions, 1),
                          icon: Icon(Icons.add_circle_outline, color: t.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // NOTE: SectionHeader must not be placed inside a Row - it uses
              // `Expanded` internally, and inside a Row the width constraint is
              // unbounded, which threw "RenderFlex children have non-zero flex
              // but incoming width constraints are unbounded" and blanked the
              // whole client detail screen.
              SectionHeader(title: s.plansSection),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '${AppRoutes.addPlan}/$clientId'),
                      icon: const Icon(Icons.add),
                      label: Text(s.addPlan),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '${AppRoutes.attendance}/$clientId'),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(s.attendanceLabel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              plansAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorState(message: e.toString()),
                data: (plans) {
                  if (plans.isEmpty) {
                    return AppEmptyState(icon: Icons.calendar_today, title: s.planNotFound);
                  }
                  return Column(
                    children: plans.map((plan) {
                      final remaining = plan.remaining;
                      final sessions = plan.sessions;
                      final status = plan.status;
                      final consumed = sessions > 0
                          ? ((sessions - remaining) / sessions).clamp(0.0, 1.0)
                          : 0.0;
                      // Null for queued plans (no start date yet).
                      final daysLeft = planRemainingDays(startDate: plan.startDate, days: plan.days);
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        onTap: () => Navigator.pushNamed(context, '${AppRoutes.attendance}/$clientId/${plan.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(templateLabel(plan.templateId), style: AppTypography.headlineMedium),
                                      const SizedBox(height: AppSpacing.xs),
                                      AppPill(
                                        label: _statusLabel(status, s),
                                        color: _statusColor(status, t),
                                        isSelected: true,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        s.remainingDetail(remaining, sessions),
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                AppProgressRing(
                                  size: 64,
                                  strokeWidth: 6,
                                  value: consumed,
                                  progressColor: _statusColor(status, t),
                                  child: Text(
                                    s.isPersian ? toPersian('$remaining') : '$remaining',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: _statusColor(status, t),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Icon(Icons.event, size: 15, color: t.onSurfaceVar),
                                const SizedBox(width: 4),
                                Text('${s.startDateLabel}: ', style: AppTypography.bodySmall),
                                Expanded(
                                  child: Text(
                                    plan.startDate == null || plan.startDate!.isEmpty
                                        ? s.notProvided
                                        : formatDateShort(plan.startDate!, lang),
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                AppPill(label: s.remainingSessions(remaining), color: t.successSoft),
                                if (daysLeft != null)
                                  AppPill(label: s.remainingDays(daysLeft), color: t.primaryLight),
                              ],
                            ),
                            const Divider(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final result = await showDialog<({int price, int share})>(
                                      context: context,
                                      builder: (ctx) => _PlanPriceDialog(
                                        initialPrice: plan.price,
                                        initialShare: plan.sharePercent,
                                      ),
                                    );
                                    if (result == null) return;
                                    try {
                                      await ref.read(plansServiceProvider).setPlanPrice(
                                            plan.id!,
                                            result.price,
                                            result.share,
                                          );
                                      ref.invalidateAppData();
                                      messenger.showSnackBar(
                                        SnackBar(content: Text(s.planPriceSaved)),
                                      );
                                    } catch (e) {
                                      messenger.showSnackBar(
                                        SnackBar(content: Text('${s.errorPrefix}$e')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.payments_outlined, size: 18),
                                  label: Text(s.setPlanPrice),
                                ),
                                if (status == 'active')
                                  TextButton.icon(
                                    onPressed: () async {
                                      await ref.read(plansServiceProvider).freezePlan(plan.id!);
                                      ref.invalidateAppData();
                                    },
                                    icon: const Icon(Icons.pause_circle_outline, size: 18),
                                    label: Text(s.freeze),
                                  ),
                                if (status == 'frozen')
                                  TextButton.icon(
                                    onPressed: () async {
                                      await ref.read(plansServiceProvider).unfreezePlan(plan.id!);
                                      ref.invalidateAppData();
                                    },
                                    icon: const Icon(Icons.play_circle_outline, size: 18),
                                    label: Text(s.activate),
                                  ),
                                TextButton.icon(
                                  onPressed: () async {
                                    final confirmed = await AppConfirmDialog.show(
                                      context,
                                      title: s.deletePlan,
                                      message: s.deletePlanMessage,
                                      confirmLabel: s.delete,
                                    );
                                    if (!confirmed) return;
                                    await ref.read(plansServiceProvider).deletePlan(plan.id!);
                                    ref.invalidateAppData();
                                  },
                                  icon: Icon(Icons.delete_outline, size: 18, color: t.error),
                                  label: Text(s.deletePlan),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const _HeroChip({required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTypography.labelMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _CollapsibleSection({required this.title, required this.child, this.initiallyExpanded = false});

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: AppTypography.headlineMedium)),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
          child: Text(label, style: AppTypography.bodySmall),
        ),
        Expanded(child: Text(value, style: AppTypography.bodyLarge)),
      ],
    );
  }
}

/// Dialog to record or correct the price and gym-share of an existing plan.
/// Works for every plan status (active, frozen, queued, expired) — this is how
/// plans created before the pricing feature get their revenue entered.
class _PlanPriceDialog extends StatefulWidget {
  final int initialPrice;
  final int initialShare;

  const _PlanPriceDialog({required this.initialPrice, required this.initialShare});

  @override
  State<_PlanPriceDialog> createState() => _PlanPriceDialogState();
}

class _PlanPriceDialogState extends State<_PlanPriceDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _shareController;

  @override
  void initState() {
    super.initState();
    // Prefilled grouped so an existing price reads `1,000,000`, exactly like
    // the live input formatting below.
    _priceController = TextEditingController(
      text: widget.initialPrice > 0 ? groupDigits(widget.initialPrice) : '',
    );
    _shareController = TextEditingController(text: '${widget.initialShare}');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AlertDialog(
      title: Text(s.planPriceDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: const [ThousandsSeparatorInputFormatter()],
            decoration: InputDecoration(
              labelText: s.planPriceLabel,
              helperText: s.planPriceHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _shareController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s.planShareLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            final priceText = _priceController.text.trim().replaceAll(',', '');
            final price = int.tryParse(toLatinDigits(priceText)) ?? 0;
            final rawShare = int.tryParse(toLatinDigits(_shareController.text.trim()));
            final share = rawShare == null ? 0 : rawShare.clamp(0, 100).toInt();
            Navigator.pop(context, (price: price, share: share));
          },
          child: Text(s.save),
        ),
      ],
    );
  }
}