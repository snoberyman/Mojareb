import 'package:flutter/foundation.dart';


class Session with ChangeNotifier {
  final String id;
  final String mentorId;
  final String time;
  final String duration;
  final String mainC;
  final String description;
  // final String userIdd;
  


  Session({
    @required this.id,
    @required this.mentorId,
    @required this.time,
    @required this.mainC,
    @required this.description,
    @required this.duration,
    // @required this.userIdd,
  });


}