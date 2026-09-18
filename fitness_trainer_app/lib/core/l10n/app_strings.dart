import 'package:flutter/material.dart';
import '../utils/persian_numbers.dart';

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
  final String viewProfile;
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
    required this.settingsTitle,
    required this.trainerInfo,
    required this.trainerNameLabel,
    required this.saveName,
    required this.appearance,
    required this.themeLabel,
    required this.themeSystem,
    required this.themeLight,
    required this.themeDark,
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
    required this.viewProfile,
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
    settingsTitle: 'تنظیمات',
    trainerInfo: 'اطلاعات مربی',
    trainerNameLabel: 'نام مربی',
    saveName: 'ذخیره نام',
    appearance: 'ظاهر برنامه',
    themeLabel: 'تم برنامه',
    themeSystem: 'سیستم',
    themeLight: 'روشن',
    themeDark: 'تیره',
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
    viewProfile: 'مشاهده پروفایل',
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
    settingsTitle: 'Settings',
    trainerInfo: 'Trainer info',
    trainerNameLabel: 'Trainer name',
    saveName: 'Save name',
    appearance: 'Appearance',
    themeLabel: 'App theme',
    themeSystem: 'System',
    themeLight: 'Light',
    themeDark: 'Dark',
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
    viewProfile: 'View profile',
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
  );
}
