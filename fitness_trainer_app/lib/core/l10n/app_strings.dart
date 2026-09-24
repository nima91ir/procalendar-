import 'package:flutter/material.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import '../utils/persian_numbers.dart';
import '../utils/jalali_calendar.dart';

/// Lightweight localization (no i18n package).
///
/// Every string is a field on [AppStrings]; [AppStrings.fa] and
/// [AppStrings.en] are the two const locales. Screens resolve the active
/// locale via [AppStrings.of], which responds to the ambient [Locale] set by
/// `MaterialApp` (so the widget rebuilds automatically on language switch).
class AppStrings {
  final bool isPersian;

  // Template-based strings use `{token}` placeholders.
  final String welcomeTemplate;
  final String bonusClientsTemplate;
  final String remainingSessionsTemplate;
  final String clientsWithBonusTemplate;
  final String remainingDetailTemplate;
  final String deleteClientMessageTemplate;
  final String attendanceCountTemplate;
  final String recordAddedTemplate;
  final String recordRemovedTemplate;
  final String clientDeletedTemplate;

  // Common actions
  final String ok;
  final String yes;
  final String no;
  final String cancel;
  final String confirm;
  final String delete;
  final String edit;
  final String save;
  final String saved;
  final String errorPrefix;
  final String loading;

  // Navigation
  final String appTitle;
  final String navDashboard;
  final String navClients;
  final String navTemplates;
  final String navTags;
  final String navSettings;
  final String navAccounting;

  // Accounting
  final String totalIncome;
  final String totalExpense;
  final String balanceLabel;
  final String gymShareLabel;
  final String gymShareRateTemplate;
  final String addTransaction;
  final String transactionsLabel;
  final String noTransactionsTitle;
  final String noTransactionsSubtitle;
  final String transactionType;
  final String incomeTypeLabel;
  final String expenseTypeLabel;
  final String categoryLabel;
  final String amountLabel;
  final String amountRequired;
  final String dateLabel;
  final String clientOptionalLabel;
  final String noClientSelected;
  final String deleteTransactionTitle;
  final String deleteTransactionMessage;
  final String transactionSaved;
  final String transactionDeleted;
  final String editTransaction;
  final String transactionUpdated;
  final String incomeCategoryPlan;
  final String incomeCategoryOther;
  final String expenseCategoryRent;
  final String expenseCategorySalary;
  final String expenseCategoryEquipment;
  final String gymShareSettingTitle;
  final String gymShareSettingHint;
  final String planPriceLabel;
  final String planPriceHint;
  final String planShareLabel;
  final String perPlanShareTitle;
  final String planPriceDialogTitle;
  final String planPriceSaved;
  final String setPlanPrice;
  final String shareRateTemplate;
  final String remainingDaysTemplate;
  final String gymShareDeductionTemplate;
  final String netIncomeLabel;
  final String openReports;
  final String reportsTitle;
  final String weeklyLabel;
  final String monthlyLabel;
  final String yearlyLabel;
  final String monthlyChartTitle;
  final String weeklyChartTitle;
  final String noReportsTitle;
  final String noReportsSubtitle;

  // Settings
  final String settingsTitle;
  final String trainerInfo;
  final String trainerNameLabel;
  final String saveName;
  final String appearance;
  final String themeLabel;
  final String themeSystem;
  final String themeLight;
  final String themeDark;
  final String accentColorLabel;
  final String accentGreen;
  final String accentBlue;
  final String accentPurple;
  final String accentRose;
  final String accentOrange;
  final String accentTeal;
  final String languageLabel;
  final String languageFa;
  final String languageEn;
  final String devTools;
  final String devToolsDescription;
  final String seedDemoData;
  final String databaseFailedTitle;

  // Dashboard
  final String dashboardTitle;
  final String totalClients;
  final String expiredPlans;
  final String frozenPlans;
  final String queuedPlans;
  final String todayAttendance;
  final String noAttendanceYet;
  final String noAttendanceSubtitle;
  final String noClientsTitle;
  final String noClientsSubtitle;
  final String present;
  final String absent;
  final String lowSessionPlans;
  final String viewClients;
  final String sessionsLeft;
  final String addClient;
  final String registerPresent;
  final String registerAbsent;
  final String unmarked;
  final String undoAttendance;

  // Client detail
  final String contactInfo;
  final String phoneNumber;
  final String note;
  final String notProvided;
  final String bonusSessionsLabel;
  final String activePlans;
  final String addPlan;
  final String planProgress;
  final String attendanceLabel;
  final String planNotFound;
  final String clientNotFound;
  final String freeze;
  final String activate;
  final String deletePlan;
  final String deletePlanMessage;
  final String deleteClientTitle;
  final String statusActive;
  final String statusFrozen;
  final String statusQueued;
  final String statusExpired;

  // Clients screen
  final String searchHint;
  final String allLabel;
  final String sortBy;
  final String sortName;
  final String sortNewest;
  final String sortBonus;
  final String noResults;
  final String noResultsSubtitle;

  // Clients list (localization for the refreshed clients screen)
  final String clientsTitle;
  final String emptyClientsTitle;
  final String emptyClientsSubtitle;
  final String addClientFab;
  final String sortSheetTitle;
  final String sortByName;
  final String sortByNewest;
  final String sortByBonusSessions;
  final String confirmDeleteClient;
  final String tapToOpenProfile;
  final String openAttendance;
  final String editClient;
  final String deleteClient;

  // Client detail plan section (active/expired tabs)
  final String activePlansTab;
  final String expiredPlansTab;
  final String noPlansYet;
  final String planTemplateLabel;
  // Attendance
  final String sessionStatusTitle;
  final String activePlanRemainingLabel;
  final String noActivePlanLabel;
  final String queuedPlansLabel;
  final String recordedSessionsLabel;
  final String quickAddToday;
  final String bonusSessions;
  final String attendanceHistory;
  final String noHistoryYet;
  final String noHistorySubtitle;
  final String deleteSession;
  final String plansSection;
  // Bonus sessions & tag filters
  final String bonusSessionCountTemplate;
  final String bonusAdded;
  final String bonusRemoved;
  final String noClientsWithTag;
  final String tagsSection;
  final String addTag;
  final String noTagsDefined;
  final String pageNotFound;

  // Templates screen
  final String templatesTitle;
  final String noTemplatesTitle;
  final String noTemplatesSubtitle;
  final String addTemplate;
  final String usedByCountTemplate;
  final String deleteTemplateTitle;
  final String deleteTemplateMessageTemplate;
  final String sessionsCountTemplate;
  final String daysCountTemplate;
  final String oneSessionPerDaysTemplate;

  // Tags screen
  final String newTag;
  final String editTagTitle;
  final String deleteTagTitle;
  final String deleteTagMessageTemplate;
  final String tagNameLabel;
  final String emojiOptionalLabel;
  final String colorLabel;
  final String tagClientCountTemplate;
  final String noTagsDefinedSubtitle;
  final String manageTags;
  final String clientActionsTitle;

  // Backup & export
  final String backupSection;
  final String backupDescription;
  final String exportBackupJson;
  final String importBackupJson;
  final String exportCsv;
  final String csvClients;
  final String csvPlans;
  final String csvAttendance;
  final String csvTransactions;
  final String backupSavedTemplate;
  final String backupFailedTemplate;
  final String lastBackupLabel;
  final String lastBackupNever;
  final String lastBackupOnTemplate;
  final String daysAgoTemplate;
  final String backupReminderNeverBody;
  final String backupReminderDueTitleTemplate;
  final String backupReminderGo;
  final String backupReminderLater;
  final String importTitle;
  final String importHint;
  final String chooseFile;
  final String pasteFromClipboard;
  final String mergeData;
  final String replaceData;
  final String mergeHint;
  final String replaceWarning;
  final String importInvalid;
  final String importSummaryTemplate;
  final String importDoneTemplate;
  final String replaceConfirmTitle;
  final String replaceConfirmMessage;
  final String importFailedTemplate;
  final String noBackupContent;
  final String safetyCopySavedTemplate;
  final String safetyCopyFailed;

  // Plan assignment (add-plan screen & confirmations)
  final String selectPlanTemplate;
  final String approximateEndTemplate;
  final String chooseThisTemplate;
  final String chooseStartDate;
  final String confirmDate;
  final String reviewStartDate;
  final String startDateLabel;
  final String endDateLabel;
  final String sessionsLabel;
  final String queuedPlanWarning;
  final String confirmStartDateMessage;
  final String yesSavePlan;
  final String planAddedWithStartTemplate;
  final String change;
  final String todayLabel;
  final String prevMonth;
  final String nextMonth;
  final String retryLabel;

  // Client / template editor forms
  final String templateNameLabel;
  final String templateSessionsLabel;
  final String templateDaysLabel;
  final String templateNameRequired;
  final String templateInvalidNumbers;
  final String editTemplateTitle;
  final String clientNameRequired;
  final String clientNameLabel;
  final String contactLabel;
  final String activePlanFallback;
  final String deleteSessionMessage;

  const AppStrings({
    required this.isPersian,
    required this.welcomeTemplate,
    required this.bonusClientsTemplate,
    required this.remainingSessionsTemplate,
    required this.clientsWithBonusTemplate,
    required this.remainingDetailTemplate,
    required this.deleteClientMessageTemplate,
    required this.attendanceCountTemplate,
    required this.recordAddedTemplate,
    required this.recordRemovedTemplate,
    required this.clientDeletedTemplate,
    required this.ok,
    required this.yes,
    required this.no,
    required this.cancel,
    required this.confirm,
    required this.delete,
    required this.edit,
    required this.save,
    required this.saved,
    required this.errorPrefix,
    required this.loading,
    required this.appTitle,
    required this.navDashboard,
    required this.navClients,
    required this.navTemplates,
    required this.navTags,
    required this.navSettings,
    required this.navAccounting,
    required this.totalIncome,
    required this.totalExpense,
    required this.balanceLabel,
    required this.gymShareLabel,
    required this.gymShareRateTemplate,
    required this.addTransaction,
    required this.transactionsLabel,
    required this.noTransactionsTitle,
    required this.noTransactionsSubtitle,
    required this.transactionType,
    required this.incomeTypeLabel,
    required this.expenseTypeLabel,
    required this.categoryLabel,
    required this.amountLabel,
    required this.amountRequired,
    required this.dateLabel,
    required this.clientOptionalLabel,
    required this.noClientSelected,
    required this.deleteTransactionTitle,
    required this.deleteTransactionMessage,
    required this.transactionSaved,
    required this.transactionDeleted,
    required this.editTransaction,
    required this.transactionUpdated,
    required this.incomeCategoryPlan,
    required this.incomeCategoryOther,
    required this.expenseCategoryRent,
    required this.expenseCategorySalary,
    required this.expenseCategoryEquipment,
    required this.gymShareSettingTitle,
    required this.gymShareSettingHint,
    required this.planPriceLabel,
    required this.planPriceHint,
    required this.planShareLabel,
    required this.perPlanShareTitle,
    required this.planPriceDialogTitle,
    required this.planPriceSaved,
    required this.setPlanPrice,
    required this.shareRateTemplate,
    required this.remainingDaysTemplate,
    required this.gymShareDeductionTemplate,
    required this.netIncomeLabel,
    required this.openReports,
    required this.reportsTitle,
    required this.weeklyLabel,
    required this.monthlyLabel,
    required this.yearlyLabel,
    required this.monthlyChartTitle,
    required this.weeklyChartTitle,
    required this.noReportsTitle,
    required this.noReportsSubtitle,
    required this.settingsTitle,
    required this.trainerInfo,
    required this.trainerNameLabel,
    required this.saveName,
    required this.appearance,
    required this.themeLabel,
    required this.themeSystem,
    required this.themeLight,
    required this.themeDark,
    required this.accentColorLabel,
    required this.accentGreen,
    required this.accentBlue,
    required this.accentPurple,
    required this.accentRose,
    required this.accentOrange,
    required this.accentTeal,
    required this.languageLabel,
    required this.languageFa,
    required this.languageEn,
    required this.devTools,
    required this.devToolsDescription,
    required this.seedDemoData,
    required this.databaseFailedTitle,
    required this.dashboardTitle,
    required this.totalClients,
    required this.expiredPlans,
    required this.frozenPlans,
    required this.queuedPlans,
    required this.todayAttendance,
    required this.noAttendanceYet,
    required this.noAttendanceSubtitle,
    required this.noClientsTitle,
    required this.noClientsSubtitle,
    required this.present,
    required this.absent,
    required this.lowSessionPlans,
    required this.viewClients,
    required this.sessionsLeft,
    required this.addClient,
    required this.registerPresent,
    required this.registerAbsent,
    required this.unmarked,
    required this.undoAttendance,
    required this.contactInfo,
    required this.phoneNumber,
    required this.note,
    required this.notProvided,
    required this.bonusSessionsLabel,
    required this.activePlans,
    required this.addPlan,
    required this.planProgress,
    required this.attendanceLabel,
    required this.planNotFound,
    required this.clientNotFound,
    required this.freeze,
    required this.activate,
    required this.deletePlan,
    required this.deletePlanMessage,
    required this.deleteClientTitle,
    required this.statusActive,
    required this.statusFrozen,
    required this.statusQueued,
    required this.statusExpired,
    required this.searchHint,
    required this.allLabel,
    required this.sortBy,
    required this.sortName,
    required this.sortNewest,
    required this.sortBonus,
    required this.noResults,
    required this.noResultsSubtitle,
    required this.clientsTitle,
    required this.emptyClientsTitle,
    required this.emptyClientsSubtitle,
    required this.addClientFab,
    required this.sortSheetTitle,
    required this.sortByName,
    required this.sortByNewest,
    required this.sortByBonusSessions,
    required this.confirmDeleteClient,
    required this.tapToOpenProfile,
    required this.openAttendance,
    required this.editClient,
    required this.deleteClient,
    required this.activePlansTab,
    required this.expiredPlansTab,
    required this.noPlansYet,
    required this.planTemplateLabel,

    required this.sessionStatusTitle,
    required this.activePlanRemainingLabel,
    required this.noActivePlanLabel,
    required this.queuedPlansLabel,
    required this.recordedSessionsLabel,
    required this.quickAddToday,
    required this.bonusSessions,
    required this.attendanceHistory,
    required this.noHistoryYet,
    required this.noHistorySubtitle,
    required this.deleteSession,
    required this.plansSection,
    required this.bonusSessionCountTemplate,
    required this.bonusAdded,
    required this.bonusRemoved,
    required this.noClientsWithTag,
    required this.tagsSection,
    required this.addTag,
    required this.noTagsDefined,
    required this.pageNotFound,
    required this.templatesTitle,
    required this.noTemplatesTitle,
    required this.noTemplatesSubtitle,
    required this.addTemplate,
    required this.usedByCountTemplate,
    required this.deleteTemplateTitle,
    required this.deleteTemplateMessageTemplate,
    required this.sessionsCountTemplate,
    required this.daysCountTemplate,
    required this.oneSessionPerDaysTemplate,
    required this.newTag,
    required this.editTagTitle,
    required this.deleteTagTitle,
    required this.deleteTagMessageTemplate,
    required this.tagNameLabel,
    required this.emojiOptionalLabel,
    required this.colorLabel,
    required this.tagClientCountTemplate,
    required this.noTagsDefinedSubtitle,
    required this.manageTags,
    required this.clientActionsTitle,
    required this.backupSection,
    required this.backupDescription,
    required this.exportBackupJson,
    required this.importBackupJson,
    required this.exportCsv,
    required this.csvClients,
    required this.csvPlans,
    required this.csvAttendance,
    required this.csvTransactions,
    required this.backupSavedTemplate,
    required this.backupFailedTemplate,
    required this.lastBackupLabel,
    required this.lastBackupNever,
    required this.lastBackupOnTemplate,
    required this.daysAgoTemplate,
    required this.backupReminderNeverBody,
    required this.backupReminderDueTitleTemplate,
    required this.backupReminderGo,
    required this.backupReminderLater,
    required this.importTitle,
    required this.importHint,
    required this.chooseFile,
    required this.pasteFromClipboard,
    required this.mergeData,
    required this.replaceData,
    required this.mergeHint,
    required this.replaceWarning,
    required this.importInvalid,
    required this.importSummaryTemplate,
    required this.importDoneTemplate,
    required this.replaceConfirmTitle,
    required this.replaceConfirmMessage,
    required this.importFailedTemplate,
    required this.noBackupContent,
    required this.safetyCopySavedTemplate,
    required this.safetyCopyFailed,
    required this.selectPlanTemplate,
    required this.approximateEndTemplate,
    required this.chooseThisTemplate,
    required this.chooseStartDate,
    required this.confirmDate,
    required this.reviewStartDate,
    required this.startDateLabel,
    required this.endDateLabel,
    required this.sessionsLabel,
    required this.queuedPlanWarning,
    required this.confirmStartDateMessage,
    required this.yesSavePlan,
    required this.planAddedWithStartTemplate,
    required this.change,
    required this.todayLabel,
    required this.prevMonth,
    required this.nextMonth,
    required this.retryLabel,
    required this.templateNameLabel,
    required this.templateSessionsLabel,
    required this.templateDaysLabel,
    required this.templateNameRequired,
    required this.templateInvalidNumbers,
    required this.editTemplateTitle,
    required this.clientNameRequired,
    required this.clientNameLabel,
    required this.contactLabel,
    required this.activePlanFallback,
    required this.deleteSessionMessage,
  });

  String _digits(String value) => isPersian ? toPersian(value) : value;

  String welcomeWith(String name) => welcomeTemplate.replaceAll('{name}', name);
  String bonusClients(int count) => bonusClientsTemplate.replaceAll('{count}', _digits('$count'));
  String remainingSessions(int count) => remainingSessionsTemplate.replaceAll('{count}', _digits('$count'));
  String clientsWithBonus(int count) => clientsWithBonusTemplate.replaceAll('{count}', _digits('$count'));
  String remainingDetail(int remaining, int sessions) => remainingDetailTemplate
      .replaceAll('{remaining}', _digits('$remaining'))
      .replaceAll('{sessions}', _digits('$sessions'));
  String deleteClientMessage(String name) => deleteClientMessageTemplate.replaceAll('{name}', name);
  String attendanceCount(String statusLabel, int count) => attendanceCountTemplate
      .replaceAll('{status}', statusLabel)
      .replaceAll('{count}', _digits('$count'));
  String recordAdded(String statusLabel, String dateText) => recordAddedTemplate
      .replaceAll('{status}', statusLabel)
      .replaceAll('{date}', dateText);
  String recordRemoved(String dateText) => recordRemovedTemplate.replaceAll('{date}', dateText);
  String clientDeleted(String name) => clientDeletedTemplate.replaceAll('{name}', name);
  String bonusSessionsCount(int count) =>
      bonusSessionCountTemplate.replaceAll('{count}', _digits('$count'));
  String usedByCount(int count) => usedByCountTemplate.replaceAll('{count}', _digits('$count'));
  String deleteTemplateMessage(String name) => deleteTemplateMessageTemplate.replaceAll('{name}', name);
  String sessionsCount(int count) => sessionsCountTemplate.replaceAll('{count}', _digits('$count'));
  String daysCount(int count) => daysCountTemplate.replaceAll('{count}', _digits('$count'));
  String oneSessionPerDays(int days) => oneSessionPerDaysTemplate.replaceAll('{days}', _digits('$days'));
  String deleteTagMessage(String name) => deleteTagMessageTemplate.replaceAll('{name}', name);
  String tagClientCount(int count) => tagClientCountTemplate.replaceAll('{count}', _digits('$count'));
  String backupSaved(String file) => backupSavedTemplate.replaceAll('{file}', file);
  String backupFailed(String error) => backupFailedTemplate.replaceAll('{error}', error);
  String lastBackupOn(String date) => lastBackupOnTemplate.replaceAll('{date}', date);
  String daysAgo(int days) => daysAgoTemplate.replaceAll('{days}', _digits('$days'));
  String backupReminderDueTitle(int days) =>
      backupReminderDueTitleTemplate.replaceAll('{days}', _digits('$days'));
  String importSummary(int clients, int plans, int attendance) => importSummaryTemplate
      .replaceAll('{clients}', _digits('$clients'))
      .replaceAll('{plans}', _digits('$plans'))
      .replaceAll('{attendance}', _digits('$attendance'));
  String importDone(int count) => importDoneTemplate.replaceAll('{count}', _digits('$count'));
  String importFailed(String error) => importFailedTemplate.replaceAll('{error}', error);
  String safetyCopySaved(String file) => safetyCopySavedTemplate.replaceAll('{file}', file);
  String approximateEnd(String date) => approximateEndTemplate.replaceAll('{date}', date);
  String planAddedWithStart(String date) => planAddedWithStartTemplate.replaceAll('{date}', date);

  /// Thousands-separated amount in the app language, e.g. `1,250,000`.
  String money(int value) => _digits(_grouped(value));

  String gymShareRate(int percent) =>
      gymShareRateTemplate.replaceAll('{percent}', _digits('$percent'));

  String shareRate(int percent) =>
      shareRateTemplate.replaceAll('{percent}', _digits('$percent'));

  String remainingDays(int count) =>
      remainingDaysTemplate.replaceAll('{count}', _digits('$count'));

  String gymShareDeduction(int amount) =>
      gymShareDeductionTemplate.replaceAll('{amount}', money(amount));

  String transactionCategory(String key) {
    switch (key) {
      case TransactionCategories.plan:
        return incomeCategoryPlan;
      case TransactionCategories.rent:
        return expenseCategoryRent;
      case TransactionCategories.salary:
        return expenseCategorySalary;
      case TransactionCategories.equipment:
        return expenseCategoryEquipment;
      default:
        return incomeCategoryOther;
    }
  }

  static const _enMonthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _enWeekdays = [
    'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri',
  ];

  /// Short month label for a Jalali month (1-12) in the app language.
  /// Persian uses the full month name (there is no distinct short form).
  String monthShort(int month) {
    final index = month.clamp(1, 12) - 1;
    return isPersian ? monthNames[index] : _enMonthShort[index];
  }

  /// Day-of-week label for a Jalali weekday (1 = Saturday ... 7 = Friday).
  String weekdayShort(int weekday) {
    final index = weekday.clamp(1, 7) - 1;
    return isPersian
        ? const ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'][index]
        : _enWeekdays[index];
  }

  static String _grouped(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'en' ? en : fa;
  }

  static const fa = AppStrings(
    isPersian: true,
    welcomeTemplate: 'خوش آمدید، {name}',
    bonusClientsTemplate: '{count} مشتری دارای جلسات اضافه',
    remainingSessionsTemplate: '{count} جلسه باقی‌مانده',
    clientsWithBonusTemplate: '{count} جلسه اضافه',
    remainingDetailTemplate: '{remaining} از {sessions}',
    deleteClientMessageTemplate: 'آیا از حذف «{name}» اطمینان دارید؟ برنامه‌ها و سوابق حضور نیز حذف می‌شوند.',
    attendanceCountTemplate: '{status} ×{count}',
    recordAddedTemplate: '{status} ثبت شد · {date}',
    recordRemovedTemplate: 'ثبت {date} حذف شد',
    clientDeletedTemplate: '{name} حذف شد',
    ok: 'باشه',
    yes: 'بله',
    no: 'خیر',
    cancel: 'انصراف',
    confirm: 'تأیید',
    delete: 'حذف',
    edit: 'ویرایش',
    save: 'ذخیره',
    saved: 'ذخیره شد',
    errorPrefix: 'خطا: ',
    loading: 'در حال بارگذاری...',
    appTitle: 'تقویم حرفه‌ای',
    navDashboard: 'داشبورد',
    navClients: 'مشتریان',
    navTemplates: 'برنامه‌ها',
    navTags: 'برچسب‌ها',
    navSettings: 'تنظیمات',
    navAccounting: 'حسابداری',
    totalIncome: 'درآمد کل',
    totalExpense: 'هزینه کل',
    balanceLabel: 'موجودی',
    gymShareLabel: 'سهم باشگاه',
    gymShareRateTemplate: '{percent}٪ از درآمدها',
    addTransaction: 'ثبت تراکنش',
    transactionsLabel: 'تراکنش‌ها',
    noTransactionsTitle: 'هنوز تراکنشی ثبت نشده',
    noTransactionsSubtitle: 'اولین درآمد یا هزینه را با «ثبت تراکنش» اضافه کنید',
    transactionType: 'نوع تراکنش',
    incomeTypeLabel: 'درآمد',
    expenseTypeLabel: 'هزینه',
    categoryLabel: 'دسته‌بندی',
    amountLabel: 'مبلغ (تومان)',
    amountRequired: 'مبلغ را وارد کنید',
    dateLabel: 'تاریخ',
    clientOptionalLabel: 'مشتری (اختیاری)',
    noClientSelected: 'بدون مشتری',
    deleteTransactionTitle: 'حذف تراکنش',
    deleteTransactionMessage: 'این تراکنش حذف شود؟',
    transactionSaved: 'تراکنش ذخیره شد',
    transactionDeleted: 'تراکنش حذف شد',
    editTransaction: 'ویرایش تراکنش',
    transactionUpdated: 'تراکنش به‌روزرسانی شد',
    incomeCategoryPlan: 'برنامه',
    incomeCategoryOther: 'سایر',
    expenseCategoryRent: 'اجاره',
    expenseCategorySalary: 'حقوق و دستمزد',
    expenseCategoryEquipment: 'تجهیزات',
    gymShareSettingTitle: 'سهم باشگاه',
    gymShareSettingHint: 'درصدی از درآمدها که به باشگاه تعلق می‌گیرد',
    planPriceLabel: 'قیمت برنامه (تومان)',
    planPriceHint: 'اگر بیشتر از صفر باشد، هنگام ثبت برنامه یک تراکنش درآمدِ «برنامه» خودکار ثبت می‌شود.',
    planShareLabel: 'سهم باشگاه (٪)',
    perPlanShareTitle: 'سهم برنامه‌ها',
    planPriceDialogTitle: 'قیمت برنامه',
    planPriceSaved: 'قیمت برنامه ثبت شد',
    setPlanPrice: 'ثبت قیمت',
    shareRateTemplate: '{percent}٪',
    remainingDaysTemplate: '{count} روز باقی‌مانده',
    gymShareDeductionTemplate: 'سهم باشگاه: {amount}',
    netIncomeLabel: 'سود خالص',
    openReports: 'گزارش‌ها',
    reportsTitle: 'گزارش درآمد و هزینه',
    weeklyLabel: 'هفتگی',
    monthlyLabel: 'ماهانه',
    yearlyLabel: 'سالانه',
    monthlyChartTitle: 'روند درآمد ماهانه (۱۲ ماه اخیر)',
    weeklyChartTitle: 'درآمد هفت روز اخیر',
    noReportsTitle: 'هنوز گزارشی برای نمایش نیست',
    noReportsSubtitle: 'با ثبت تراکنش‌ها، روند درآمد و هزینه این‌جا نمایش داده می‌شود',
    settingsTitle: 'تنظیمات',
    trainerInfo: 'اطلاعات مربی',
    trainerNameLabel: 'نام مربی',
    saveName: 'ذخیره نام',
    appearance: 'ظاهر برنامه',
    themeLabel: 'تم برنامه',
    themeSystem: 'سیستم',
    themeLight: 'روشن',
    themeDark: 'تیره',
    accentColorLabel: 'رنگ اصلی',
    accentGreen: 'سبز',
    accentBlue: 'آبی',
    accentPurple: 'بنفش',
    accentRose: 'صورتی',
    accentOrange: 'نارنجی',
    accentTeal: 'فیروزه‌ای',
    languageLabel: 'زبان',
    languageFa: 'فارسی',
    languageEn: 'English',
    devTools: 'ابزار توسعه',
    devToolsDescription: 'چند مشتری، قالب، برچسب و دو هفته حضور و غیاب اضافه می‌کند تا داشبورد، برنامه‌ها و مصرف جلسات بررسی شود.',
    seedDemoData: 'افزودن داده نمونه',
    databaseFailedTitle: 'راه‌اندازی پایگاه داده ناموفق بود',
    dashboardTitle: 'تقویم حرفه‌ای',
    totalClients: 'تعداد مشتریان',
    expiredPlans: 'پایان‌یافته',
    frozenPlans: 'متوقف',
    queuedPlans: 'در صف',
    todayAttendance: 'حضور امروز',
    noAttendanceYet: 'هنوز چیزی ثبت نشده',
    noAttendanceSubtitle: 'برای مشتریان مورد نظر حضور یا غیاب ثبت کنید',
    noClientsTitle: 'هنوز مشتری‌ای اضافه نشده',
    noClientsSubtitle: 'برای شروع اولین مشتری را اضافه کنید',
    present: 'حاضر',
    absent: 'غایب',
    lowSessionPlans: 'برنامه‌های رو به اتمام',
    viewClients: 'مشاهده مشتریان',
    sessionsLeft: 'جلسه باقی‌مانده',
    addClient: 'افزودن مشتری',
    registerPresent: 'ثبت حضور',
    registerAbsent: 'ثبت غیبت',
    unmarked: 'ثبت نشده',
    undoAttendance: 'حذف ثبت',
    contactInfo: 'اطلاعات تماس',
    phoneNumber: 'شماره تلفن',
    note: 'یادداشت',
    notProvided: 'وارد نشده',
    bonusSessionsLabel: 'جلسات اضافه',
    activePlans: 'برنامه‌های فعال',
    addPlan: 'افزودن برنامه',
    planProgress: 'پیشرفت برنامه',
    attendanceLabel: 'حضور و غیاب',
    planNotFound: 'برنامه‌ای یافت نشد',
    clientNotFound: 'مشتری یافت نشد',
    freeze: 'متوقف',
    activate: 'فعال‌سازی',
    deletePlan: 'حذف برنامه',
    deletePlanMessage: 'این برنامه حذف شود؟',
    deleteClientTitle: 'حذف مشتری',
    statusActive: 'فعال',
    statusFrozen: 'متوقف',
    statusQueued: 'در صف',
    statusExpired: 'پایان‌یافته',
    searchHint: 'جستجوی مشتری...',
    allLabel: 'همه',
    sortBy: 'مرتب‌سازی',
    sortName: 'نام',
    sortNewest: 'جدیدترین',
    sortBonus: 'جلسات اضافه',
    noResults: 'نتیجه‌ای یافت نشد',
    noResultsSubtitle: 'عبارت دیگری را جستجو کنید',
    clientsTitle: 'مشتریان',
    emptyClientsTitle: 'هنوز مشتری‌ای اضافه نشده',
    emptyClientsSubtitle: 'برای شروع اولین مشتری را اضافه کنید',
    addClientFab: 'افزودن مشتری',
    sortSheetTitle: 'مرتب‌سازی مشتریان',
    sortByName: 'بر اساس نام',
    sortByNewest: 'بر اساس تاریخ افزودن',
    sortByBonusSessions: 'بر اساس جلسات اضافه',
    confirmDeleteClient: 'آیا از حذف «{name}» اطمینان دارید؟',
    tapToOpenProfile: 'مشاهده پروفایل',
    openAttendance: 'مشاهده حضور و غیاب',
    editClient: 'ویرایش مشتری',
    deleteClient: 'حذف مشتری',
    activePlansTab: 'فعال',
    expiredPlansTab: 'پایان‌یافته‌ها',
    noPlansYet: 'هنوز برنامه‌ای تنظیم نشده',
    planTemplateLabel: 'قالب',
    sessionStatusTitle: 'وضعیت جلسات',
    activePlanRemainingLabel: 'جلسات باقی‌مانده برنامه فعال',
    noActivePlanLabel: 'برنامه فعالی نیست',
    queuedPlansLabel: 'برنامه‌های در صف',
    recordedSessionsLabel: 'جلسات ثبت‌شده',
    quickAddToday: 'ثبت سریع امروز',
    bonusSessions: 'جلسات هدیه',
    attendanceHistory: 'سوابق ثبت شده',
    noHistoryYet: 'هنوز سابقه‌ای ثبت نشده',
    noHistorySubtitle: 'روی روزهای تقویم بزنید یا از «ثبت سریع امروز» استفاده کنید',
    deleteSession: 'حذف و بازگشت جلسه',
    plansSection: 'برنامه‌ها',
    bonusSessionCountTemplate: '{count} جلسه اضافه',
    bonusAdded: 'جلسه هدیه اضافه شد',
    bonusRemoved: 'جلسه هدیه حذف شد',
    noClientsWithTag: 'مشتری‌ای با این برچسب نیست',
    tagsSection: 'برچسب‌ها',
    addTag: 'افزودن برچسب',
    noTagsDefined: 'هنوز برچسبی ساخته نشده',
    pageNotFound: 'صفحه مورد نظر پیدا نشد',
    templatesTitle: 'قالب‌های برنامه',
    noTemplatesTitle: 'قالبی تعریف نشده',
    noTemplatesSubtitle: 'برای شروع اولین قالب را ایجاد کنید',
    addTemplate: 'قالب جدید',
    usedByCountTemplate: '{count} مورد استفاده',
    deleteTemplateTitle: 'حذف قالب',
    deleteTemplateMessageTemplate: 'آیا از حذف "{name}" اطمینان دارید؟',
    sessionsCountTemplate: '{count} جلسه',
    daysCountTemplate: '{count} روز',
    oneSessionPerDaysTemplate: 'هر {days} روز یک جلسه',
    newTag: 'برچسب جدید',
    editTagTitle: 'ویرایش برچسب',
    deleteTagTitle: 'حذف برچسب',
    deleteTagMessageTemplate: 'آیا از حذف "{name}" اطمینان دارید؟',
    tagNameLabel: 'نام برچسب',
    emojiOptionalLabel: 'ایموجی (اختیاری)',
    colorLabel: 'رنگ: ',
    tagClientCountTemplate: '{count} مشتری',
    noTagsDefinedSubtitle: 'برای سازماندهی مشتریان برچسب ایجاد کنید',
    manageTags: 'مدیریت برچسب‌ها',
    clientActionsTitle: 'گزینه‌های مشتری',
    backupSection: 'پشتیبان‌گیری و خروجی',
    backupDescription: 'از داده‌ها فایل پشتیبان بسازید یا فایل CSV برای اکسل بگیرید. هنگام ورود، ابتدا داده‌ها ادغام می‌شوند و در صورت نیاز می‌توانید همه را جایگزین کنید.',
    exportBackupJson: 'خروجی پشتیبان (JSON)',
    importBackupJson: 'ورود پشتیبان (JSON)',
    exportCsv: 'خروجی CSV',
    csvClients: 'مشتریان',
    csvPlans: 'برنامه‌ها',
    lastBackupLabel: 'آخرین پشتیبان‌گیری',
    lastBackupNever: 'هنوز پشتیبان نگرفته‌اید',
    lastBackupOnTemplate: 'آخرین پشتیبان: {date}',
    daysAgoTemplate: '{days} روز پیش',
    backupReminderNeverBody:
        'اطلاعات شما فقط روی همین گوشی ذخیره شده است. با یک فایل پشتیبان می‌توانید همه‌چیز را روی دستگاه دیگری برگردانید.',
    backupReminderDueTitleTemplate: '{days} روز از آخرین پشتیبان‌گیری گذشته است',
    backupReminderGo: 'پشتیبان‌گیری',
    backupReminderLater: 'بعداً',
    csvAttendance: 'حضور و غیاب',
    csvTransactions: 'تراکنش‌ها',
    backupSavedTemplate: 'فایل ذخیره شد: {file}',
    backupFailedTemplate: 'ذخیره فایل ناموفق بود: {error}',
    importTitle: 'ورود پشتیبان',
    importHint: 'محتوای فایل پشتیبان (JSON) را اینجا بچسبانید',
    chooseFile: 'انتخاب فایل',
    pasteFromClipboard: 'چسباندن از حافظه',
    mergeData: 'ادغام با داده موجود',
    replaceData: 'جایگزینی کامل',
    mergeHint: 'موارد جدید اضافه می‌شوند و اطلاعات فعلی حفظ می‌گردد.',
    replaceWarning: 'هشدار: همه مشتریان، برنامه‌ها و سوابق فعلی پاک و با فایل پشتیبان جایگزین می‌شوند.',
    importInvalid: 'محتوای پشتیبان معتبر نیست',
    importSummaryTemplate: 'این فایل شامل {clients} مشتری، {plans} برنامه و {attendance} رکورد حضور است.',
    importDoneTemplate: 'ورود انجام شد: {count} مورد اضافه شد',
    replaceConfirmTitle: 'جایگزینی اطلاعات',
    replaceConfirmMessage: 'تمام اطلاعات فعلی حذف و با محتوای پشتیبان جایگزین می‌شود. ادامه می‌دهید؟',
    importFailedTemplate: 'ورود ناموفق بود: {error}',
    safetyCopySavedTemplate: 'پیش از جایگزینی، نسخه پشتیبان اطلاعات فعلی در فایل {file} ذخیره شد.',
    safetyCopyFailed: 'جایگزینی انجام نشد: ذخیره نسخه پشتیبان اطلاعات فعلی ممکن نبود.',
    noBackupContent: 'ابتدا محتوای پشتیبان را وارد کنید',
    selectPlanTemplate: 'انتخاب قالب برنامه',
    approximateEndTemplate: 'پایان تقریبی دوره: {date}',
    chooseThisTemplate: 'انتخاب این قالب',
    chooseStartDate: 'انتخاب تاریخ شروع',
    confirmDate: 'تأیید تاریخ',
    reviewStartDate: 'بررسی تاریخ شروع',
    startDateLabel: 'تاریخ شروع',
    endDateLabel: 'تاریخ پایان',
    sessionsLabel: 'تعداد جلسات',
    queuedPlanWarning: 'این مشتری برنامه فعال دارد؛ برنامه جدید «در صف» ثبت می‌شود و تاریخ شروع آن هنگام فعال شدن به‌روز می‌شود.',
    confirmStartDateMessage: 'مطمئنید تاریخ شروع را درست انتخاب کرده‌اید؟',
    yesSavePlan: 'بله، ثبت شود',
    planAddedWithStartTemplate: 'برنامه اضافه شد (شروع: {date})',
    change: 'تغییر',
    todayLabel: 'امروز',
    prevMonth: 'ماه قبل',
    nextMonth: 'ماه بعد',
    retryLabel: 'تلاش مجدد',
    templateNameLabel: 'نام قالب *',
    templateSessionsLabel: 'تعداد جلسات *',
    templateDaysLabel: 'تعداد روزها *',
    templateNameRequired: 'نام قالب الزامی است',
    templateInvalidNumbers: 'جلسات و روزها باید عدد صحیح و بزرگتر از صفر باشند',
    editTemplateTitle: 'ویرایش قالب',
    clientNameRequired: 'نام مشتری الزامی است',
    clientNameLabel: 'نام *',
    contactLabel: 'شماره تماس',
    activePlanFallback: 'برنامه فعال',
    deleteSessionMessage: 'این جلسه حذف شود؟ جلسه مصرف‌شده به برنامه یا جلسات هدیه بازگردانده می‌شود.',
  );



  static const en = AppStrings(
    isPersian: false,
    welcomeTemplate: 'Welcome back, {name}',
    bonusClientsTemplate: '{count} client with bonus sessions',
    remainingSessionsTemplate: '{count} sessions left',
    clientsWithBonusTemplate: '{count} bonus sessions',
    remainingDetailTemplate: '{remaining} of {sessions} sessions',
    deleteClientMessageTemplate: 'Delete «{name}»? Plans and attendance history will also be deleted.',
    attendanceCountTemplate: '{status} ×{count}',
    recordAddedTemplate: '{status} recorded · {date}',
    recordRemovedTemplate: 'Record for {date} removed',
    clientDeletedTemplate: '{name} deleted',
    ok: 'OK',
    yes: 'Yes',
    no: 'No',
    cancel: 'Cancel',
    confirm: 'OK',
    delete: 'Delete',
    edit: 'Edit',
    save: 'Save',
    saved: 'Saved',
    errorPrefix: 'Error: ',
    loading: 'Loading...',
    appTitle: 'Pro Calendar',
    navDashboard: 'Dashboard',
    navClients: 'Clients',
    navTemplates: 'Templates',
    navTags: 'Tags',
    navSettings: 'Settings',
    navAccounting: 'Accounting',
    totalIncome: 'Total income',
    totalExpense: 'Total expense',
    balanceLabel: 'Balance',
    gymShareLabel: 'Gym share',
    gymShareRateTemplate: '{percent}% of income',
    addTransaction: 'Add transaction',
    transactionsLabel: 'Transactions',
    noTransactionsTitle: 'No transactions yet',
    noTransactionsSubtitle: 'Add your first income or expense with “Add transaction”',
    transactionType: 'Type',
    incomeTypeLabel: 'Income',
    expenseTypeLabel: 'Expense',
    categoryLabel: 'Category',
    amountLabel: 'Amount (toman)',
    amountRequired: 'Enter an amount',
    dateLabel: 'Date',
    clientOptionalLabel: 'Client (optional)',
    noClientSelected: 'No client',
    deleteTransactionTitle: 'Delete transaction',
    deleteTransactionMessage: 'Delete this transaction?',
    transactionSaved: 'Transaction saved',
    transactionDeleted: 'Transaction deleted',
    editTransaction: 'Edit transaction',
    transactionUpdated: 'Transaction updated',
    incomeCategoryPlan: 'Plan',
    incomeCategoryOther: 'Other',
    expenseCategoryRent: 'Rent',
    expenseCategorySalary: 'Salary',
    expenseCategoryEquipment: 'Equipment',
    gymShareSettingTitle: 'Gym share percent',
    gymShareSettingHint: 'Percent of income owed to the gym',
    planPriceLabel: 'Plan price (toman)',
    planPriceHint: 'When above zero, an automatic “plan” income transaction is recorded when the plan is assigned.',
    planShareLabel: 'Gym share (%)',
    perPlanShareTitle: 'Per-plan share',
    planPriceDialogTitle: 'Plan price',
    planPriceSaved: 'Plan price saved',
    setPlanPrice: 'Set price',
    shareRateTemplate: '{percent}%',
    remainingDaysTemplate: '{count} days left',
    gymShareDeductionTemplate: 'Gym share: {amount}',
    netIncomeLabel: 'Net income',
    openReports: 'Reports',
    reportsTitle: 'Income & expense reports',
    weeklyLabel: 'Weekly',
    monthlyLabel: 'Monthly',
    yearlyLabel: 'Yearly',
    monthlyChartTitle: 'Monthly income trend (last 12 months)',
    weeklyChartTitle: 'Last 7 days income',
    noReportsTitle: 'Nothing to report yet',
    noReportsSubtitle: 'Add transactions to see income and expense trends here',
    settingsTitle: 'Settings',
    trainerInfo: 'Trainer info',
    trainerNameLabel: 'Trainer name',
    saveName: 'Save name',
    appearance: 'Appearance',
    themeLabel: 'App theme',
    themeSystem: 'System',
    themeLight: 'Light',
    themeDark: 'Dark',
    accentColorLabel: 'Accent color',
    accentGreen: 'Green',
    accentBlue: 'Blue',
    accentPurple: 'Purple',
    accentRose: 'Rose',
    accentOrange: 'Orange',
    accentTeal: 'Teal',
    languageLabel: 'Language',
    languageFa: 'فارسی',
    languageEn: 'English',
    devTools: 'Dev tools',
    devToolsDescription: 'Adds sample clients, templates, tags and two weeks of attendance so the dashboard, plans and session usage can be reviewed.',
    seedDemoData: 'Seed demo data',
    databaseFailedTitle: 'Database setup failed',
    dashboardTitle: 'Pro Calendar',
    totalClients: 'Total clients',
    expiredPlans: 'Expired',
    frozenPlans: 'Frozen',
    queuedPlans: 'Queued',
    todayAttendance: "Today's attendance",
    noAttendanceYet: 'Nothing recorded yet',
    noAttendanceSubtitle: 'Mark attendance for the clients you want',
    noClientsTitle: 'No clients yet',
    noClientsSubtitle: 'Add your first client to get started',
    present: 'Present',
    absent: 'Absent',
    lowSessionPlans: 'Low-session plans',
    viewClients: 'View clients',
    sessionsLeft: 'sessions left',
    addClient: 'Add client',
    registerPresent: 'Mark present',
    registerAbsent: 'Mark absent',
    unmarked: 'Unmarked',
    undoAttendance: 'Undo',
    contactInfo: 'Contact info',
    phoneNumber: 'Phone number',
    note: 'Note',
    notProvided: 'Not provided',
    bonusSessionsLabel: 'Bonus sessions',
    activePlans: 'Active plans',
    addPlan: 'Add plan',
    planProgress: 'Plan progress',
    attendanceLabel: 'Attendance',
    planNotFound: 'No plans found',
    clientNotFound: 'Client not found',
    freeze: 'Freeze',
    activate: 'Activate',
    deletePlan: 'Delete plan',
    deletePlanMessage: 'Delete this plan?',
    deleteClientTitle: 'Delete client',
    statusActive: 'Active',
    statusFrozen: 'Frozen',
    statusQueued: 'Queued',
    statusExpired: 'Expired',
    searchHint: 'Search clients...',
    allLabel: 'All',
    sortBy: 'Sort',
    sortName: 'Name',
    sortNewest: 'Newest',
    sortBonus: 'Bonus sessions',
    noResults: 'No results found',
    noResultsSubtitle: 'Try a different search term',
    clientsTitle: 'Clients',
    emptyClientsTitle: 'No clients yet',
    emptyClientsSubtitle: 'Add your first client to get started',
    addClientFab: 'Add client',
    sortSheetTitle: 'Sort clients',
    sortByName: 'By name',
    sortByNewest: 'By newest',
    sortByBonusSessions: 'By bonus sessions',
    confirmDeleteClient: 'Delete «{name}»?',
    tapToOpenProfile: 'View profile',
    openAttendance: 'View attendance',
    editClient: 'Edit client',
    deleteClient: 'Delete client',

    // Client detail plan section (active/expired tabs)
    activePlansTab: 'Active',
    expiredPlansTab: 'Expired',
    noPlansYet: 'No plan assigned yet',
    planTemplateLabel: 'Template',

    sessionStatusTitle: 'Session status',
    activePlanRemainingLabel: 'Remaining sessions (active plan)',
    noActivePlanLabel: 'No active plan',
    queuedPlansLabel: 'Queued plans',
    recordedSessionsLabel: 'Recorded sessions',
    quickAddToday: 'Quick add today',
    bonusSessions: 'Bonus sessions',
    attendanceHistory: 'Attendance history',
    noHistoryYet: 'No history yet',
    noHistorySubtitle: 'Tap days on the calendar or use quick add today',
    deleteSession: 'Refund & delete session',
    plansSection: 'Plans',
    bonusSessionCountTemplate: '{count} bonus sessions',
    bonusAdded: 'Bonus session added',
    bonusRemoved: 'Bonus session removed',
    noClientsWithTag: 'No clients with this tag',
    tagsSection: 'Tags',
    addTag: 'Add tag',
    noTagsDefined: 'No tags created yet',
    pageNotFound: 'Page not found',
    templatesTitle: 'Program templates',
    noTemplatesTitle: 'No templates yet',
    noTemplatesSubtitle: 'Create your first template to get started',
    addTemplate: 'New template',
    usedByCountTemplate: 'Used {count} times',
    deleteTemplateTitle: 'Delete template',
    deleteTemplateMessageTemplate: 'Delete "{name}"?',
    sessionsCountTemplate: '{count} sessions',
    daysCountTemplate: '{count} days',
    oneSessionPerDaysTemplate: 'One session every {days} days',
    newTag: 'New tag',
    editTagTitle: 'Edit tag',
    deleteTagTitle: 'Delete tag',
    deleteTagMessageTemplate: 'Delete "{name}"?',
    tagNameLabel: 'Tag name',
    emojiOptionalLabel: 'Emoji (optional)',
    colorLabel: 'Color: ',
    tagClientCountTemplate: '{count} clients',
    noTagsDefinedSubtitle: 'Create tags to organize your clients',
    manageTags: 'Manage tags',
    clientActionsTitle: 'Client actions',
    backupSection: 'Backup & export',
    backupDescription: 'Create a backup file or export CSV for Excel. Imports merge first; you can replace everything if needed.',
    exportBackupJson: 'Export backup (JSON)',
    importBackupJson: 'Import backup (JSON)',
    exportCsv: 'Export CSV',
    csvClients: 'Clients',
    csvPlans: 'Plans',
    csvAttendance: 'Attendance',
    csvTransactions: 'Transactions',
    backupSavedTemplate: 'File saved: {file}',
    backupFailedTemplate: 'Could not save file: {error}',
    lastBackupLabel: 'Last backup',
    lastBackupNever: 'No backup yet',
    lastBackupOnTemplate: 'Last backup: {date}',
    daysAgoTemplate: '{days} days ago',
    backupReminderNeverBody:
        'Your data is stored only on this phone. A backup file lets you restore everything on another device.',
    backupReminderDueTitleTemplate: '{days} days since your last backup',
    backupReminderGo: 'Back up',
    backupReminderLater: 'Later',
    importTitle: 'Import backup',
    importHint: 'Paste the backup file contents (JSON) here',
    chooseFile: 'Choose file',
    pasteFromClipboard: 'Paste from clipboard',
    mergeData: 'Merge with current data',
    replaceData: 'Replace everything',
    mergeHint: 'New rows are added; your current data is kept.',
    replaceWarning: 'Warning: all current clients, plans and attendance are deleted and replaced by the backup.',
    importInvalid: 'Not a valid backup file',
    importSummaryTemplate: 'This file has {clients} clients, {plans} plans and {attendance} attendance records.',
    importDoneTemplate: 'Import complete: {count} rows added',
    replaceConfirmTitle: 'Replace data',
    replaceConfirmMessage: 'All current data will be deleted and replaced by the backup. Continue?',
    importFailedTemplate: 'Import failed: {error}',
    noBackupContent: 'Enter the backup contents first',
    safetyCopySavedTemplate: 'Before replacing, your current data was saved to {file}.',
    safetyCopyFailed: 'Replace cancelled: a safety copy of your current data could not be saved.',
    selectPlanTemplate: 'Select plan template',
    approximateEndTemplate: 'Approximate end date: {date}',
    chooseThisTemplate: 'Choose this template',
    chooseStartDate: 'Choose start date',
    confirmDate: 'Confirm date',
    reviewStartDate: 'Check start date',
    startDateLabel: 'Start date',
    endDateLabel: 'End date',
    sessionsLabel: 'Number of sessions',
    queuedPlanWarning: 'This client already has an active plan. The new plan will be queued and its start date updated when it activates.',
    confirmStartDateMessage: 'Is the start date correct?',
    yesSavePlan: 'Yes, save it',
    planAddedWithStartTemplate: 'Plan added (start: {date})',
    change: 'Change',
    todayLabel: 'Today',
    prevMonth: 'Previous month',
    nextMonth: 'Next month',
    retryLabel: 'Try again',
    templateNameLabel: 'Template name *',
    templateSessionsLabel: 'Number of sessions *',
    templateDaysLabel: 'Number of days *',
    templateNameRequired: 'Template name is required',
    templateInvalidNumbers: 'Sessions and days must be whole numbers greater than zero',
    editTemplateTitle: 'Edit template',
    clientNameRequired: 'Client name is required',
    clientNameLabel: 'Name *',
    contactLabel: 'Phone number',
    activePlanFallback: 'Active plan',
    deleteSessionMessage: 'Remove this session? The used session is refunded to the plan or bonus sessions.',
  );
}
