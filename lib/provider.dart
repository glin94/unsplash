import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'model/photo.dart';

const CLIENT_ID =
    "cf49c08b444ff4cb9e4d126b7e9f7513ba1ee58de7906e4360afc1a33d1bf4c0";
Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
      await client.get('https://api.unsplash.com/photos/?client_id=$CLIENT_ID');
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    // Use the compute function to run parsePhotos in a separate isolate.
    return compute(parsePhotos, response.body);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load photos');
  }
}

// A function that converts a response body into a List<Photo>.
List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}
