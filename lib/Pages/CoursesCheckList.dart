


import 'dart:convert';

import 'package:appli_ojn/Pages/Courses.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Constants/ApiConstants.dart';
import '../Models/Appel.dart';
import '../Models/Cours.dart';
import '../Models/AdherentAvecAppel.dart';
import 'Home.dart';

class CourseCheckListPage extends StatefulWidget{

  final int userId;
  final int courseId;

  const CourseCheckListPage({super.key, required this.userId, required this.courseId});

  @override
  _CourseCheckListPageState createState() => _CourseCheckListPageState();

}


class _CourseCheckListPageState extends State<CourseCheckListPage> {

  late Future<List<dynamic>> combinedFuture=Future.value([]);
  late String apiUrl;
  late int userId;
  late int courseId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    courseId = widget.courseId;
    apiUrl = ApiConstants.baseUrl;
    combinedFuture = Future.wait([
      fetchAdherents(widget.courseId),
      fetchCours(widget.courseId),
    ]);
  }


  Future<List<AdherentAvecAppel>> fetchAdherents(int courseId) async {
    final response = await http.get(Uri.parse("$apiUrl/api/adherents/adherents_by_cours_with_appels/$courseId"));
    if(response.body.length>0){
      final data = jsonDecode(response.body) as List;
      print(data);
      return data.map((e) => AdherentAvecAppel.fromJson(e)).toList();
    }else{
      final data = jsonDecode(response.body);
      print(data);
      return [];
    }


  }

  Future<List<Cours>> fetchCours(int courseId) async {
    final response = await http.get(Uri.parse("$apiUrl/api/dojo_cours/get_cours/$courseId"));
    final data = jsonDecode(response.body) ;
    print(data);
    return  [Cours.fromJson(data)];

  }


  Future<void> updateorCreateAppelStatus(int adherentId,int coursId, bool status) async {
    // Exemple, adapte selon ton API
    final response = await http.post(
      Uri.parse('$apiUrl/api/adherents/upsert_appel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status':status, 'adherentId':adherentId, 'coursId':coursId }),
    );
    print("mise a jour appel");
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception('Erreur API');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Présence"),
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
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Mes cours"),
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_)=>CoursesListPage(userId: userId))
                    );
                  },
                )
              ],
            )
            )
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun adhérent trouvé.'));
          }

          final adherents_avec_appels = snapshot.data![0] as List<AdherentAvecAppel>;
          final cours = snapshot.data![1] as List<Cours>;
          final now = DateTime.now();
          final formattedDate = formatDate(now, [dd, '/', mm, '/', yyyy]);
// ou autre format : DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(now);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${cours[0].dojo!.nom} - ${cours[0].jour} - ${cours[0].heure.substring(0,5)} - ${formattedDate}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Nom', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                      DataColumn(
                        label: Text('Prenom', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                      DataColumn(
                        label: Text('Action', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    ],
                    rows: adherents_avec_appels.map((adherent_avec_appel) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(adherent_avec_appel.adherent.nom)),
                          DataCell(Text(adherent_avec_appel.adherent.prenom)),
                          DataCell(Row(
                            children: [

                              IconButton(
                                icon: Icon(
                                  adherent_avec_appel.appel != null && adherent_avec_appel.appel!.status
                                      ? Icons.check_circle
                                      : Icons.cancel     ,
                                  color: adherent_avec_appel.appel != null && adherent_avec_appel.appel!.status
                                      ? Colors.green
                                      : Colors.red,

                                ),
                                onPressed: () async {
                                  final ancienStatus = adherent_avec_appel.appel?.status ?? false;
                                  final bool nouveauStatus = !ancienStatus;

                                  setState(() {
                                    if (adherent_avec_appel.appel == null) {
                                      // Si pas encore d'appel → création locale temporaire
                                      adherent_avec_appel.appel = Appel(
                                        id: 0, // ou null si non requis par ton modèle
                                        status: nouveauStatus,
                                        adherentId: adherent_avec_appel.adherent.id,
                                        coursId: cours[0].id,
                                        date: DateTime.now().toIso8601String(), // si utile
                                      );
                                    } else {
                                      // Toggle si appel déjà existant
                                      adherent_avec_appel.appel!.status = nouveauStatus;
                                    }
                                  });

                                  try {
                                    // Appel API qui gère création ou update selon existence
                                     await updateorCreateAppelStatus(
                                      adherent_avec_appel.adherent.id,
                                      cours[0].id,
                                      nouveauStatus,
                                    );


                                  } catch (e) {
                                    // Revert en cas d'erreur
                                    setState(() {
                                      adherent_avec_appel.appel?.status = ancienStatus;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Erreur lors de la mise à jour')),
                                    );
                                  }
                                },
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),

    );
  }


}

