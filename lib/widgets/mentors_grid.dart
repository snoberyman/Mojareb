import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './mentor_item.dart';

import '../providers/mentors.dart';

class MentorsGrid extends StatelessWidget {
  final bool showFavs;

  MentorsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final mentorsData = Provider.of<Mentors>(context);
    final mentors = showFavs ? mentorsData.favoriteItems : mentorsData.items;
    return GridView.builder(
      padding: const EdgeInsets.only(left:10.0,right: 10),
      itemCount: mentors.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: mentors[i],
        child: MentorItem(
            // Mentors[i].id,
            // Mentors[i].title,
            // Mentors[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.9 / 1,
        crossAxisSpacing: 100,
        mainAxisSpacing: 10,
      ),
    );
  }
}
