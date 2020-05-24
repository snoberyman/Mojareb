import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import '../widgets/mentors_app_drawer.dart';


enum FilterOptions {
  Favorites,
  All,
}


class MentorProfilesScreen extends StatefulWidget {
  @override
  _MentorProfilescreenState createState() => _MentorProfilescreenState();
}

class _MentorProfilescreenState extends State<MentorProfilesScreen> {
  // var _showOnlyFavorite = false;
  // var _isInit = true;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mojareb'),
        actions: <Widget>[
          // PopupMenuButton(
          //   onSelected: (FilterOptions selectedValue) {
          //     setState(() {
          //       if (selectedValue == FilterOptions.Favorites) {
          //         _showOnlyFavorite = true;
          //       } else {
          //         _showOnlyFavorite = false;
          //       }
          //     });
          //   },
          //   icon: Icon(Icons.more_vert),
          //   itemBuilder: (_) => [
          //     PopupMenuItem(
          //       child: Text('Only Favorites'),
          //       value: FilterOptions.Favorites,
          //     ),
          //     PopupMenuItem(
          //       child: Text('Show All'),
          //       value: FilterOptions.All,
          //     ),
          //   ],
          // ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: MentorsAppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Text('HELLOOO'),
    );
  }
}