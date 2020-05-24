import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_mentor_screen.dart';

import '../chat/video_chat_mentor.dart';
import '../chat/audio_chat_mentor.dart';


import '../providers/mentors.dart';
import '../providers/slots.dart';

import '../widgets/user_mentor_item.dart';
import '../widgets/mentors_app_drawer.dart';

class MentorsScreen extends StatelessWidget {
  static const routeName = '/user-Mentors';

  Future<void> _refreshMentors(BuildContext context) async {
    await Provider.of<Mentors>(context, listen: false).fetchAndSetMentors(true);
    await Provider.of<Slots>(context, listen: false).fetchAndSetSlots(true);
  }

  @override
  Widget build(BuildContext context) {
    //final MentorsData = Provider.of<Mentors>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Mentors'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditMentorscreen.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          VideoChatMentor(displayName: 'mentor')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AudioChat(displayName: 'mentor')));
            },
          ),
        ],
      ),
      drawer: MentorsAppDrawer(),
      body: FutureBuilder(
        future: _refreshMentors(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshMentors(context),
                    child: Consumer<Mentors>(
                      builder: (ctx, mentorsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: mentorsData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: <Widget>[
                              UserMentorItem(
                                mentorsData.items[i].id,
                                mentorsData.items[i].name,
                                mentorsData.items[i].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
