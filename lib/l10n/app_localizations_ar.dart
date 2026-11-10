// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'صيدليتي';

  @override
  String get appTagline => 'ابحث عن أقرب صيدلية مفتوحة';

  @override
  String get nearbyPharmacies => 'الصيدليات القريبة';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'ابحث عن صيدلية أو حي...';

  @override
  String get openNow => 'مفتوحة الآن';

  @override
  String get closed => 'مغلقة';

  @override
  String get open24h => 'مفتوحة 24/7';

  @override
  String get hoursUnknown => 'ساعات العمل غير معروفة';

  @override
  String get getDirections => 'الحصول على الاتجاهات';

  @override
  String get call => 'اتصال';

  @override
  String get distance => 'المسافة';

  @override
  String get km => 'كم';

  @override
  String get m => 'م';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noResults => 'لم يتم العثور على صيدليات';

  @override
  String get locationDenied => 'تم رفض إذن الموقع. يرجى تفعيله من الإعدادات.';

  @override
  String get enableLocation => 'تفعيل الموقع';

  @override
  String get locationFallback =>
      'الموقع الافتراضي (الجزائر العاصمة). فعّل GPS للنتائج القريبة.';

  @override
  String get activateGps => 'تفعيل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get french => 'الفرنسية';

  @override
  String get arabic => 'العربية';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get address => 'العنوان';

  @override
  String get phone => 'الهاتف';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get rating => 'التقييم';

  @override
  String get pharmacyOnDuty => 'صيدلية المناوبة';

  @override
  String get yourLocation => 'موقعك';

  @override
  String get searchArea => 'ابحث في هذه المنطقة';

  @override
  String get filter => 'تصفية';

  @override
  String get all => 'الكل';

  @override
  String get openOnly => 'المفتوحة فقط';

  @override
  String directionsTo(String name) {
    return 'الاتجاهات إلى $name';
  }

  @override
  String get errorOccurred => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get poweredBy => 'مدعوم من OpenStreetMap';

  @override
  String get madeWith => 'صُنع بحب في الجزائر';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get searchRadius => 'نطاق البحث';

  @override
  String radiusKm(String km) {
    return '$km كم';
  }

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavorites => 'لا توجد مفضلات بعد. اضغط على القلب لحفظ صيدلية.';

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get clearRecent => 'مسح';

  @override
  String get wheelchairAccess => 'إمكانية الوصول للكراسي المتحركة';

  @override
  String get wheelchairYes => 'متاح';

  @override
  String get wheelchairNo => 'غير متاح';

  @override
  String get wheelchairLimited => 'وصول محدود';

  @override
  String get wheelchairUnknown => 'غير معروف';

  @override
  String get noMapsApp => 'لا يوجد تطبيق خرائط متاح';

  @override
  String pharmaciesCount(int count) {
    return '$count صيدليات';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get addFavorite => 'إضافة إلى المفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get operator => 'المشغّل';

  @override
  String get dataSource => 'بيانات الخريطة © مساهمو OpenStreetMap';

  @override
  String get unnamedPharmacy => 'صيدلية';

  @override
  String get noOpenNearby =>
      'لا توجد صيدليات مفتوحة قريبة. أوقف «المفتوحة فقط» أو وسّع نطاق البحث.';

  @override
  String get showAllPharmacies => 'عرض الكل';

  @override
  String get copied => 'تم النسخ';

  @override
  String get share => 'مشاركة';

  @override
  String sharePharmacyText(
      String name, String address, String lat, String lng) {
    return '$name\n$address\nhttps://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng';
  }

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get copyAddress => 'نسخ العنوان';

  @override
  String get copyPhone => 'نسخ الهاتف';

  @override
  String get includeUnknownHours => 'تضمين الساعات غير المعروفة';

  @override
  String get includeUnknownHoursSubtitle =>
      'مع «المفتوحة فقط»، أظهر أيضاً الصيدليات بدون ساعات عمل';

  @override
  String get filters => 'عوامل التصفية';

  @override
  String get shareFailed => 'تعذّرت المشاركة';
}
