import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'db_helper.dart';
/*
void main() {
  runApp(const MyApp());
}*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final user = await DBHelper.getUser();

  runApp(MyApp(isLoggedIn: user != null));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contrôle de présences',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: isLoggedIn
          ? AccueilPage()
          : const MyHomePage(title: 'Page de connexion'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    Future<void> login() async {
      final email = emailController.text.trim();
      final password = passwordController.text;
      if(email.isEmpty || password.isEmpty){
        Fluttertoast.showToast(
          msg: "Données incompletes",
          toastLength: Toast.LENGTH_SHORT, // ou Toast.LENGTH_LONG
          gravity: ToastGravity.BOTTOM, // ou TOP, CENTER
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else{
        print("Infos de connexion :$email $password");
        final url = Uri.parse('https://api-control.nash-project.name/api/auth/login');

        try {

          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            Fluttertoast.showToast(
              msg: "Connexion réussie :  ${data['nom']} ${data['prenom']} (${data['role']})",
              toastLength: Toast.LENGTH_SHORT, // ou Toast.LENGTH_LONG
              gravity: ToastGravity.BOTTOM, // ou TOP, CENTER
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            print("Connexion réussie !");
            print(data);
            await DBHelper.insertUser({
              'nom': data['nom'],
              'prenom': data['prenom'],
              'email': data['email'],
              'role': data['role'], // si tu veux vraiment stocker le hash
              'token': data['token'],
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccueilPage()),
            );
          } else {
            final data = jsonDecode(response.body);
            Fluttertoast.showToast(
              msg: "Erreur : ${data['message']}",
              toastLength: Toast.LENGTH_SHORT, // ou Toast.LENGTH_LONG
              gravity: ToastGravity.BOTTOM, // ou TOP, CENTER
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            print("Erreur : ${response.statusCode}");
            print(data);
          }
        } catch (e) {
          print("Échec de la connexion: $e");
          Fluttertoast.showToast(
            msg: "Échec de la connexion: $e",
            toastLength: Toast.LENGTH_SHORT, // ou Toast.LENGTH_LONG
            gravity: ToastGravity.BOTTOM, // ou TOP, CENTER
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }




    }

    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),

      body: SingleChildScrollView(
        //width: double.infinity,
        child: Column(
          children: [
            Container(
              color: Colors.red,
              margin: EdgeInsets.all(20),
              child: Image.asset("images/logo.png"),
            ),
            Container(
              height: 300,
              margin: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Identifiant',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mot de passe',
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              color: Colors
                                  .blue, // ou n'importe quelle couleur de lien
                              decoration:
                                  TextDecoration.underline, // pour souligner
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: login,
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.blue, // Couleur de fond du bouton
                            padding: EdgeInsets.symmetric(
                              // Espace interne
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              // Coins arrondis (optionnel)
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Colors.black,
                              backgroundColor: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AccueilPage extends StatefulWidget  {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  Map<String, dynamic>? utilisateur;

  @override
  void initState() {
    super.initState(); // Appelé une seule fois au début
    _chargerUtilisateur(); // Appelle ta fonction async ici
  }

  Future<void> _chargerUtilisateur() async {
    final user = await DBHelper.getUtilisateurLocal();
    setState(() {
      utilisateur = user;
    });
  }


  @override
  Widget build(BuildContext context) {

    Future<void> logout() async {
      Fluttertoast.showToast(
        msg: "Deconnexion",
        toastLength: Toast.LENGTH_SHORT, // ou Toast.LENGTH_LONG
        gravity: ToastGravity.BOTTOM, // ou TOP, CENTER
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Bienvenue, ${utilisateur?['nom']} ${utilisateur?['prenom']} (${utilisateur?['role']})!'),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                Colors.blue, // Couleur de fond du bouton
                padding: EdgeInsets.symmetric(
                  // Espace interne
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  // Coins arrondis (optionnel)
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: logout,
              child: Text(
                "Se déconnecter",
                style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.blue,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
