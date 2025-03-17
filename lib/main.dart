import 'package:blockchain_messenger/models/chat_provider_model.dart';
import 'package:blockchain_messenger/models/friend_list_management.dart';
import 'package:flutter/material.dart';
import 'package:blockchain_messenger/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blockchain_messenger/screens/welcome_page.dart';

void main() async {
  // SharedPreferences를 불러옴
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // 저장된 로그인 상태를 확인하고 로그인이 되어있으면 홈페이지로 이동
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  Widget homePage = isLoggedIn ? HomePage() : WelcomePage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FriendListModel()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        // 다른 프로바이더들을 여기에 추가
      ],
      child:MyApp(homePage: homePage),
    ),
  );
  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.homePage}) : super(key: key);

  final Widget homePage;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blockchain Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: homePage,
      ),
    );
  }
}
