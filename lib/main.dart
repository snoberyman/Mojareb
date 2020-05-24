import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './localization/localizations.dart';

import './providers/mentors.dart';
import './providers/auth.dart';
import './providers/reviews.dart';
import './providers/sessions.dart';
import './providers/slots.dart';

import './screens/mentors_overview_screen.dart';
import './screens/mentor_detail_screen.dart';
import './screens/sessions_screen.dart';
import './screens/mentors_screen.dart';
import './screens/edit_mentor_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash-screen.dart';
import './screens/mentors_sessions_screen.dart';

Future<Null> main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Mentors>(
          builder: (ctx, auth, previousMentors) => Mentors(
              auth.token,
              auth.userId,
              previousMentors == null ? [] : previousMentors.items),
        ),
        ChangeNotifierProxyProvider<Auth, Reviews>(
          builder: (ctx, auth, previousReviews) => Reviews(
              auth.token,
              auth.userId,
              previousReviews == null ? [] : previousReviews.items),
        ),
        ChangeNotifierProxyProvider<Auth, Sessions>(
          builder: (ctx, auth, previousReviews) => Sessions(
              auth.token,
              auth.userId,
              previousReviews == null ? [] : previousReviews.items),
        ),
        ChangeNotifierProxyProvider<Auth, Slots>(
          builder: (ctx, auth, previousReviews) => Slots(
              auth.token,
              auth.userId,
              previousReviews == null ? [] : previousReviews.items),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          title: 'Mojarebb',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            accentColor: Colors.lightBlueAccent,
            fontFamily: 'JannaLT',
          ),
          home: auth.isAuth
              ? ((auth.userId != 'bWmQdTmxWags6E7P30lPxvFo3i52')
                  ? MentorsOverviewScreen()
                  : MentorsScreen())
              : (FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                )),
          routes: {
            MentorDetailScreen.routeName: (ctx) => MentorDetailScreen(),
            SessionsScreen.routeName: (ctx) => SessionsScreen(),
            MentorsSessionsScreen.routeName: (ctx) => MentorsSessionsScreen(),
            MentorsScreen.routeName: (ctx) => MentorsScreen(),
            EditMentorscreen.routeName: (ctx) => EditMentorscreen(),
            // CartScreen.routeName: (ctx) => CartScreen(),
          },

          supportedLocales: [
            const Locale('en'), // English
            // const Locale('ar')
          ],
          locale : auth.userId != 'bWmQdTmxWags6E7P30lPxvFo3i52' 
          ? Locale('en', 'US')
          : Locale('en', 'US'),
        ),
      ),
    );
  }
}
