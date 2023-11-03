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
          child: RealTimeWidget(),
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

    // suscribir para escuchar cambios en autenticación de usuario
    // design pattern - https://en.wikipedia.org/wiki/Observer_pattern
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("USUARIO: ${user.uid}");
      } else {
        print("SIN USUARIO!");
      }
    });

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
        TextButton(
            onPressed: () async {
              try {
                // singleton en uso práctico
                // https://en.wikipedia.org/wiki/Singleton_pattern
                final user = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: login.text, password: password.text);
                print("USUARIO CREADO: ${user.user?.uid}");
              } on FirebaseAuthException catch (e) {
                print(e.code);
                if (e.code == 'weak-password') {
                  print("PASSWORD MUY CHAFA.");
                } else if (e.code == 'email-already-in-use') {
                  print("YA TE REGISTRASTE");
                }
              }
            },
            child: const Text("Sign Up")),
        TextButton(
            onPressed: () async {
              try {
                final user = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: login.text, password: password.text);
                print("USUARIO LOGGEADO: ${user.user?.uid}");
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Log In")),
        TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Log Out")),
        TextButton(
            onPressed: () async {
              // vamos a definir un objeto que vamos a utilizar para definir
              // un nuevo documento en nuestra colección
              final perrito = <String, dynamic>{
                "nombre": "Killer",
                "raza": "Chihuahueño",
                "edad": 1.0
              };

              FirebaseFirestore.instance
                  .collection("perritos")
                  .add(perrito)
                  .then((DocumentReference documento) =>
                      print("nuevo doc: ${documento.id}"));
            },
            child: const Text("Add Record")),
        TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("perritos")
                  .get()
                  .then((value) {
                for (var doc in value.docs) {
                  print("doc actual: ${doc.data()}");
                }
              });
            },
            child: const Text("Query")),
      ],
    );
  }
}

class RealTimeWidget extends StatefulWidget {
  const RealTimeWidget({super.key});

  @override
  State<RealTimeWidget> createState() => _RealTimeWidgetState();
}

class _RealTimeWidgetState extends State<RealTimeWidget> {
  final Stream<QuerySnapshot> _perritosStream =
      FirebaseFirestore.instance.collection("perritos").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _perritosStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("ERROR AL HACER QUERY, FAVOR DE VERIFICAR");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.docs
              .map((DocumentSnapshot doc) {
                Map<String, dynamic> docActual =
                    doc.data()! as Map<String, dynamic>;

                return ListTile(
                  title: Text(docActual['nombre']),
                  subtitle: Text(docActual['raza']),
                );
              })
              .toList()
              .cast(),
        );
      },
    );
  }
}
