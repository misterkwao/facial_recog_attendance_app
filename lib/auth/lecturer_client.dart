import 'dart:io';

import 'package:dio/dio.dart';

import '../Auth/api.dart';

class LecturerClient {
  var dioclient = Dio();

  Future<dynamic> getProfile(String api) async {
    var url = baseurl + api;
    var response = await dioclient.get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response;
    } else {
      // throw Exception(response.data.toString());
      // throw exception
    }
  }
}
