// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../Auth/api.dart';

class DioClient {
  var dioclient = Dio();

  Future<dynamic> postLogin(
      String api, dynamic object, BuildContext context) async {
    dioclient.options.contentType = Headers.formUrlEncodedContentType;
    var url = baseurl + api;
    var response = await dioclient.post(
      url,
      data: object,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      accessToken = response.data["access_token"];
      return response.data;
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Ooops!",
        text: response.data["detail"],
      );
    }
  }

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
