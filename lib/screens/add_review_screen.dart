import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../providers/review.dart';
import '../providers/reviews.dart';

class AddReviewscreen extends StatefulWidget {
  static const routeName = '/edit-Review';
  final String mentorId;

  AddReviewscreen({Key key, @required this.mentorId}) : super(key: key);
  @override
  _AddReviewscreenState createState() =>
      new _AddReviewscreenState(mentorId: mentorId);
}

class _AddReviewscreenState extends State<AddReviewscreen> {
  final _reviewFocusNode = FocusNode();
  final String mentorId;

  _AddReviewscreenState({Key key, @required this.mentorId});
  final _form = GlobalKey<FormState>();
  var _editedReview = Review(
    id: null,
    description: '',
    mentorId: '',
    rating: 3,
  );
  var _initValues = {
    'description': '',
    'mentorId': '',
    'rating': '',
  };
  // var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  // if (_isInit) {
  //   final mentorId = ModalRoute.of(context).settings.arguments as String;
  //   if (mentorId != null) {
  //     _editedReview =
  //         Provider.of<Reviews>(context, listen: false).findById(mentorId);
  //     _initValues = {
  //       'description': _editedReview.description,
  //     };
  //   }
  // }
  // _isInit = false;
  // super.didChangeDependencies();
  // }

  @override
  void dispose() {
    _reviewFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    try {
      await Provider.of<Reviews>(context, listen: false)
          .addReview(_editedReview);
    } catch (error) {
      print(error);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occuerrd'),
          content: Text('something went wrong'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    } // finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   Navigator.of(context).pop();
    // }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Review'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.save),
        //     onPressed: _saveForm,
        //   ),
        // ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                          labelText: 'How was you experience?'),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      focusNode: _reviewFocusNode,
                      onSaved: (value) {
                        _editedReview = Review(
                          description: value,
                          mentorId: mentorId,
                          rating: _editedReview.rating,
                          id: _editedReview.id,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please add your review';
                        }
                        if (value.length < 4) {
                          return 'Should be at least 4 characters lenght';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    Container(
                      alignment: Alignment(0.0, 0.0),
                      child: RatingBar(
                        initialRating: 3,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                          _editedReview = Review(
                            description: _editedReview.description,
                            mentorId: mentorId,
                            rating: rating,
                            id: _editedReview.id,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            color: Colors.red,
                            child: Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14,color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                          ),
                          SizedBox(width: 30,),
                          FlatButton.icon(
                            
                            label: Text('Save',style: TextStyle(color: Colors.white,fontSize: 16),),
                            icon: Icon(Icons.save),
                            onPressed: _saveForm,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
