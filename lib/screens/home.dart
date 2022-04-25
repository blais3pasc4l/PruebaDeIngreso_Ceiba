import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rest_api_example/services/api_service.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/bloc.dart';
import '../models/user_model.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

Future<void> _setIdPreferences(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("postId", id);
}

Future<void> _setNamePreferences(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("postName", name);
}

class _HomeState extends State<Home> {

  final userInfo = CardBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prueba de Ingreso'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async{
              final results = await showSearch(context: context, delegate: UserSearch());
            },
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: userInfo.getCardsInfo(),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot){
                if(snapshot.hasData){
                  return Column(
                    children: snapshot.data.map((e) {
                      return buildCard(e["id"], e["name"], e["phone"], e["email"], context);
                    }).toList(),
                  );
                }else{
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      )
    );
  }
}

class UserSearch extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear),
      onPressed: (){
        if (query.isEmpty){
          close(context, null);
        }else{
          query = '';
          showSuggestions(context);
        }
      },
    )
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          close(context, null);
        },
      );

  CardBloc controller = CardBloc();

  @override
  Widget buildResults(BuildContext context) {
      return SingleChildScrollView(
        child: FutureBuilder(
              future: controller.getNames(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  for (int i = 0; i < snapshot.data.length; i++){
                    if (snapshot.data[i].keys.toString().substring(1, snapshot.data[i].keys.toString().length - 1) == query){
                      return FutureBuilder(
                          future: controller.getPosts(snapshot.data[i].values.toString().substring(1, snapshot.data[i].values.toString().length - 1)),
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              return Column(
                                  children:
                                    snapshot.data.map<Widget>((e) {
                                      return buildPost(e["title"], e["body"]);
                                    }).toList(),
                                );
                            }else{
                              return CircularProgressIndicator();
                            }
                          }
                       );
                    }
                  }
                  return Container();
                }else{
                  return Center(child: CircularProgressIndicator());
                }
              }
          ),
      );
  }

  @override
  Widget buildSuggestions(BuildContext context) => FutureBuilder<List<dynamic>>(
      future: controller.getNames(),
      builder: (context, snapshot){
          if (snapshot.hasData){
            List<String> recentList = [];
            List<String> totalList = [];
            for (int i = 0; i < (snapshot.data.length/3); i++){
              recentList.add(snapshot.data[i].keys.toString().substring(1, snapshot.data[i].keys.toString().length - 1));
            }
            for (int i = 0; i < snapshot.data.length; i++){
              totalList.add(snapshot.data[i].keys.toString().substring(1, snapshot.data[i].keys.toString().length - 1));
            }
            final suggestions = query.isEmpty
              ? recentList
              : totalList.where((name) {
                  final nameLower = name.toLowerCase();
                  final queryLower = query.toLowerCase();

                  return nameLower.startsWith(queryLower);
                }).toList();
            return buildSuggestionsSucces(suggestions);
          }else{
            return Center(child: CircularProgressIndicator());
          }
      },
  );

  Widget buildSuggestionsSucces(List<String> suggestions) =>
      ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index){
          final suggestion = suggestions[index];
          final queryText = suggestion.substring(0, query.length);
          final remainingText = suggestion.substring(query.length);
          return ListTile(
            onTap: () {
              query = suggestion;
              //close(context, suggestion);
              showResults(context);
            },
            leading: Icon(Icons.account_circle, color: Colors.green),
            title: RichText(
              text: TextSpan(
                text: queryText,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
                children: [
                  TextSpan(
                    text: remainingText,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    )
                  )
                ]
              ),
            ),
          );
        },
      );
}

Card buildCard(int id, String name, String phone, String email, BuildContext context) {
  String _id = id.toString();
  return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
            margin: EdgeInsets.all(15),
            elevation: 10,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                      name,
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  iconColor: Colors.green,
                  title: Text(phone),
                ),
                Container(
                  child: ListTile(
                    leading: Icon(Icons.email),
                    iconColor: Colors.green,
                    title: Text(email),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 150),
                    TextButton(
                      child: Text(
                        "Ver Publicaciones",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      onPressed: (){
                        _setIdPreferences(_id);
                        _setNamePreferences(name);
                        Navigator.pushNamed(context, '/posts');
                      },
                    )
                  ],
                )
              ],
            ),
          );
}

Card buildPost(String title, String body) {
  return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)),
    margin: EdgeInsets.all(15),
    elevation: 10,
    child: Column(
      children: [
        ListTile(
          title: Text(
            title.toUpperCase(),
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
        ListTile(
          leading: Icon(Icons.add_box_outlined),
          title: Text(body),
        ),
        SizedBox(height:10)
      ],
    ),
  );
}
