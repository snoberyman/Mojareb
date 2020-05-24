import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../screens/mentor_detail_screen.dart';

import '../providers/mentor.dart';
import '../providers/reviews.dart';

// import '../providers/cart.dart';
// import '../providers/auth.dart';

class MentorItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // MentorItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final mentor = Provider.of<Mentor>(context, listen: false);
    // final cart = Provider.of<Cart>(context, listen: false);
    // final authData = Provider.of<Auth>(context, listen: false);

    final reviews = Provider.of<Reviews>(context, listen: false);
    double reviewsAvg = reviews.findReviewsAvgById(mentor.id);
    int reviewsCount = reviews.reviewsCount(mentor.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              MentorDetailScreen.routeName,
              arguments: mentor.id,
            );
          },
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Image.network(
                  mentor.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                flex: 7,
                child: Text(mentor.title),
              ),
            ],
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          // leading: Consumer<Mentor>(
          //   builder: (ctx, mentor, _) => IconButton(
          //     icon: Icon(
          //         mentor.isFavorite ? Icons.favorite : Icons.favorite_border),
          //     onPressed: () {
          //       mentor.toggleFavoriteStatus(
          //         authData.token,
          //         authData.userId,
          //       );
          //     },
          //     color: Theme.of(context).accentColor,
          //   ),
          // ),
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RatingBarIndicator(
                  rating: reviewsAvg,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 10.0,
                  direction: Axis.horizontal,
                ),
                Text(
                  " ("+reviewsCount.toString()+")",
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          leading: Text(
            mentor.name,
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white),
          ),
          trailing: IconButton(
            icon: Icon(Icons.more),
            onPressed: () {
              Navigator.of(context).pushNamed(
                MentorDetailScreen.routeName,
                arguments: mentor.id,
              );
            },
            color: Theme.of(context).accentColor,
          ),
          // trailing: IconButton(
          //   icon: Icon(Icons.shopping_cart),
          //   onPressed: () {
          //     cart.addItem(mentor.id, mentor.price, mentor.title);
          //     Scaffold.of(context).hideCurrentSnackBar();
          //     Scaffold.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text('added item to cart'),
          //         duration: Duration(seconds: 2),
          //         action: SnackBarAction(
          //           label: 'UNDO',
          //           onPressed: () {
          //             cart.removeSingleItem(mentor.id);
          //           },
          //         ),
          //       ),
          //     );
          //   },
          //   color: Theme.of(context).accentColor,
          // ),
        ),
      ),
    );
  }
}
