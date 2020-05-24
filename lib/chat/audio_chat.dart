import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_incall_manager/incall.dart';
import 'package:uuid/uuid.dart';

import './audio_signaling.dart';

import '../screens/add_review_screen.dart';

// import '../localization/localizations.dart';
//import 'package:flutter_cupertino_localizations/flutter_cupertino_localizations.dart';

class AudioChat extends StatefulWidget {
  final String ip = "95.110.175.35";
  final String displayName;
  final String mentorId;

  AudioChat({Key key, @required this.displayName, @required this.mentorId})
      : super(key: key);

  @override
  _AudioChatState createState() => new _AudioChatState(
      serverIP: ip, displayName: displayName, mentorId: mentorId);
}

class _AudioChatState extends State<AudioChat> {
  Signaling _signaling;
  List<dynamic> _peers;
  var _currentPeer;
  var _selfId;
  SignalingState _callState;
  bool _connected = false;

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  final String displayName;
  final String mentorId;
  String clientId;
  final String serverIP;
  SharedPreferences prefs;

  IncallManager incall = new IncallManager();

  _AudioChatState(
      {Key key,
      @required this.serverIP,
      @required this.displayName,
      @required this.mentorId});

  @override
  initState() {
    super.initState();

    incall.checkRecordPermission();
    incall.requestRecordPermission();
    incall.checkCameraPermission();
    incall.requestCameraPermission();

    _init();
    _connect();
  }

  _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();

    if (_signaling != null) {
      _hangUp();
      _signaling.close();
    }

    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    clientId = prefs.getString('clientId');

    if (clientId == null) {
      clientId = new Uuid().v1();
      prefs.setString('clientId', clientId);
    }

    if (_signaling == null) {
      _signaling = new Signaling(serverIP, clientId, displayName)..connect();

      _signaling.onStateChange = (SignalingState state, String peerId) {
        switch (state) {
          case SignalingState.CallStateOutgoing:
            incall
                .start({'media': '', 'auto': true, 'ringback': '_DTMF_'});
            this.setState(() {
              _callState = state;
            });
            break;
          case SignalingState.CallStateIdle:
            _currentPeer = null;
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _callState = state;
            });

            incall.stopRingtone();

            incall.stop({'busytone': '_DTMF_'});
            break;
          case SignalingState.CallStateConnected:
            incall.stopRingback();
            incall.stopRingtone();
            incall.start({'media': '', 'auto': true, 'ringback': ''});
            this.setState(() {
              _callState = state;
            });
            break;
          case SignalingState.CallStateIncoming:
            _currentPeer = _peers.singleWhere((i) => i['id'] == peerId);
            incall.startRingtone('DEFAULT', 'default', 30);
            this.setState(() {
              _callState = state;
            });
            break;
          case SignalingState.ConnectionClosed:
            this.setState(() {
              _connected = false;
            });
            break;
          case SignalingState.ConnectionError:
            this.setState(() {
              _connected = false;
            });
            break;
          case SignalingState.ConnectionOpen:
            this.setState(() {
              _connected = true;
            });
            break;
        }
      };

      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          _selfId = event['self'];
          _peers = event['peers'];
        });
      });

      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
        _localRenderer.mirror = true;
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });
    }
  }

  _invitePeer(context, peerId, useScreen) async {
    if (_signaling != null && peerId != _selfId) {
      _currentPeer = _peers.singleWhere((i) => i['id'] == peerId);
      _signaling.invite(peerId, 'video', useScreen);
    }
  }

  _hangUp() {
    incall.stopRingtone();

    incall.stop({'busytone': '_DTMF_'});

    if (_signaling != null) {
      _signaling.bye();
    }
  }

  _pickUp() {
    if (_signaling != null) {
      _signaling.answer();
      _signaling.raiseStateChange(SignalingState.CallStateConnected);
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  // _buildRow(context, peer) {
  //   return ListBody(children: <Widget>[
  //     ListTile(
  //       title: Text(peer['name']),
  //       onTap: null,
  //       trailing: new SizedBox(
  //           width: 100.0,
  //           child: new Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: <Widget>[
  //                 IconButton(
  //                   icon: const Icon(Icons.videocam),
  //                   onPressed: () => peer['session_id'] == null
  //                       ? _invitePeer(context, peer['id'], false)
  //                       : null,
  //                   tooltip: 'Video calling',
  //                 )
  //               ])),
  //       subtitle: peer['session_id'] != null
  //           ? Text(AppLocalizations.of(context).busy,
  //               style: TextStyle(color: Colors.red))
  //           : Text(AppLocalizations.of(context).free,
  //               style: TextStyle(color: Colors.green)),
  //     ),
  //     Divider()
  //   ]);
  // }

  _buildRow(context, peer) {
    return ListBody(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 50),
          Container(
            child: Text(peer['name'], style: TextStyle(fontSize: 40)),
          ),
          peer['session_id'] != null
              ? Text('busy',
                  style: TextStyle(color: Colors.red))
              : Text('free',
                  style: TextStyle(color: Colors.green)),
          SizedBox(height: 20),
          Container(
            child: SizedBox(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.videocam,
                    //     color: Colors.blue,
                    //     size: 30,
                    //   ),
                    //   onPressed: () => peer['session_id'] == null
                    //       ? _invitePeer(context, peer['id'], false)
                    //       : null,
                    //   tooltip: 'Video calling',
                    // ),
                    RaisedButton.icon(
                      onPressed: () => peer['session_id'] == null
                          ? _invitePeer(context, peer['id'], false)
                          : null,
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.blue,
                        size: 25,
                      ),
                      label: Text('Voice Call'),
                    ),
                  ]),
            ),
          ),
        ],
      ),
      SizedBox(height: 50),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var floatingActionButtons = <Widget>[
      FloatingActionButton(
        child: const Icon(Icons.switch_camera),
        onPressed: _switchCamera,
      ),
      FloatingActionButton(
        onPressed: () {
          _hangUp();
        },
        tooltip: 'Hangup',
        child: new Icon(Icons.call_end),
        backgroundColor: Colors.pink,
      ),
      FloatingActionButton(
        onPressed: () {
          _hangUp();
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => AddReviewscreen(
                      mentorId: mentorId,
                    )));
          });
        },
        tooltip: 'EndSession',
        
        child: Text('End Session',style: TextStyle(fontSize: 12),textAlign: TextAlign.center,),
        backgroundColor: Colors.red,
      )
    ];

    if (_callState == SignalingState.CallStateIncoming)
      floatingActionButtons.add(FloatingActionButton(
        onPressed: _pickUp,
        tooltip: 'Pickup',
        child: Icon(Icons.call),
        backgroundColor: Colors.green,
      ));

    return Scaffold(
      appBar: AppBar(
        title: Text('بدء جلسة صوت'),
        actions: <Widget>[
          IconButton(
              icon: _connected
                  ? const Icon(Icons.cloud_done)
                  : const Icon(Icons.cloud_off),
              onPressed: null),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _callState == SignalingState.CallStateIncoming ||
              _callState == SignalingState.CallStateOutgoing ||
              _callState == SignalingState.CallStateConnected
          ? new SizedBox(
              width: 200.0,
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: floatingActionButtons))
          : null,
      body: _callState == SignalingState.CallStateIncoming ||
              _callState == SignalingState.CallStateOutgoing ||
              _callState == SignalingState.CallStateConnected
          ? OrientationBuilder(builder: (context, orientation) {
              return Container(
                child: Stack(children: <Widget>[
                  Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: new Container(
                        margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          children: <Widget>[
                            new Text(_currentPeer['name'],
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                            Expanded(child: new RTCVideoView(_remoteRenderer)),
                          ],
                        ),
                        decoration: new BoxDecoration(color: Colors.black54),
                      )),
                  new Positioned(
                    left: 20.0,
                    top: 20.0,
                    child: new Container(
                      width: orientation == Orientation.portrait ? 90.0 : 120.0,
                      height:
                          orientation == Orientation.portrait ? 120.0 : 90.0,
                      child: new RTCVideoView(_localRenderer),
                      decoration: new BoxDecoration(color: Colors.black54),
                    ),
                  ),
                ]),
              );
            })
          : _peers == null || _peers.length == 0
              ? Center(
                  child: _connected
                      ? Text(
                          'Mentor Currently not Available',
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                        )
                      : CircularProgressIndicator(),
                  // child: Text(
                  //   _connected
                  //       ? AppLocalizations.of(context).nobodyConnected
                  //       : AppLocalizations.of(context).serviceNotAvailable,
                  //   style: TextStyle(fontSize: 20.0),
                  //   textAlign: TextAlign.center,
                  // ),
                )
              : new ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0.0),
                  itemCount: (_peers.length),
                  itemBuilder: (ctx, i) {
                    return _buildRow(context, _peers[i]);
                  }),
    );
  }
}
