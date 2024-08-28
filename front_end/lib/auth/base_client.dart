// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';

import '../Auth/api.dart';

class DioClient {
  var dioclient = Dio();

  Future<dynamic> postCreateAdmin(String api, dynamic object) async {
    var url = baseurl + api;
    var response = await dioclient.post(
      url,
      data: object,
      options: Options(
        contentType: 'application/json',
        headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      print(response.data);
      print('failed');
      // throw exception
    }
  }

  Future<dynamic> deleteAdmin(String api) async {
    var url = baseurl + api;
    var response = await dioclient.delete(url);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      // throw exception
    }
  }

  Future<dynamic> updateAdmin(String api, dynamic object) async {
    dioclient.options.contentType = Headers.jsonContentType;
    var url = baseurl + api;
    var response = await dioclient.patch(
      url,
      data: object,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {'Authorization': "bearer $accessToken"},
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      // throw exception
    }
  }

  Future<dynamic> getClassLocs(String api) async {
    var url = baseurl + api;
    var response = await dioclient.get(
      url,
      options: Options(
        responseType: ResponseType.json,
        headers: {"Authorization": "bearer $accessToken"},
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      // throw exception
    }
  }
}

Future<dynamic> createClassLoc(String api) async {
  var url = baseurl + api;
  var response = await Dio().post(
    url,
    options: Options(
      contentType: 'application/json',
      headers: {"Authorization": "bearer $accessToken"},
      validateStatus: (status) => true,
    ),
  );
  if (response.statusCode == 200) {
    return response.data;
  } else {
    // throw exception
    print(response.data);
    print('failed');
  }
}
