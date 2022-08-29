import 'package:firebase_auth_refresh/bloc/auth_cubit.dart';
import 'package:firebase_auth_refresh/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "",
      authDomain: "",
      projectId: "",
      storageBucket: "",
      messagingSenderId: "",
      appId: "",
      measurementId: "",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Refresh',
      theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.amber,
        secondary: Colors.teal,
      )),
      home: BlocProvider(
          create: (_) => AuthCubit(),
          child: const HomePage(title: 'Flutter Auth Refresh')),
    );
  }
}
