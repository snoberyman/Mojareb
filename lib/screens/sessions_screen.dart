import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sessions.dart' show Sessions;

import '../widgets/session_item.dart' as ses;
import '../widgets/app_drawer.dart';

class SessionsScreen extends StatefulWidget {
  static const routeName = '/sessions';

  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
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
        title: Text('Sessions'),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessionData.items.length,
              itemBuilder: (ctx, i) => ses.SessionItem(sessionData.items[i]),
            ),
    );
  }
}


// elegant approach
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/orders.dart' show Orders;
// import '../widgets/order_item.dart';
// import '../widgets/app_drawer.dart';

// class SessionsScreen extends StatelessWidget {
//   static const routeName = '/orders';

//   @override
//   Widget build(BuildContext context) {
//     print('building orders');
//     // final orderData = Provider.of<Orders>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Orders'),
//       ),
//       drawer: AppDrawer(),
//       body: FutureBuilder(
//         future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
//         builder: (ctx, dataSnapshot) {
//           if (dataSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else {
//             if (dataSnapshot.error != null) {
//               // ...
//               // Do error handling stuff
//               return Center(
//                 child: Text('An error occurred!'),
//               );
//             } else {
//               return Consumer<Orders>(
//                 builder: (ctx, orderData, child) => ListView.builder(
//                       itemCount: orderData.orders.length,
//                       itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
//                     ),
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }
