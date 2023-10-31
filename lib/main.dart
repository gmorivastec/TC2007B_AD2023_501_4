import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// install firebase cli - https://firebase.google.com/docs/cli
// dart pub global activate flutterfire_cli
// flutter pub add firebase_core
// flutter pub add firebase_auth
// flutter pub add cloud_firestore
// fluterfire configure

// como va a haber lógica asíncrona necesitamos código
// que sea capaz de procesarla
Future<void> main() async {
  // como firebase utiliza bindings nativos es necesario
  // asegurarse que etán listos

  WidgetsFlutterBinding.ensureInitialized();

  // una vez que sabemos que el binding está listo inicializamos firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: LoginWidget(),
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    // 1ero - vamos a agregar controllers que serán utilizados por widgets
    TextEditingController login = TextEditingController();
    TextEditingController password = TextEditingController();

    setState(() {
      login.text = "";
      password.text = "";
    });

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Login",
              ),
              controller: login,
            )),
        Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Password",
            ),
            controller: password,
            obscureText: true,
          ),
        ),
        TextButton(onPressed: () {}, child: const Text("Sign Up")),
        TextButton(onPressed: () {}, child: const Text("Log In")),
        TextButton(onPressed: () {}, child: const Text("Log Out")),
        TextButton(onPressed: () {}, child: const Text("Add Record")),
        TextButton(onPressed: () {}, child: const Text("Query")),
      ],
    );
  }
}
