import 'dart:convert';
import 'package:ekom_ui/main.dart';
import 'package:ekom_ui/menu/main_menu_three.dart';
import 'package:ekom_ui/menu_two_items/Music_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../home_sub_screen/banner_slider_screen.dart';
import '../home_sub_screen/home_category.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _tvenableAll = false; // Add a variable to track tvenableAll status

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    // Simulate network request delay
    await Future.delayed(const Duration(seconds: 1));

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
        // Handle errors or non-200 responses
        print('Failed to load settings');
      }
    } catch (e) {
      // Handle network errors or JSON parsing errors
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   height: screenhgt*0.01,
            //   child: Text('.'),
            // ),
            // if (_tvenableAll) // Conditionally display SubVod
              Container(
                color: cardColor,
                height: screenhgt * 0.8,
                child: BannerSlider(),
              ),
            // if (_tvenableAll) // Conditionally display SubVod
              Container(
                color: cardColor,
                child: SizedBox(
                  height: screenhgt * 0.6,
                  child: MusicScreen(),
                ),
              ),
              Container(
                color: cardColor,
                child: SizedBox(
                  height: screenhgt * 0.5,
                  child: MainMenuThree(),
                ),
              ),
            Container(
              color: cardColor,
              child: SizedBox(
                height: screenhgt * 4,
                child: HomeCategory(),
              ),
            ),
            Container(
              height: 0,
              child: Text(''),
            ),
            if (_isLoading)
              // ...[
              // const Padding(
              // padding: EdgeInsets.symmetric(vertical: 20),
              // child:
              Center(
                child: SpinKitFadingCircle(
                  color: borderColor,
                  size: 50.0,
                ),
              ),
            // ),
            // ],
          ],
        ),
      ),
    );
  }
}
