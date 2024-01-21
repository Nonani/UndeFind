import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:undefind_project/presentation/screens/home_screen.dart';
import 'package:undefind_project/presentation/screens/navi_map_screen.dart';
import 'package:undefind_project/presentation/screens/splash_screen.dart';
import 'package:undefind_project/presentation/screens/trash_map_screen.dart';
import 'package:undefind_project/presentation/view_models/trash_map_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'firebase_options.dart';

void main() async {
  Logger logger = Logger();
  HttpOverrides.global = MyHttpOverrides(); // http 인증서 오류 해결
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env"); // 2번코드
  AuthRepository.initialize(appKey: dotenv.env['APP_KEY'] ?? '');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: dotenv.env['VAPID_KEY'] ?? "");
  logger.w(fcmToken);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    logger.w('Got a message whilst in the foreground!');
    logger.w('Message data: ${message.data}');
    if (message.notification != null) {
      logger.w('Message also contained a notification: ${message.notification}');
    }
  });
  logger.w('main start');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrashMapViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.white,
          hintColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            color: Colors.white,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        home: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 3), () => "Intro Completed."),
          builder: (context, snapshot) {
            return AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: _splashLoadingWidget(snapshot)
            );
          },
        )
    );
  }

  Widget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
    if(snapshot.hasError) {
      return const Text("Error!!");
    } else if(snapshot.hasData) {
      return const HomeScreen();
    } else {
      return const SplashScreen();
    }
  }
}
// Define a top-level handler for background/terminated messages.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger logger = Logger();
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  logger.w('Handling a background message: ${message.messageId}');
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
