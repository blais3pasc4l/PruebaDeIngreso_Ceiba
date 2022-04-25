import 'dart:developer';
import 'package:rest_api_example/constants.dart';
import 'package:dio/dio.dart';
import 'package:rest_api_example/models/user_model.dart';

class getRepo {

  var dio = Dio();

  Future<List<dynamic>> getUsers() async {
    try {
      Response response = await dio.get('https://jsonplaceholder.typicode.com/users');
      return response.data;
    }on DioError catch (e) {
      if (e.response != null) {
        print(e.message);
        print(e.response.data);
        print(e.response.headers);
      } else {
        print(e.message);
      }
    }
  }

  Future<List<dynamic>> getPostsFromUser(String id) async{
    try{
      Response response = await dio.get('https://jsonplaceholder.typicode.com/posts?userId='+id);
      return response.data;
    }on DioError catch (e) {
      if (e.response != null) {
        print(e.message);
        print(e.response.data);
        print(e.response.headers);
      } else {
        print(e.message);
      }
    }
  }
}

