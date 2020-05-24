import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_webrtc/webrtc.dart';

enum SignalingState {
  CallStateOutgoing,
  CallStateIncoming,
  CallStateConnected,
  CallStateIdle,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

/*
 * callbacks for Signaling API.
 */
typedef void SignalingStateCallback(SignalingState state, String peerId);

typedef void StreamStateCallback(MediaStream stream);

typedef void OtherEventCallback(dynamic event);

typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);

typedef void DataChannelCallback(RTCDataChannel dc);

class Signaling {
  var _socket;
  var _sessionId;
  SignalingState _callState;
  var _lastOffer;
  var _host;
  var _port = 4443;
  var _selfId;
  var _displayName;
  var _peerConnections = new Map<String, RTCPeerConnection>();
  var _dataChannels = new Map<String, RTCDataChannel>();
  var _remoteCandidates = [];

  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
       */
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  Signaling(this._host, this._selfId, this._displayName);

  close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    _peerConnections.forEach((key, pc) {
      pc.close();
    });

    if (_socket != null) _socket.close();

    this.onStateChange = null;
    this.onPeersUpdate = null;
  }

  void switchCamera() {
    if (_localStream != null) {
      _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void raiseStateChange(SignalingState signalingState, [String peerId]) {
    _callState = signalingState;
    if (this.onStateChange != null) {
      this.onStateChange(signalingState, peerId);
    }
  }

  void invite(String peerId, String media, useScreen) {
    this._sessionId = _selfId + '-' + peerId;

    raiseStateChange(SignalingState.CallStateOutgoing);

    _createPeerConnection(peerId, media, useScreen).then((pc) {
      _peerConnections[peerId] = pc;
      if (media == 'data') {
        _createDataChannel(peerId, pc);
      }
      _createOffer(peerId, pc, media);
    });
  }

  void bye() {
    if (this._sessionId != null)
      _send('bye', {
        'session_id': this._sessionId,
        'from': _selfId,
      });
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];

    switch (mapData['type']) {
      case 'peers':
        {
          List<dynamic> peers = data;
          if (this.onPeersUpdate != null) {
            Map<String, dynamic> event = new Map<String, dynamic>();
            event['self'] = _selfId;
            event['peers'] = peers;
            peers.removeWhere((i) => i['id'] == _selfId);
            this.onPeersUpdate(event);
          }
        }
        break;
      //Incoming call
      case 'offer':
        {
          if (_callState == SignalingState.CallStateIdle) {
            var media = data['media'];
            if (media == 'video') {
              _lastOffer = data;
              var id = data['from'];
              var description = data['description'];
              var sessionId = data['session_id'];
              this._sessionId = sessionId;

              raiseStateChange(SignalingState.CallStateIncoming, id);

              var pc = await _createPeerConnection(id, media, false);
              _peerConnections[id] = pc;
              await pc.setRemoteDescription(new RTCSessionDescription(
                  description['sdp'], description['type']));
              //await _createAnswer(id, pc, media);
              if (this._remoteCandidates.length > 0) {
                _remoteCandidates.forEach((candidate) async {
                  await pc.addCandidate(candidate);
                });
                _remoteCandidates.clear();
              }
            }
          }
        }
        break;
      case 'answer':
        {
          var id = data['from'];
          var description = data['description'];

          var pc = _peerConnections[id];
          if (pc != null) {
            await pc.setRemoteDescription(new RTCSessionDescription(
                description['sdp'], description['type']));

            raiseStateChange(SignalingState.CallStateConnected);
          }
        }
        break;
      case 'candidate':
        {
          var id = data['from'];
          var candidateMap = data['candidate'];
          var pc = _peerConnections[id];
          RTCIceCandidate candidate = new RTCIceCandidate(
              candidateMap['candidate'],
              candidateMap['sdpMid'],
              candidateMap['sdpMLineIndex']);
          if (pc != null) {
            await pc.addCandidate(candidate);
          } else {
            _remoteCandidates.add(candidate);
          }
        }
        break;
      case 'leave':
        {
          var id = data;
          _peerConnections.remove(id);
          _dataChannels.remove(id);

          if (_localStream != null) {
            _localStream.dispose();
            _localStream = null;
          }

          var pc = _peerConnections[id];
          if (pc != null) {
            pc.close();
            _peerConnections.remove(id);
          }
          this._sessionId = null;
          raiseStateChange(SignalingState.CallStateIdle);
        }
        break;
      case 'bye':
        {
          var to = data['to'];
          var sessionId = data['session_id'];
          print('bye: ' + sessionId);

          if (_localStream != null) {
            _localStream.dispose();
            _localStream = null;
          }

          var pc = _peerConnections[to];
          if (pc != null) {
            pc.close();
            _peerConnections.remove(to);
          }

          var dc = _dataChannels[to];
          if (dc != null) {
            dc.close();
            _dataChannels.remove(to);
          }

          this._sessionId = null;
          raiseStateChange(SignalingState.CallStateIdle);
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  Future<WebSocket> _connectForSelfSignedCert(String host, int port) async {
    try {
      Random r = new Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
      SecurityContext securityContext = new SecurityContext();
      HttpClient client = HttpClient(context: securityContext);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        print('Allow self-signed certificate => $host:$port. ');
        return true;
      };

      HttpClientRequest request = await client.getUrl(
          Uri.parse('https://$host:$port/ws')); // form the correct url here
      request.headers.add('Connection', 'Upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add(
          'Sec-WebSocket-Version', '13'); // insert the correct version here
      request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

      HttpClientResponse response = await request.close();
      // Socket socket = await response.detachSocket();
      var webSocket = WebSocket.fromUpgradedSocket(
        await response.detachSocket(),
        protocol: 'signaling',
        serverSide: false,
      );

      return webSocket;
    } catch (e) {
      throw e;
    }
  }

  void connect() async {
    try {
      /*
      var url = 'ws://$_host:$_port';
      _socket = await WebSocket.connect(url);
      */
      _socket = await _connectForSelfSignedCert(_host, _port);

      raiseStateChange(SignalingState.ConnectionOpen);

      _socket.listen((data) {
        print('Received data: ' + data);
        JsonDecoder decoder = new JsonDecoder();
        this.onMessage(decoder.convert(data));
      }, onDone: () async {
        print('Closed by server!');
        raiseStateChange(SignalingState.ConnectionClosed);
      });

      _send('new', {
        'name': _displayName,
        'id': _selfId,
        'user_agent':
            'flutter-webrtc/' + Platform.operatingSystem + '-plugin 0.1.7'
      });

      raiseStateChange(SignalingState.CallStateIdle);
    } catch (e) {
      raiseStateChange(SignalingState.ConnectionError);
    }
  }

  Future<MediaStream> createStream(media, userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = userScreen
        ? await navigator.getDisplayMedia(mediaConstraints)
        : await navigator.getUserMedia(mediaConstraints);
    if (this.onLocalStream != null) {
      this.onLocalStream(stream);
    }
    return stream;
  }

  _createPeerConnection(id, media, userScreen) async {
    if (media != 'data') _localStream = await createStream(media, userScreen);

    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);

    if (media != 'data') pc.addStream(_localStream);

    pc.onIceCandidate = (candidate) {
      _send('candidate', {
        'to': id,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': this._sessionId,
      });
    };

    pc.onIceConnectionState = (state) {};

    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
      //_remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage(channel, data);
    };
    _dataChannels[id] = channel;

    if (this.onDataChannel != null) this.onDataChannel(channel);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(String id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s = await pc
          .createOffer(media == 'data' ? _dcConstraints : _constraints);

      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._sessionId,
        'media': media,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void answer() {
    var id = _lastOffer['from'];
    _createAnswer(id, _peerConnections[id], _lastOffer['media']);
  }

  _createAnswer(String id, RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dcConstraints : _constraints);

      pc.setLocalDescription(s);
      _send('answer', {
        'to': id,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._sessionId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _send(event, data) {
    data['type'] = event;

    JsonEncoder encoder = new JsonEncoder();

    if (_socket != null) _socket.add(encoder.convert(data));

    print('send: ' + encoder.convert(data));
  }
}
