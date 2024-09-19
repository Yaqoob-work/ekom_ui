




// import 'dart:async';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:ekom_ui/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:palette_generator/palette_generator.dart';
// import '../video_widget/socket_service.dart';
// import '../video_widget/vlc_player_screen.dart';

// void main() {
//   runApp(NewsScreen());
// }

// class NewsScreen extends StatefulWidget {
//   @override
//   _NewsScreenState createState() => _NewsScreenState();
// }

// class _NewsScreenState extends State<NewsScreen> {
//   List<dynamic> entertainmentList = [];
//   List<int> allowedChannelIds = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   bool _isNavigating = false;
//   bool tvenableAll = false;
//   final SocketService _socketService = SocketService();
//   int _maxRetries = 3;
//   int _retryDelay = 5; // seconds

//   @override
//   void initState() {
//     super.initState();
//     _socketService.initSocket();
//     fetchSettings();
//   }

//   Future<void> fetchSettings() async {
//     try {
//       final response = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getSettings'),
//         headers: {
//           'x-api-key': 'vLQTuPZUxktl5mVW',
//         },
//       );

//       if (response.statusCode == 200) {
//         final settingsData = json.decode(response.body);
//         setState(() {
//           allowedChannelIds = List<int>.from(settingsData['channels']);
//           tvenableAll = settingsData['tvenableAll'] == 1;
//         });

//         fetchEntertainment();
//       } else {
//         throw Exception('Something Went Wrong');
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Something Went Wrong';
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchEntertainment() async {
//     try {
//       final response = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
//         headers: {
//           'x-api-key': 'vLQTuPZUxktl5mVW',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body);

//         setState(() {
//           entertainmentList = responseData.where((channel) {
//             int channelId = int.tryParse(channel['id'].toString()) ?? 0;
//             String channelGenres = channel['genres'].toString();
//             String channelStatus = channel['status'].toString();

//             return channelGenres.contains('News') &&
//                 channelStatus == "1" &&
//                 (tvenableAll || allowedChannelIds.contains(channelId));
//           }).map((channel) {
//             channel['isFocused'] = false;
//             channel['dominantColor'] = Colors.black.withOpacity(0.5); // Default color
//             return channel;
//           }).toList();
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Something Went Wrong');
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Something Went Wrong';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: isLoading
//           ? Center(
//               child: SpinKitFadingCircle(
//                 color: borderColor,
//                 size: 50.0,
//               ),
//             )
//           : errorMessage.isNotEmpty
//               ? Center(
//                   child: Text(
//                     errorMessage,
//                     style: TextStyle(fontSize: 20, color: hintColor),
//                   ),
//                 )
//               : entertainmentList.isEmpty
//                   ? Center(
//                       child: Text('Something Went Wrong',
//                           style: TextStyle(color: hintColor)))
//                   : Padding(
//                       padding: EdgeInsets.only(top: screenhgt * 0.1),
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: entertainmentList.length,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: () => _navigateToVideoScreen(
//                                 context, entertainmentList[index]),
//                             child: _buildGridViewItem(index),
//                           );
//                         },
//                       ),
//                     ),
//     );
//   }

//   Widget _buildGridViewItem(int index) {
//     return Focus(
//       onKeyEvent: (node, event) {
//         if (event is KeyDownEvent &&
//             event.logicalKey == LogicalKeyboardKey.select) {
//           _navigateToVideoScreen(context, entertainmentList[index]);
//           return KeyEventResult.handled;
//         }
//         return KeyEventResult.ignored;
//       },
//       onFocusChange: (hasFocus) async {
//         setState(() {
//           entertainmentList[index]['isFocused'] = hasFocus;
//         });

//         if (hasFocus) {
//           Color dominantColor =
//               await _getPaletteColor(entertainmentList[index]['banner'] ?? '');
//           setState(() {
//             entertainmentList[index]['dominantColor'] = dominantColor;
//           });
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Stack(
//             children: [
//               AnimatedContainer(
//                 curve: Curves.ease,
//                 width: screenwdt * 0.19,
//                 height: entertainmentList[index]['isFocused']
//                     ? screenhgt * 0.22
//                     : screenhgt * 0.2,
//                 duration: const Duration(milliseconds: 300),
//                 decoration: BoxDecoration(
//                   border: entertainmentList[index]['isFocused']
//                       ? Border.all(
//                           color: entertainmentList[index]['dominantColor'] ??
//                               hintColor,
//                           width: 3.0,
//                         )
//                       : Border.all(
//                           color: Colors.transparent,
//                           width: 3.0,
//                         ),
//                   boxShadow: entertainmentList[index]['isFocused']
//                       ? [
//                           BoxShadow(
//                             color: entertainmentList[index]['dominantColor'] ??
//                                 Colors.black.withOpacity(0.5),
//                             blurRadius: 25.0,
//                             spreadRadius: 10.0,
//                           ),
//                         ]
//                       : [],
//                 ),
//                 child: CachedNetworkImage(
//                   imageUrl: entertainmentList[index]['banner'] ?? '',
//                   placeholder: (context, url) => localImage,
//                   width: screenwdt * 0.19,
//                   height: entertainmentList[index]['isFocused']
//                       ? screenhgt * 0.22
//                       : screenhgt * 0.2,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Container(
//             width: screenwdt * 0.19,
//             child: Column(
//               children: [
//                 Text(
//                   (entertainmentList[index]['name'] ?? 'Unknown')
//                       .toString()
//                       .toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: entertainmentList[index]['isFocused']
//                         ? entertainmentList[index]['dominantColor'] ??
//                             highlightColor
//                         : Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   entertainmentList[index]['description'] ?? 'No description available',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: entertainmentList[index]['isFocused']
//                         ? entertainmentList[index]['dominantColor']?.withOpacity(0.8) ??
//                             highlightColor.withOpacity(0.8)
//                         : Colors.white.withOpacity(0.8),
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<Color> _getPaletteColor(String imageUrl) async {
//     try {
//       final imageProvider = CachedNetworkImageProvider(imageUrl);
//       final paletteGenerator =
//           await PaletteGenerator.fromImageProvider(imageProvider);
//       return paletteGenerator.dominantColor?.color ??
//           Colors.white.withOpacity(0.5);
//     } catch (e) {
//       print('Error fetching palette: $e');
//       return Colors.black.withOpacity(0.5);
//     }
//   }

//   void _navigateToVideoScreen(
//       BuildContext context, dynamic entertainmentItem) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     bool shouldPlayVideo = true;
//     bool shouldPop = true;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             shouldPlayVideo = false;
//             shouldPop = false;
//             return true;
//           },
//           child: Center(
//             child: SpinKitFadingCircle(
//               color: borderColor,
//               size: 50.0,
//             ),
//           ),
//         );
//       },
//     );

//     Timer(Duration(seconds: 5), () {
//       _isNavigating = false;
//     });

//     try {
//       if (entertainmentItem['stream_type'] == 'YoutubeLive') {
//         for (int i = 0; i < _maxRetries; i++) {
//           try {
//             String updatedUrl =
//                 await _socketService.getUpdatedUrl(entertainmentItem['url']);
//             entertainmentItem['url'] = updatedUrl;
//             entertainmentItem['stream_type'] = 'M3u8';
//             break;
//           } catch (e) {
//             if (i == _maxRetries - 1) rethrow;
//             await Future.delayed(Duration(seconds: _retryDelay));
//           }
//         }
//       }

//       if (shouldPop) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       if (shouldPlayVideo) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VlcPlayerScreen(
//               videoUrl: entertainmentItem['url'],
//               videoTitle: entertainmentItem['name'],
//               channelList: entertainmentList,
//               onFabFocusChanged: (bool) {},
//               genres: '',
//               channels: [],
//               initialIndex: 1,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (shouldPop) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something Went Wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   @override
//   void dispose() {
//     _socketService.dispose();
//     super.dispose();
//   }
// }



import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekom_ui/main.dart';
import 'package:ekom_ui/menu_one_item/live_screen.dart';
import 'package:ekom_ui/video_widget/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:palette_generator/palette_generator.dart';
import '../video_widget/socket_service.dart';

void main() {
  runApp(NewsScreen());
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> entertainmentList = [];
  List<int> allowedChannelIds = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _isNavigating = false;
  bool tvenableAll = false;
  final SocketService _socketService = SocketService();
  int _maxRetries = 3;
  int _retryDelay = 5; // seconds

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final response = await https.get(
        Uri.parse('https://api.ekomflix.com/android/getSettings'),
        headers: {
          'x-api-key': 'vLQTuPZUxktl5mVW',
        },
      );

      if (response.statusCode == 200) {
        final settingsData = json.decode(response.body);
        setState(() {
          allowedChannelIds = List<int>.from(settingsData['channels']);
          tvenableAll = settingsData['tvenableAll'] == 1;
        });

        fetchEntertainment();
      } else {
        throw Exception('Something Went Wrong');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something Went Wrong';
        isLoading = false;
      });
    }
  }

  Future<void> fetchEntertainment() async {
    try {
      final response = await https.get(
        Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
        headers: {
          'x-api-key': 'vLQTuPZUxktl5mVW',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          entertainmentList = responseData.where((channel) {
            int channelId = int.tryParse(channel['id'].toString()) ?? 0;
            String channelGenres = channel['genres'].toString();
            String channelStatus = channel['status'].toString();

            return channelGenres.contains('News') &&
                channelStatus == "1" &&
                (tvenableAll || allowedChannelIds.contains(channelId));
          }).map((channel) {
            channel['isFocused'] = false;
            channel['dominantColor'] = Colors.black.withOpacity(0.5);
            return channel;
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Something Went Wrong');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something Went Wrong';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: borderColor,
                size: 50.0,
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 20, color: hintColor),
                  ),
                )
              : entertainmentList.isEmpty
                  ? Center(
                      child: Text('Something Went Wrong',
                          style: TextStyle(color: hintColor)))
                  : Padding(
                      padding: EdgeInsets.only(top: screenhgt * 0.1),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: entertainmentList.length > 10 ? 11 : entertainmentList.length,
                        itemBuilder: (context, index) {
                          if (index == 10 && entertainmentList.length > 10) {
                            return GestureDetector(
                              onTap: () => _navigateToViewAllScreen(context),
                              child: _buildViewAllItem(),
                            );
                          }
                          return GestureDetector(
                            onTap: () => _navigateToVideoScreen(
                                context, entertainmentList[index]),
                            child: _buildGridViewItem(index),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildGridViewItem(int index) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          _navigateToVideoScreen(context, entertainmentList[index]);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (hasFocus) async {
        setState(() {
          entertainmentList[index]['isFocused'] = hasFocus;
        });

        if (hasFocus) {
          Color dominantColor =
              await _getPaletteColor(entertainmentList[index]['banner'] ?? '');
          setState(() {
            entertainmentList[index]['dominantColor'] = dominantColor;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              AnimatedContainer(
                curve: Curves.ease,
                width: screenwdt * 0.19,
                height: entertainmentList[index]['isFocused']
                    ? screenhgt * 0.22
                    : screenhgt * 0.2,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  border: entertainmentList[index]['isFocused']
                      ? Border.all(
                          color: entertainmentList[index]['dominantColor'] ??
                              hintColor,
                          width: 3.0,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 3.0,
                        ),
                  boxShadow: entertainmentList[index]['isFocused']
                      ? [
                          BoxShadow(
                            color: entertainmentList[index]['dominantColor'] ??
                                Colors.black.withOpacity(0.5),
                            blurRadius: 25.0,
                            spreadRadius: 10.0,
                          ),
                        ]
                      : [],
                ),
                child: CachedNetworkImage(
                  imageUrl: entertainmentList[index]['banner'] ?? '',
                  placeholder: (context, url) => localImage,
                  width: screenwdt * 0.19,
                  height: entertainmentList[index]['isFocused']
                      ? screenhgt * 0.22
                      : screenhgt * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            width: screenwdt * 0.19,
            child: Column(
              children: [
                Text(
                  (entertainmentList[index]['name'] ?? 'Unknown')
                      .toString()
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: entertainmentList[index]['isFocused']
                        ? entertainmentList[index]['dominantColor'] ??
                            highlightColor
                        : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  entertainmentList[index]['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 12,
                    color: entertainmentList[index]['isFocused']
                        ? entertainmentList[index]['dominantColor']?.withOpacity(0.8) ??
                            highlightColor.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllItem() {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          _navigateToViewAllScreen(context);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenwdt * 0.19,
            height: screenhgt * 0.2,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              border: Border.all(color: highlightColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Go to View All',
                style: TextStyle(color: highlightColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'VIEW ALL',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<Color> _getPaletteColor(String imageUrl) async {
    try {
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      final paletteGenerator =
          await PaletteGenerator.fromImageProvider(imageProvider);
      return paletteGenerator.dominantColor?.color ??
          Colors.white.withOpacity(0.5);
    } catch (e) {
      print('Error fetching palette: $e');
      return Colors.black.withOpacity(0.5);
    }
  }

  void _navigateToVideoScreen(
      BuildContext context, dynamic entertainmentItem) async {
    if (_isNavigating) return;
    _isNavigating = true;

    bool shouldPlayVideo = true;
    bool shouldPop = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            shouldPlayVideo = false;
            shouldPop = false;
            return true;
          },
          child: Center(
            child: SpinKitFadingCircle(
              color: borderColor,
              size: 50.0,
            ),
          ),
        );
      },
    );

    Timer(Duration(seconds: 5), () {
      _isNavigating = false;
    });

    try {
      if (entertainmentItem['stream_type'] == 'YoutubeLive') {
        for (int i = 0; i < _maxRetries; i++) {
          try {
            String updatedUrl =
                await _socketService.getUpdatedUrl(entertainmentItem['url']);
            entertainmentItem['url'] = updatedUrl;
            entertainmentItem['stream_type'] = 'M3u8';
            break;
          } catch (e) {
            if (i == _maxRetries - 1) rethrow;
            await Future.delayed(Duration(seconds: _retryDelay));
          }
        }
      }

      if (shouldPop) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (shouldPlayVideo) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: entertainmentItem['url'],
              videoTitle: entertainmentItem['name'],
              channelList: entertainmentList,
              onFabFocusChanged: (bool) {},
              genres: '',
              channels: [],
              initialIndex: 1,
            ),
          ),
        );
      }
    } catch (e) {
      if (shouldPop) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something Went Wrong')),
      );
    } finally {
      _isNavigating = false;
    }
  }

  void _navigateToViewAllScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveScreen (),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}