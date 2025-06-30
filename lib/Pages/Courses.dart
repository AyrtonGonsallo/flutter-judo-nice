


import 'dart:convert';

import 'package:appli_ojn/Models/Utilisateur.dart';
import 'package:appli_ojn/Pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:searchable_listview/searchable_listview.dart';

import '../Constants/ApiConstants.dart';
import '../Models/Cours.dart';
import '../widgets/CoursWidget.dart';

class CoursesListPage extends StatefulWidget{

  final int userId;

  const CoursesListPage({super.key, required this.userId});

  @override
  _CoursesListPageState createState() => _CoursesListPageState();

}

class _CoursesListPageState extends State<CoursesListPage> {
  late Future<Utilisateur> userFuture;
  late String apiUrl;
  late int userId;

  @override
  void initState() {
    super.initState();
    userId=widget.userId;
    apiUrl = ApiConstants.baseUrl;
    userFuture = fetchUtilisateur(apiUrl,widget.userId);

  }

  Future<Utilisateur> fetchUtilisateur(String apiUrl,int userId) async {
    final response = await http.get(Uri.parse("$apiUrl/api/auth/get_all_teacher_datas/$userId"));
    final data = jsonDecode(response.body) ;
    print(data);
    return  Utilisateur.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mes cours"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
            child: Image.asset('images/logo_blanc_transparent.png', height: 40),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Column(
                children: [
                  Image(
                    image: AssetImage("images/logo_blanc_transparent.png"),
                  ),
                ],
              ),
            ),
            Expanded(child:
            ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Accueil"),
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_)=>HomePage(userId: userId))
                    );
                  },
                )
              ],
            )
            )
          ],
        ),
      ),
      body: FutureBuilder<Utilisateur>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.cours!.isEmpty) {
            return const Center(child: Text("Aucun cours trouvé."));
          }

          final user = snapshot.data!;
          final coursList = user.cours!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${user.dojo!.nom}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                Flexible(
                  child: SearchableList<Cours>(
                    initialList: coursList,
                    itemBuilder: (Cours cours) => CoursItem(cours: cours,userID: user.id),
                    filter: (value) => coursList.where(
                          (cours) =>
                      cours.jour.toLowerCase().contains(value.toLowerCase()) ||
                          cours.heure.contains(value) ||
                          cours.categorieAge.toLowerCase().contains(value.toLowerCase()),
                    ).toList(),
                    emptyWidget: const Center(child: Text("Aucun résultat.")),
                    inputDecoration: InputDecoration(
                      labelText: "Rechercher un cours",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );


        },
      ),
    );
  }
}
