import 'dart:convert';

import 'package:flutter_cubit_isar/logic/constants/constants.dart';
import 'package:http/http.dart' as http;

class PostsService {
  static const FETCH_LIMIT = 15;

  // fetches only 15 posts per page at a time
  Future<List<dynamic>> fetchPosts(int page) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/posts?_limit=$FETCH_LIMIT&_page=$page"));
      return jsonDecode(response.body) as List<dynamic>;
    } catch (err) {
      return [];
    }
  }
}
