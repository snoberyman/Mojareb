import 'package:flutter/foundation.dart';

class Slot with ChangeNotifier {
  final String id;
  final String mentorId;
  final String time;
  final String duration;
  final String status;

  Slot({
    @required this.id,
    @required this.mentorId,
    @required this.time,
    @required this.duration,
    @required this.status,
    // @required this.userIdd,
  });
}
