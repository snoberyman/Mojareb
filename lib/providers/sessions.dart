import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './session.dart';
import '../models/http_exception.dart';

class Sessions with ChangeNotifier {
  List<Session> _items = [];

  final String authToken;
  final String userId;

  Sessions(this.authToken, this.userId, this._items);

  List<Session> get items {
    return [..._items];
  }

  Session findById(String id) {
    return _items.firstWhere((sess) => sess.id == id);
  }

  // List<Session> findByUserId(String userId) {
  //   return _items.where((sess) => sess.userIdd == userId);
  // }

  Future<void> fetchAndSetSessions([bool filterByUser = false]) async {
    // final filterString =
    //     filterByUser ? 'orderBy="userIdd"&equalTo="$userId"' : '';
        
    var url =
        'https://flutter-course-89a90.firebaseio.com/sessions.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final List<Session> loadedSessions = [];
      extractedData.forEach((sessionId, sessionData) {
        loadedSessions.add(Session(
          id: sessionId,
          mentorId: sessionData['mentorId'],
          time: sessionData['time'],
          mainC: sessionData['mainC'],
          description: sessionData['description'],
          duration: sessionData['duration'],
        ));
      });
      _items = loadedSessions;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }



  Future<void> addSession(Session session) async {
    final url =
        'https://flutter-course-89a90.firebaseio.com/sessions.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'mentorId': session.mentorId,
          'time': session.time,
          'mainC': session.mainC,
          'description': session.description,
          'duration': session.duration,
        }),
      );
      final newSession = Session(
        mentorId: session.mentorId,
        time: session.time,
        mainC: session.mainC,
        description: session.description,
        duration: session.duration,
        id: json.decode(response.body)['name'],
      );
      _items.add(newSession);
      //_items.insert(0, newMentor);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteSession(String id) async {
    final url =
        'https://flutter-course-89a90.firebaseio.com/sessions/$id.json?auth=$authToken';
    final existingSessionIndex = _items.indexWhere((session) => session.id == id);
    var existingSession = _items[existingSessionIndex];
    _items.removeAt(existingSessionIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingSessionIndex, existingSession);
      notifyListeners();
      throw HttpException('Could not delete Session');
    }
    existingSession = null;

    // _items.removeWhere((prod) => prod.id == id);
  }
}
