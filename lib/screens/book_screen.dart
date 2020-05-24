import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/session.dart';
import '../providers/sessions.dart';
import '../providers/slot.dart';
import '../providers/slots.dart';
import '../providers/mentors.dart';

class Book extends StatefulWidget {
  static const routeName = '/book';

  final String mentorId;

  Book({Key key, @required this.mentorId}) : super(key: key);

  @override
  _BookState createState() => _BookState(mentorId: mentorId);
}

class _BookState extends State<Book> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _form = GlobalKey<FormState>();
  final _descriptionFocusNode = FocusNode();

  final String mentorId;
  var selectedCat = '';
  var selectedCat2 = '';
  Slot selectedTimeSlotId;
  var tcVisibility = false;

  String dateTimeValue = '';

  _BookState({Key key, @required this.mentorId});

  var _editedSession = Session(
    id: null,
    // userIdd: null,
    mentorId: '',
    time: null,
    mainC: '',
    duration: '',
    description: '',
  );
  // var _initValues = {
  //   'mentorId': '',
  //   'time': '',
  //   'mainC': '',
  //   'description': '',
  //   'duration': '',
  // };

  List<Slot> _editedSlots = [
    Slot(
      id: null,
      time: '',
      duration: '',
      status: '',
      mentorId: '',
    )
  ];
  int noOfTimeSlots = 0;

  var _isInit = true;
  // var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final sessionId = ModalRoute.of(context).settings.arguments as String;

      noOfTimeSlots = Provider.of<Slots>(context, listen: false)
          .noOfSlotsByMentorId(mentorId);
      // print(mentorId);
      // print(noOfTimeSlots);
      if (noOfTimeSlots != 0) {
        _editedSlots =
            Provider.of<Slots>(context, listen: false).findByMentorId(mentorId);
      }
      if (sessionId != null) {
        _editedSession =
            Provider.of<Sessions>(context, listen: false).findById(sessionId);
        // _initValues = {
        //   'mentorId': _editedSession.mentorId,
        //   'time': _editedSession.time,
        //   'duration': _editedSession.duration,
        //   'description': _editedSession.description,
        //   'mainC': _editedSession.mainC,
        // };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  bool editedSessionHaveValue() {
    if (selectedTimeSlotId != null && _editedSession.mainC != '') {
      return true;
    }
    return false;
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    // setState(() {
    //   _isLoading = true;
    // });

    if (_editedSession.id != null) {
      // await Provider.of<Sessions>(context, listen: false)
      //     .updateMentor(_editedMentor.id, _editedMentor);
    } else {
      try {
        await Provider.of<Sessions>(context, listen: false)
            .addSession(_editedSession);
        await Provider.of<Slots>(context, listen: false)
            .deleteSlot(selectedTimeSlotId.id);
        // await Provider.of<Slots>(context, listen: true).fetchAndSetSlots(true);
        // await Provider.of<Slots>(context, listen: false)
        //     .updateSlotReserved(selectedTimeSlotId.id,selectedTimeSlotId);
      } catch (error) {
        print(error);
        await showDialog(
          context: _scaffoldKey.currentState.context,
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
    }
    // setState(() {
    //   _isLoading = false;
    // });
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Awesome!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, color: Theme.of(context).accentColor),
        ),
        content: Text(
          'Your session has been reserved!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: <Widget>[
          Center(
            child: FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          )
        ],
      ),
    );
    Navigator.of(context).pop();
  }

  Widget getCat(String cat) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: switchColor(cat),
      ),
      width: MediaQuery.of(context).size.width * 0.30,
      height: 60.0,
      child: InkWell(
        onTap: () {
          selectCat(cat);
          // print(cat);
          _editedSession = Session(
              mainC: cat,
              id: _editedSession.id,
              duration: _editedSession.duration,
              time: _editedSession.time,
              description: _editedSession.description,
              mentorId: _editedSession.mentorId);
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              cat,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                  color: switchContentColor(cat)),
            ),
          ),

          // Text(
          //   day,
          //   style: TextStyle(
          //       fontFamily: 'FiraSans',
          //       fontSize: 15.0,
          //       color: switchContentColor(date)),
          // ),
        ),
      ),
    );
  }

  Color switchColor(cat) {
    if (cat == selectedCat) {
      return Colors.black.withOpacity(0.8);
    } else {
      return Colors.grey.withOpacity(0.2);
    }
  }

  Color switchContentColor(cat) {
    if (cat == selectedCat) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  selectCat(cat) {
    setState(() {
      selectedCat = cat;
    });
  }

  Widget getCat2(String cat, Slot selectedSlot) {
    List<String> timeAndDuration = cat.split('/');
    var parsedDate = DateTime.parse(timeAndDuration[0]);

    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    String startTime = DateFormat('kk:mm').format(parsedDate);

    var formattedTime =
        parsedDate.add(new Duration(minutes: int.parse(timeAndDuration[1])));
    String endTime = DateFormat('kk:mm').format(formattedTime);

    // cat = formattedDate + '\n' + startTime + ' - ' + endTime;
    cat = formattedDate + '\n' + startTime + ' - ' +  endTime;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(00.0),
        color: switchColor2(cat),
      ),
      width: MediaQuery.of(context).size.width * 0.33,
      height: 50.0,
      child: InkWell(
        onTap: () {
          selectCat2(cat, selectedSlot);

          _editedSession = Session(
              time: timeAndDuration[0],
              id: _editedSession.id,
              duration: timeAndDuration[1],
              mainC: _editedSession.mainC,
              description: _editedSession.description,
              mentorId: _editedSession.mentorId);
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              cat,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Lanto',
                  color: switchContentColor2(cat)),
            ),
          ),

          // Text(
          //   day,
          //   style: TextStyle(
          //       fontFamily: 'FiraSans',
          //       fontSize: 15.0,
          //       color: switchContentColor(date)),
          // ),
        ),
      ),
    );
  }

  Color switchColor2(cat) {
    if (cat == selectedCat2) {
      return Colors.black.withOpacity(0.8);
    } else {
      return Colors.grey.withOpacity(0.2);
    }
  }

  Color switchContentColor2(cat) {
    if (cat == selectedCat2) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  selectCat2(cat, selectedSlot) {
    setState(() {
      selectedCat2 = cat;
      selectedTimeSlotId = selectedSlot;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loadedMentor = Provider.of<Mentors>(
      context,
      listen: false,
    ).findById(mentorId);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Reserve a Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              // RaisedButton(
              //   onPressed: () {
              //     DatePicker.showDateTimePicker(context, showTitleActions: true,
              //         onChanged: (date) {
              //       print('change $date in time zone ' +
              //           date.timeZoneOffset.inHours.toString());
              //     }, onConfirm: (date) {
              //       print('confirm $date');
              //       setState(() {
              //         tcVisibility = true;
              //         var formatter = new DateFormat('yyyy-MMMM-dd,  HH:mm');
              //         String formatted = formatter.format(date);
              //         dateTimeValue = formatted;
              //       });
              //     }, currentTime: DateTime.now());
              //   },
              //   child: tcVisibility == false
              //       ? Text(
              //           'Choose Date and Time',
              //           style: TextStyle(
              //               color: Theme.of(context).primaryColorDark,
              //               fontSize: 18),
              //         )
              //       : Text(
              //           dateTimeValue,
              //           style: TextStyle(
              //               color: Theme.of(context).primaryColorDark,
              //               fontSize: 16),
              //         ),
              // ),
              Center(
                child: Text(
                  "Name ",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              Center(
                child: Text(
                  loadedMentor.name,
                  style: TextStyle(
                      letterSpacing: 2.0,
                      fontFamily: 'Nunito',
                      fontSize: 25.0,
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: Text(
                  "Choose a time slot ",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: 70.0,
                    decoration:
                        BoxDecoration(boxShadow: [], color: Colors.white),
                  ),
                  Positioned(
                    top: 0.0,
                    left: 15.0,
                    right: 15.0,
                    child: Container(
                      height: 70.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: noOfTimeSlots,
                        itemBuilder: (_, i) => Row(
                          children: <Widget>[
                            getCat2(
                                _editedSlots[i].time +
                                    '/' +
                                    _editedSlots[i].duration,
                                _editedSlots[i]),
                            SizedBox(width: 15.0),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: 25.0),
              Center(
                child: Text(
                  "What do you want to speak about?",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(height: 10.0),
              Stack(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          blurRadius: 1.0,
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2.0)
                    ], color: Colors.white),
                  ),
                  Positioned(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                    child: Container(
                      height: 60.0,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          getCat('Education'),
                          SizedBox(width: 15.0),
                          getCat('Career'),
                          SizedBox(width: 15.0),
                          getCat('Job skills'),
                          SizedBox(width: 15.0),
                          getCat('Studying abroad'),
                          SizedBox(width: 15.0),
                          getCat('General questions'),
                          SizedBox(width: 15.0),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text(
                'How can i help you? (optional)',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: " ",
                decoration: InputDecoration(
                  labelText: 'How can i help you?',
                ),
                // maxLines: 3,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) {
                  _editedSession = Session(
                    mentorId: mentorId,
                    time: _editedSession.time,
                    mainC: _editedSession.mainC,
                    description: value,
                    id: _editedSession.id,
                    duration: _editedSession.duration,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              editedSessionHaveValue() == true
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: InkWell(
                        onTap: () {
                          _saveForm();
                        },
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              color: Theme.of(context).accentColor),
                          child: Center(
                            child: Text(
                              'RESERVE',
                              style: TextStyle(
                                  letterSpacing: 2.0,
                                  fontFamily: 'FirSans',
                                  fontSize: 24.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: InkWell(
                        onTap: null,
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              color: Colors.grey),
                          child: Center(
                            child: Text(
                              'RESERVE',
                              style: TextStyle(
                                  letterSpacing: 2.0,
                                  // fontFamily: 'FirSans',
                                  fontSize: 24.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
