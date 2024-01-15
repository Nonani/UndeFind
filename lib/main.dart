import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:undefind_project/presentation/screens/trash_map_screen.dart';
import 'package:undefind_project/presentation/view_models/trash_map_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // 1번코드
  await dotenv.load(fileName: "assets/.env");    // 2번코드
  AuthRepository.initialize(appKey: dotenv.env['APP_KEY'] ?? '');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrashMapViewModel()),
      ],
      child: MyApp(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TrashMapScreen(),
    );
  }
}
