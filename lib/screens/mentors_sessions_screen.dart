import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sessions.dart' show Sessions;

import '../widgets/mentors_session_item.dart' as ses;
import '../widgets/mentors_app_drawer.dart';

class MentorsSessionsScreen extends StatefulWidget {
  static const routeName = '/mentorssessions';

  @override
  _MentorsSessionsScreenState createState() => _MentorsSessionsScreenState();
}

class _MentorsSessionsScreenState extends State<MentorsSessionsScreen> {
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Sessions>(context, listen: false).fetchAndSetSessions();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<Sessions>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('all sessions'),
      ),
      drawer: MentorsAppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessionData.items.length,
              itemBuilder: (ctx, i) => ses.MentorsSessionItem(sessionData.items[i]),
            ),
    );
  }
}
