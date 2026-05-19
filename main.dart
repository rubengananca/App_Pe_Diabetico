import 'package:app_pe_diabetico/articles/adequate_shoes.dart';
import 'package:app_pe_diabetico/articles/alert_signals.dart';
import 'package:app_pe_diabetico/articles/emergency_tips.dart';
import 'package:app_pe_diabetico/articles/foot_care.dart';
import 'package:app_pe_diabetico/articles/neuropathy_article.dart';
import 'package:app_pe_diabetico/articles/weekly_examination.dart';
import 'package:app_pe_diabetico/forms/link_user_practitioner.dart';
import 'package:app_pe_diabetico/forms/well_being.dart';
import 'package:app_pe_diabetico/pages_inside/camera.dart';
import 'package:app_pe_diabetico/home.dart';
import 'package:app_pe_diabetico/login.dart';
import 'package:app_pe_diabetico/pages_inside/change_password.dart';
import 'package:app_pe_diabetico/pages_inside/explore.dart';
import 'package:app_pe_diabetico/pages_inside/messages.dart';
import 'package:app_pe_diabetico/pages_inside/practitioner_codes.dart';
import 'package:app_pe_diabetico/forgot_password.dart';
import 'package:app_pe_diabetico/pages_inside/reauthentication_page.dart';
import 'package:app_pe_diabetico/reports/blood_pressure_reports.dart';
import 'package:app_pe_diabetico/reports/glicose_reports.dart';
import 'package:app_pe_diabetico/reports/well_being_reports.dart';
import 'package:app_pe_diabetico/statistics/statistics_blood_pressure_page.dart';
import 'package:app_pe_diabetico/statistics/statistics_glicose_page.dart';
import 'package:app_pe_diabetico/statistics/statistics_well_being_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/pages_inside/galery.dart';
import 'package:app_pe_diabetico/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:app_pe_diabetico/services/auth_verification.dart';
import 'package:app_pe_diabetico/services/main_screen.dart';
import 'package:app_pe_diabetico/forms/glicose_forms.dart';
import 'package:app_pe_diabetico/forms/blood_pressure.dart';
import 'package:app_pe_diabetico/pages_inside/images_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:permission_handler/permission_handler.dart";
import 'package:app_pe_diabetico/services/notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_pe_diabetico/services/user_presence.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final _notifications = Notifications(flutterLocalNotificationsPlugin);


Future<void> _requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await _requestNotificationPermission();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Pede permissões no iOS
  NotificationSettings settings = await messaging.requestPermission();

  final UserPresence _userPresence = UserPresence();
  await _userPresence.setupFirebaseMessaging();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // verifica se há payload
      if (response.payload == 'main') {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/main',
              (route) => false,
        );
      }
    },
  );


  runApp(
      MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale("pt","PT")
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AuthVerification(),
        routes: {
          //"/": (context) => Home(),
          "/home": (context) => Home(),
          "/register": (context) => Register(),
          "/login": (context) => LoginPage(),
          "/forgot_password_page": (context) => ForgotPasswordPage(),
          "/change_password": (context) => ChangePassword(),
          "/reauthentication_page": (context) => ReauthenticationPage(),
          "/main": (context) => MainScreen(),
          "/camera": (context) => CameraPage(),
          "/galery": (context) => Galery(),
          "/explore": (context) => Explore(),

          "/messages": (context) => MessagesPage(),

          "/glicose_monitoring": (context) => GlicoseForms(),
          "/bpm_monitoring" : (context) => BloodPressure(),
          "/well_being": (context) => WellBeing(),

          "/image_page": (context) => ImagesPage(),
          "/practitioner_list": (context) => PractitionerCodesPage(),
          "/link_user_practitioner": (context) => LinkUserPractitionerPage(),

          "/foot_care": (context) => FootCarePage(),
          "/adequate_shoes": (context) => AdequateShoesPage(),
          "/alert_signals": (context) => AlertSignals(),
          "/foot_examination": (context) => WeeklyExamination(),
          "/neuropathy_article": (context) => NeuropathyArticle(),
          "/emergency_tips": (context) => EmergencyTips(),

          "/glicose_reports": (context) => GlicoseReports(),
          "/bpm_reports": (context) => BloodPressureReports(),
          "/well_being_reports": (context) => WellBeingReports(),

          "/glicose_statistics": (context) => StatisticsGlicosePage(),
          "/blood_pressure_statistics": (context) => StatisticsBloodPressurePage(),
          "/well_being_statistics": (context) => StatisticsWellBeingPage(),

        },
      )
  );
}
