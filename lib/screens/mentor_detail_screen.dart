import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../screens/book_screen.dart';

import '../providers/mentors.dart';
import '../providers/reviews.dart';
import '../providers/review.dart';
import '../providers/slots.dart';

class MentorDetailScreen extends StatefulWidget {
  // final String title;
  // final String price;

  // MentorDetailScreen(this.title, this.price);
  static const routeName = '/Mentor-detail';

  @override
  _MentorDetailScreenState createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {
  var _isInit = true;
  var _isLoading = true;



  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        // _isLoading = true;
      });

      // Provider.of<Reviews>(context).fetchAndSetReviews().then((_) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // });
      Provider.of<Slots>(context).fetchAndSetSlots().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mentorId = ModalRoute.of(context).settings.arguments as String;
    final loadedMentor = Provider.of<Mentors>(
      context,
      listen: false,
    ).findById(mentorId);

    final reviews = Provider.of<Reviews>(context, listen: false);
    double reviewsAvg = reviews.findReviewsAvgById(mentorId);
    int reviewsCount = reviews.reviewsCount(mentorId);
    List<Review> reviewsList = reviews.getReviewsById(mentorId);

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMentor.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      loadedMentor.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  loadedMentor.id == "-LtD22o-nz3SYsSgjFwK" ||
                          loadedMentor.id == "-LtHh-AjUJrBKH2HO5QT" ||
                          loadedMentor.id == "-LtHm436kXQCPPc3tSNn"
                      ? Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: () {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (BuildContext context) =>
                              //         VideoChat(displayName: 'user', mentorId: mentorId)));

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Book(mentorId: mentorId)));
                            },
                            child: Text('Reserve a Session',
                                style: TextStyle(
                                    fontSize: 20.0, fontFamily: 'JannaLT')),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: null,
                            child: Text("Currenlty Unavailable",
                                style: TextStyle(fontSize: 20.0)),
                          ),
                        ),
                  Text(
                    loadedMentor.tag,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    child: Text(
                      loadedMentor.description,
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                  SizedBox(height: 30),
                  RatingBarIndicator(
                    rating: reviewsAvg,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 16.0,
                    direction: Axis.horizontal,
                  ),
                  SizedBox(height: 15),
                  reviewsCount != 0
                      ? Container(
                          height: 250,
                          child: ListView.builder(
                            itemCount: reviewsCount,
                            itemBuilder: (context, i) {
                              return Card(
                                elevation: 10,
                                margin: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 5,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: FittedBox(
                                          child: Text(
                                        "image",
                                        style: TextStyle(fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  title: Text(
                                    reviewsList[i].description,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    "User name",
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
    );
  }
}
