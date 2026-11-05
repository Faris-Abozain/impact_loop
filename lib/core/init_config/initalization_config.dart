import 'package:impact_loop/app_bloc_observer.dart';
import 'package:impact_loop/core/exports.dart';
import 'package:impact_loop/core/notification_services/notification_service.dart';
import 'package:impact_loop/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:impact_loop/injector.dart' as injector;
import '../preferences/preferences.dart';

Future<void> initializationClass() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is initialized only when firebase_options.dart is configured
  // (run `flutterfire configure` to fill in the keys).
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.isNotEmpty && options.appId.isNotEmpty) {
      await Firebase.initializeApp(options: options);
    }
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  NotificationService notificationService = NotificationService();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  AndroidOptions getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  IOSOptions getIOSOptions() =>
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  prefs = await SharedPreferences.getInstance();
  // Ensure default locale is 'ar' (Arabic) by default
  final currentLocale = prefs.getString('locale');
  if (currentLocale == null || (currentLocale != 'ar' && currentLocale != 'en')) {
    await prefs.setString('locale', 'ar');
    await prefs.setString(AppStrings.locale, 'ar');
  }

  secureStorage = FlutterSecureStorage(
      aOptions: getAndroidOptions(), iOptions: getIOSOptions());
  await notificationService.initialize();

  await injector.setupDependencyInjection();
  await injector.setupCubit();
  await injector.setupRepo();
  Bloc.observer = AppBlocObserver();
}
