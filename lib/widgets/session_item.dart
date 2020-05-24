import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../chat/video_chat.dart';
import '../chat/audio_chat.dart';

import '../providers/session.dart';
import '../providers/sessions.dart';

import '../providers/mentors.dart';

import 'package:url_launcher/url_launcher.dart';

class SessionItem extends StatefulWidget {
  final Session sess;

  SessionItem(this.sess);

  @override
  _SessionItemState createState() => _SessionItemState();
}

class _SessionItemState extends State<SessionItem> {
  var whatsappUrl = ""; //whatsapp://send?phone=
 // 962797009913
  // var _expanded = false;
  var timeUntilSession;
  String sessionStartsIn;
  bool sessionStart = false;
  var parsedDateTimeValue;
  Color backColor = Colors.white;

  var _isLoading = false;

  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1),
        (Timer t) => getTime(widget.sess.time, widget.sess.duration));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<String> getTime(String time, String duration) {
    List<String> timeAndDuration = [time, duration];
    parsedDateTimeValue = DateTime.parse(timeAndDuration[0]);

    timeUntilSession = parsedDateTimeValue.difference(DateTime.now());

    if (timeUntilSession > Duration(days: 2)) {
      setState(() {
        timeUntilSession =
            parsedDateTimeValue.difference(DateTime.now()).inDays;
        sessionStartsIn =
            'Session starts in ' + timeUntilSession.toString() + ' Days';
        _isLoading = true;
      });
    } else if (timeUntilSession <= Duration(hours: 48) &&
        timeUntilSession >= Duration(hours: 1)) {
      setState(() {
        timeUntilSession =
            parsedDateTimeValue.difference(DateTime.now()).inHours + 1;
        sessionStartsIn =
            'Session starts in ' + timeUntilSession.toString() + ' Hours';
        _isLoading = true;
      });
    } else if (timeUntilSession <= Duration(minutes: 59) &&
        timeUntilSession > Duration(minutes: 1)) {
      setState(() {
        timeUntilSession =
            parsedDateTimeValue.difference(DateTime.now()).inMinutes + 1;
        sessionStartsIn =
            'Session starts in ' + timeUntilSession.toString() + ' Minutes';
        _isLoading = true;
      });
    } else if (timeUntilSession <= Duration(minutes: 1) &&
        timeUntilSession > Duration(seconds: 1)) {
      setState(() {
        timeUntilSession =
            parsedDateTimeValue.difference(DateTime.now()).inSeconds;
        sessionStartsIn =
            'Session starts in ' + timeUntilSession.toString() + ' Seconds';
        _isLoading = true;
      });
    } else if (timeUntilSession <= Duration(minutes: -30)) {
      setState(() {
        _isLoading = true;
        sessionStart = false;
        sessionStartsIn = 'Session Expired!';
        backColor = Colors.white54;
      });
    } else {
      setState(() {
        _isLoading = true;
        sessionStart = true;
        backColor = Colors.greenAccent;
      });
    }
    // print(timeUntilSession);

    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDateTimeValue);
    String startTime = DateFormat('kk:mm').format(parsedDateTimeValue);

    var formattedTime = parsedDateTimeValue
        .add(new Duration(minutes: int.parse(timeAndDuration[1])));
    String endTime = DateFormat('kk:mm').format(formattedTime);

    // time = 'Date: ' + formattedDate + '\n' + 'Time: ' + startTime + ' - ' + endTime;
    return [formattedDate, startTime + ' - ' + endTime];
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        final scaffold = Scaffold.of(context);
        try {
          await Provider.of<Sessions>(context, listen: false)
              .deleteSession(widget.sess.id);

          // Navigator.of(context).pop();
        } catch (error) {
          scaffold.showSnackBar(SnackBar(
            content: Text(
              'something went wrong! deleting failed',
              textAlign: TextAlign.center,
            ),
          ));
        }
        // Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Are you sure you want to delete this session?'),
      // content: Text("Are you sure you want to delete this mentor permenantly?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mentorName = Provider.of<Mentors>(
      context,
      listen: false,
    ).getNameById(widget.sess.mentorId);
    return _isLoading == true
        ? Card(
            color: backColor,
            margin: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Name : ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ),
                        Text(
                          mentorName,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Date : ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                            Text(
                              getTime(
                                  widget.sess.time, widget.sess.duration)[0],
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Time : ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                            Text(
                              getTime(
                                  widget.sess.time, widget.sess.duration)[1],
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ],
                    ),
                    // Text(
                    //   DateFormat('dd/mm/yyyy hh:mm').format(widget.sess.time),
                    // ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        showAlertDialog(context);
                      },
                    ),
                    // trailing: IconButton(
                    //   icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    //   onPressed: () {
                    //     setState(() {
                    //       _expanded = !_expanded;
                    //     });
                    //   },
                    // ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  height: 200,
                  child: sessionStart
                      ? Container(
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          VideoChat(
                                              displayName: 'User',
                                              mentorId: widget.sess.mentorId)));
                                },
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7.0),
                                      color: Colors.blue),
                                  child: Center(
                                    child: Text(
                                      'Start a Video Call',
                                      style: TextStyle(
                                          letterSpacing: 1.0,
                                          // fontFamily: 'FirSans',
                                          fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          AudioChat(
                                              displayName: 'User',
                                              mentorId: widget.sess.mentorId)));
                                },
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7.0),
                                      color: Colors.blue),
                                  child: Center(
                                    child: Text(
                                      'Start a Voice Call',
                                      style: TextStyle(
                                          letterSpacing: 1.0,
                                          // fontFamily: 'FirSans',
                                          fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              InkWell(
                                onTap: () async {
                                  await canLaunch(whatsappUrl)
                                      ? launch(whatsappUrl)
                                      : print(
                                          "open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
                                },
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7.0),
                                      color: Colors.blue),
                                  child: Center(
                                    child: Text(
                                      'Start a Text Chat',
                                      style: TextStyle(
                                          letterSpacing: 1.0,
                                          // fontFamily: 'FirSans',
                                          fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: null,
                          child: Container(
                            height: 50.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: Colors.grey),
                            child: Center(
                              child: Text(
                                sessionStartsIn,
                                style: TextStyle(
                                    letterSpacing: 1.0,
                                    fontFamily: 'FirSans',
                                    fontSize: 17.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                  // height: min(widget.sess.id.length * 20.0 + 10, 100),
                  // child: ListView(
                  //   children: widget.order.mentors
                  //       .map(
                  //         (prod) => Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: <Widget>[
                  //             Text(
                  //               prod.title,
                  //               style: TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             Text(
                  //               '${prod.quantity}x \$${prod.price}',
                  //               style: TextStyle(
                  //                 fontSize: 18,
                  //                 color: Colors.grey,
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       )
                  //       .toList(),
                  // ),
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          )
        : Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70,
                ),
                CircularProgressIndicator(),
                SizedBox(
                  height: 120,
                )
              ],
            ),
          );
  }
}
