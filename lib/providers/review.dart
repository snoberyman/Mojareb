// import 'dart:convert';

import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

class Review with ChangeNotifier {
  final String id;
  final String mentorId;
  final String description;
  final double rating;


  Review({
    @required this.description,
    @required this.id,
    @required this.mentorId,
    @required this.rating,
  });


}
