import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:rest_api_example/services/api_service.dart';
import 'package:rest_api_example/models/user_model.dart';

var cardControler = getRepo();

class CardBloc {

  Future<List<dynamic>> getCardsInfo() async{
    try{
      final List<dynamic> cardInfo = (await cardControler.getUsers()) as List;
      return cardInfo;
    }catch (e){
      print(e.toString());
    }
  }

  Future<List<dynamic>> getNames() async{
    try{
      List<Map<dynamic, dynamic>> names = [];
      List<dynamic> info = await getCardsInfo();
      for (int i = 0; i < info.length; i++){
        names.add({info[i]["name"]: info[i]["id"]});
      }
      return names;
    }catch (e){
      print(e.toString());
    }
  }

  Future<List<dynamic>> getPosts(String id) async{
    try{
      List<dynamic> info = await cardControler.getPostsFromUser(id);
      return info;
    }catch (e) {
      print(e.toString());
    }
  }



}


