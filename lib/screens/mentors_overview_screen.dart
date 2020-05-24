import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mentors.dart';
import '../providers/reviews.dart';

import '../widgets/mentors_grid.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  Favorites,
  All,
}

class MentorsOverviewScreen extends StatefulWidget {
  @override
  _MentorsOverviewScreenState createState() => _MentorsOverviewScreenState();
}

class _MentorsOverviewScreenState extends State<MentorsOverviewScreen> {
  var _showOnlyFavorite = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Mentors>(context).fetchAndSetMentors(); //won't wor;
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Mentors>(context).fetchAndSetMentors();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Mentors>(context).fetchAndSetMentors().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      Provider.of<Reviews>(context).fetchAndSetReviews().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مجرّب'),
        // actions: <Widget>[
        //   PopupMenuButton(
        //     onSelected: (FilterOptions selectedValue) {
        //       setState(() {
        //         if (selectedValue == FilterOptions.Favorites) {
        //           _showOnlyFavorite = true;
        //         } else {
        //           _showOnlyFavorite = false;
        //         }
        //       });
        //     },
        //     icon: Icon(Icons.more_vert),
        //     itemBuilder: (_) => [
        //       PopupMenuItem(
        //         child: Text('Only Favorites'),
        //         value: FilterOptions.Favorites,
        //       ),
        //       PopupMenuItem(
        //         child: Text('Show All'),
        //         value: FilterOptions.All,
        //       ),
        //     ],
        //   ),
        //   Consumer<Cart>(
        //     builder: (_, cart, ch) => Badge(
        //       child: ch,
        //       value: cart.itemCount.toString(),
        //     ),
        //     child: IconButton(
        //       icon: Icon(Icons.shopping_cart),
        //       onPressed: () {
        //         Navigator.of(context).pushNamed(CartScreen.routeName);
        //       },
        //     ),
        //   ),
        // ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : MentorsGrid(_showOnlyFavorite),
    );
  }
}
