import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mykuliner/providers/post_provider.dart'; // Pastikan Anda mengimpor provider yang benar
import 'package:mykuliner/screen/login_page.dart';
import 'package:mykuliner/screen/register_page.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => PostProvider()), // Inisialisasi PostProvider
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Auth',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(), // Memastikan LoginPage adalah halaman awal
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}
