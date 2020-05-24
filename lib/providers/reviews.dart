import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// import '../models/http_exception.dart';
import './review.dart';

class Reviews with ChangeNotifier {
  List<Review> _items = [
    // Mentor(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Mentor(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Mentor(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Mentor(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId;

  Reviews(this.authToken, this.userId, this._items);

  List<Review> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }



  Review findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Review> getReviewsById(String id){
    List<Review> reviewsList = _items.where((rev) => rev.mentorId == id).toList();
    return reviewsList;
  }

  int reviewsCount(String id){
    List<Review> reviewsList = _items.where((rev) => rev.mentorId == id).toList();
    return reviewsList.length;
  }
  double findReviewsAvgById(String id) {
  
   List<Review> reviewsList = _items.where((rev) => rev.mentorId == id).toList();
   int count = reviewsList.length;
   if(count != 0){
     
     double sum = reviewsList.map<double>((m) => m.rating).reduce((a,b )=>a+b);
     return sum/count;
   }else{
     return 0;
   }
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetReviews([bool filterByUser = false]) async {
    // final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-course-89a90.firebaseio.com/reviews.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final List<Review> loadedReviews = [];
      extractedData.forEach((prodId, prodData) {
        loadedReviews.add(Review(
          id: prodId,
          description: prodData['description'],
          mentorId: prodData['mentorId'],
          rating: prodData['rating'],
        ));
      });
      _items = loadedReviews;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addReview(Review review) async {
    final url =
        'https://flutter-course-89a90.firebaseio.com/reviews.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'description': review.description,
          'mentorId': review.mentorId,
          'rating': review.rating,
        }),
      );
      final newReview = Review(

        description: review.description,
        mentorId: review.mentorId,
        rating: review.rating,
        id: json.decode(response.body)['name'],
      );
      _items.add(newReview);
      //_items.insert(0, newMentor);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Future<void> updateReview(String id, Mentor newMentor) async {
  //   final prodIndex = _items.indexWhere((prod) => prod.id == id);
  //   if (prodIndex >= 0) {
  //     final url =
  //         'https://flutter-course-89a90.firebaseio.com/mentors/$id.json?auth=$authToken';
  //     await http.patch(url,
  //         body: json.encode({
  //           'title': newMentor.title,
  //           'name': newMentor.name,
  //           'description': newMentor.description,
  //           'imageUrl': newMentor.imageUrl,
  //           'tag': newMentor.tag,
  //         }));
  //     _items[prodIndex] = newMentor;
  //     notifyListeners();
  //   } else {
  //     print('...');
  //   }
  // }

  // Future<void> deleteMentor(String id) async {
  //   final url =
  //       'https://flutter-course-89a90.firebaseio.com/mentors/$id.json?auth=$authToken';
  //   final existingMentorIndex = _items.indexWhere((prod) => prod.id == id);
  //   var existingMentor = _items[existingMentorIndex];
  //   _items.removeAt(existingMentorIndex);
  //   notifyListeners();
  //   final response = await http.delete(url);
  //   if (response.statusCode >= 400) {
  //     _items.insert(existingMentorIndex, existingMentor);
  //     notifyListeners();
  //     throw HttpException('Could not delete Mentor');
  //   }
  //   existingMentor = null;

  //   // _items.removeWhere((prod) => prod.id == id);
  // }
}
