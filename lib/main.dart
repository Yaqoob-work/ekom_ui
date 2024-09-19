import 'dart:convert';
import 'dart:io';
// import 'package:ekom_ui/live_sub_screen/all_channel.dart';
import 'package:ekom_ui/live_sub_screen/entertainment_screen.dart';
import 'package:ekom_ui/menu_one_item/home_screen.dart';
import 'package:ekom_ui/menu_one_item/search_screen.dart';
import 'package:ekom_ui/menu_one_item/splash_screen.dart';
import 'package:ekom_ui/menu_one_item/vod.dart';
import 'package:http/http.dart' as https;
import 'package:flutter/material.dart';
import 'menu/top_navigation_bar.dart';
import 'menu_one_item/live_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

var highlightColor;
var cardColor;
var hintColor;
var borderColor;

var screenhgt;
var screenwdt;
var screensz;

var localImage;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    screenhgt = MediaQuery.of(context).size.height;
    screenwdt = MediaQuery.of(context).size.width;
    screensz = MediaQuery.of(context).size;
    highlightColor = Colors.blue;
    cardColor = Color.fromARGB(255, 8, 1, 34);
    hintColor = Colors.white;
    borderColor = Color.fromARGB(255, 247, 6, 118);
    localImage = Image.asset('assets/logo.png');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        // '/myhome': (context) => MyHomePage(),
        // '/category': (context) => HomeCategory(),
        // '/search': (context) => SearchScreen(),
        // '/vod': (context) => VOD(),
        '/live': (context) => MyHome(),
        // '/live': (context) => AllChannel(),
      },
    );
  }
}


class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _selectedPage = 0;
  late PageController _pageController;
  bool _tvenableAll = false; // Track tvenableAll status

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPage);
    _fetchTvenableAllStatus(); // Fetch tvenableAll status
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageSelected(int index) {
    setState(() {
      _selectedPage = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<void> _fetchTvenableAllStatus() async {
    try {
      final response = await https.get(
        Uri.parse('https://api.ekomflix.com/android/getSettings'),
        headers: {
          'x-api-key': 'vLQTuPZUxktl5mVW',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tvenableAll = data['tvenableAll'] == 1;
        });
      } else {
        print('Failed to load settings');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      // Your LiveScreen content pages
      HomeScreen(),
      VOD(),
      EntertainmentScreen(),
      LiveScreen(),
      SearchScreen(),
      // ReligiousScreen(),
      // EntertainmentScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedPage = index;
                });
              },
              children: pages,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: TopNavigationBar(
                selectedPage: _selectedPage,
                onPageSelected: _onPageSelected,
                tvenableAll: _tvenableAll,
              ),
          ),
        ],
      ),
    );
  }
}
