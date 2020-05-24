import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './slot.dart';

class Slots with ChangeNotifier {
  List<Slot> _items = [];

  final String authToken;
  final String userId;

  Slots(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Slot> get items {
    return [..._items];
  }

  List<Slot> findByMentorId(String mentorId) {
    return [..._items.where((slot) => (slot.mentorId == mentorId && slot.status == 'active'))];
  }

  int noOfSlotsByMentorId(String mentorId) {
    return _items.where((slot) => (slot.mentorId == mentorId && slot.status == 'active')).length;
  }

  // List<Session> findByUserId(String userId) {
  //   return _items.where((sess) => sess.userIdd == userId);
  // }

  Future<void> fetchAndSetSlots([bool filterByUser = false]) async {
    //  final filterString =
    //     filterByUser ? 'orderByChild="status"&equalTo="active"' : '';

    var url =
        'https://flutter-course-89a90.firebaseio.com/slots.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final List<Slot> loadedSlots = [];
      extractedData.forEach((slotId, slotData) {
        loadedSlots.add(Slot(
          id: slotId,
          time: slotData['time'],
          status: slotData['status'],
          duration: slotData['duration'],
          mentorId: slotData['mentorId'],
        ));
      });
      
      _items = loadedSlots;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addSlot(Slot slot) async {
    final url =
        'https://flutter-course-89a90.firebaseio.com/slots.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'time': slot.time,
          'status': slot.status,
          'duration': slot.duration,
          'mentorId': slot.mentorId,
        }),
      );
      final newSlot = Slot(
        time: slot.time,
        duration: slot.duration,
        status: slot.status,
        mentorId: slot.mentorId,
        id: json.decode(response.body)['mentorId'],
      );
      _items.add(newSlot);
      //_items.insert(0, newMentor);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }


  Future<void> updateSlot(String id, Slot newSlot) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-course-89a90.firebaseio.com/slots/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'duration': newSlot.duration,
            'mentorId': newSlot.mentorId,
            'status': newSlot.status,
            'time': newSlot.time,
          }));
      _items[prodIndex] = newSlot;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> updateSlotReserved(String id, Slot newSlot) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-course-89a90.firebaseio.com/slots/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'duration': newSlot.duration,
            'mentorId': newSlot.mentorId,
            'status': 'reserved',
            'time': newSlot.time,
          }));
      _items[prodIndex] = newSlot;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteSlot(String id) async {
    final url =
        'https://flutter-course-89a90.firebaseio.com/slots/$id.json?auth=$authToken';
    final existingSlotIndex = _items.indexWhere((slot) => slot.id == id);
    var existingSlot = _items[existingSlotIndex];
    _items.removeAt(existingSlotIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingSlotIndex, existingSlot);
      notifyListeners();
      throw HttpException('Could not delete Slot');
    }
    existingSlot = null;

    // _items.removeWhere((prod) => prod.id == id);
  }
}
