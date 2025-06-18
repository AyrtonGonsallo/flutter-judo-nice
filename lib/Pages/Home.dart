import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../db_helper.dart';
import 'Login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      await DBHelper.clearUser();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(title: 'Login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        backgroundColor: Colors.white54,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey, // couleur du trait
            height: 1.0, // épaisseur du trait
          ),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Image.asset('images/icon_72x72.png', height: 50),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Bienvenue, ${utilisateur?['nom']} ${utilisateur?['prenom']} (${utilisateur?['role']})!',
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur de fond du bouton
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
                  color: Colors.white,
                  backgroundColor: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
