import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/authentication/auth_service.dart';
import 'package:todo/service/task_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskService(),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData) return Homepage();
            return LoginPage();
          },
        ),
        routes: {'/home': (_) => Homepage(), '/login': (_) => LoginPage()},
      ),
    );
  }
}
