import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rest_api_example/screens/home.dart' as home;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_api_example/bloc/bloc.dart';

Future<String> getUsername() async{
  try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("postName");
  }catch(e){
    print(e);
  }
}

Future<String> getId() async{
  try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("postId");
  }catch (e){
    print(e);
  }
}

class Posts extends StatelessWidget {
  Posts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  final CardBloc controller = CardBloc();

  buildBody(BuildContext context) {
    print('HOLAMUNDO');
    return SingleChildScrollView(
      child: FutureBuilder(
        future: getId(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            return FutureBuilder(
              future: controller.getPosts(snapshot.data),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return Column(
                    children:
                    snapshot.data.map<Widget>((e) {
                      return home.buildPost(e["title"], e["body"]);
                    }).toList(),
                  );
                }else{
                  return CircularProgressIndicator();
                }
              },
            );
          }else{
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
        ),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
      title: FutureBuilder(
        future: getUsername(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            return Text(
                snapshot.data,
                style: TextStyle(color: Colors.black),
            );
          }else{
            return Text("data");
          }
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

