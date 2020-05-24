import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Mentor with ChangeNotifier {
  final String id;
  final String name;
  final String title;
  final String description;
  final String tag;
  final String imageUrl;
  bool isFavorite;

  Mentor({
    @required this.description,
    @required this.id,
    @required this.imageUrl,
    @required this.tag,
    @required this.name,
    @required this.title,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-course-89a90.firebaseio.com/userFavorite/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
