// import 'dart:async';
// import 'package:ekom_ui/main.dart';
// import 'package:ekom_ui/menu_one_item/live_screen.dart';
// import 'package:ekom_ui/video_widget/socket_service.dart';
// import 'package:ekom_ui/video_widget/video_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import '../widgets/services/api_service.dart';
// import '../widgets/models/news_item_model.dart';
// import '../widgets/items/news_item.dart';

// class NewsScreen extends StatefulWidget {
//   @override
//   _NewsScreenState createState() => _NewsScreenState();
// }

// class _NewsScreenState extends State<NewsScreen> {
//   List<NewsItemModel> entertainmentList = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   bool _isNavigating = false;
//   final SocketService _socketService = SocketService();
//   final ApiService _apiService = ApiService();
//   int _maxRetries = 3;
//   int _retryDelay = 5; // seconds

//   @override
//   void initState() {
//     super.initState();
//     _socketService.initSocket();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     try {
//       await _apiService.fetchSettings();
//       await _apiService.fetchEntertainment();
//       setState(() {
//         entertainmentList = _apiService.entertainmentList;
//         isLoading = false;
//       });
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
//           ? Center(child: SpinKitFadingCircle(color: Theme.of(context).highlightColor, size: 50.0))
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage, style: TextStyle(fontSize: 20, color: Theme.of(context).hintColor)))
//               : entertainmentList.isEmpty
//                   ? Center(child: Text('No news available', style: TextStyle(color: Theme.of(context).hintColor)))
//                   : _buildNewsList(),
//     );
//   }

//   Widget _buildNewsList() {
//     return Padding(
//       padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: entertainmentList.length > 10 ? 11 : entertainmentList.length,
//         itemBuilder: (context, index) {
//           if (index == 10) {
//             return NewsItem(
//               key: Key('view_all'),
//               item: NewsItemModel(
//                 id: 'view_all',
//                 name: 'VIEW ALL',
//                 description: 'See all news items',
//                 banner: '',
//                 url: '',
//                 streamType: '',
//                 genres: '',
//                 status: '',
//               ),
//               onTap: _navigateToViewAllScreen,
//               onEnterPress: _handleEnterPress,
//             );
//           }
//           return NewsItem(
//             key: Key(entertainmentList[index].id),
//             item: entertainmentList[index],
//             onTap: () => _navigateToVideoScreen(entertainmentList[index]),
//             onEnterPress: _handleEnterPress,
//           );
//         },
//       ),
//     );
//   }

//   void _handleEnterPress(String itemId) {
//     if (itemId == 'view_all') {
//       _navigateToViewAllScreen();
//     } else {
//       final selectedItem = entertainmentList.firstWhere((item) => item.id == itemId);
//       _navigateToVideoScreen(selectedItem);
//     }
//   }

//   void _navigateToVideoScreen(NewsItemModel newsItem) async {
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
//               color: Theme.of(context).primaryColor,
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
//       if (newsItem.streamType == 'YoutubeLive') {
//         for (int i = 0; i < _maxRetries; i++) {
//           try {
//             String updatedUrl = await _socketService.getUpdatedUrl(newsItem.url);
//             newsItem = NewsItemModel(
//               id: newsItem.id,
//               name: newsItem.name,
//               description: newsItem.description,
//               banner: newsItem.banner,
//               url: updatedUrl,
//               streamType: 'M3u8',
//               genres: newsItem.genres,
//               status: newsItem.status,
//             );
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
//             builder: (context) => VideoScreen(
//               videoUrl: newsItem.url,
//               videoTitle: newsItem.name,
//               channelList: entertainmentList,
//               onFabFocusChanged: (bool) {},
//               genres: newsItem.genres,
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

//   void _navigateToViewAllScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LiveScreen(),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _socketService.dispose();
//     super.dispose();
//   }
// }


import 'dart:async';
import 'package:ekom_ui/main.dart';
import 'package:ekom_ui/menu_one_item/live_screen.dart';
import 'package:ekom_ui/video_widget/socket_service.dart';
import 'package:ekom_ui/video_widget/video_screen.dart';
import 'package:ekom_ui/widgets/items/news_item.dart';
import 'package:ekom_ui/widgets/models/news_item_model.dart';
import 'package:ekom_ui/widgets/services/api_service.dart';
import 'package:ekom_ui/widgets/small_widgets/empty_state.dart';
import 'package:ekom_ui/widgets/small_widgets/error_message.dart';
import 'package:ekom_ui/widgets/small_widgets/loading_indicator.dart';
import 'package:flutter/material.dart';


class MovieScreen extends StatefulWidget {
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  final List<NewsItemModel> _MovieList = [];
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  int _maxRetries = 3;
  int _retryDelay = 5; // seconds

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _apiService.fetchSettings();
      await _apiService.fetchEntertainment();
      setState(() {
        _MovieList.addAll(_apiService.movieList );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Something Went Wrong';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingIndicator();
    } else if (_errorMessage.isNotEmpty) {
      return ErrorMessage(message: _errorMessage);
    } else if (_MovieList.isEmpty) {
      return EmptyState(message: 'Something Went Wrong');
    } else {
      return _buildNewsList();
    }
  }

  Widget _buildNewsList() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _MovieList.length > 10 ? 11 : _MovieList.length,
        itemBuilder: (context, index) {
          if (index == 10) {
            return _buildViewAllItem();
          }
          return _buildNewsItem(_MovieList[index]);
        },
      ),
    );
  }

//   Widget _buildNewsList() {
//   final moviesList = _MovieList.where((item) => item.genres.contains('Music')).toList();
//   return Padding(
//     padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
//     child: ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: moviesList.length > 10 ? 11 : moviesList.length,
//       itemBuilder: (context, index) {
//         if (index == 10) {
//           return _buildViewAllItem();
//         }
//         return _buildNewsItem(moviesList[index]);
//       },
//     ),
//   );
// }

  Widget _buildViewAllItem() {
    return NewsItem(
      key: Key('view_all'),
      item: NewsItemModel(
        id: 'view_all',
        name: 'VIEW ALL',
        description: 'See all movie channels',
        banner: '',
        url: '',
        streamType: '',
        genres: '',
        status: '',
      ),
      onTap: _navigateToViewAllScreen,
      onEnterPress: _handleEnterPress,
    );
  }

  Widget _buildNewsItem(NewsItemModel item) {
    return NewsItem(
      key: Key(item.id),
      item: item,
      onTap: () => _navigateToVideoScreen(item),
      onEnterPress: _handleEnterPress,
    );
  }

  void _handleEnterPress(String itemId) {
    if (itemId == 'view_all') {
      _navigateToViewAllScreen();
    } else {
      final selectedItem = _MovieList.firstWhere((item) => item.id == itemId);
      _navigateToVideoScreen(selectedItem);
    }
  }

  void _navigateToVideoScreen(NewsItemModel newsItem) async {
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
          child: LoadingIndicator(),
        );
      },
    );

    Timer(Duration(seconds: 5), () {
      _isNavigating = false;
    });

    try {
      if (newsItem.streamType == 'YoutubeLive') {
        for (int i = 0; i < _maxRetries; i++) {
          try {
            String updatedUrl = await _socketService.getUpdatedUrl(newsItem.url);
            newsItem = NewsItemModel(
              id: newsItem.id,
              name: newsItem.name,
              description: newsItem.description,
              banner: newsItem.banner,
              url: updatedUrl,
              streamType: 'M3u8',
              genres: newsItem.genres,
              status: newsItem.status,
            );
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
              videoUrl: newsItem.url,
              videoTitle: newsItem.name,
              channelList: _MovieList,
              onFabFocusChanged: (bool) {},
              genres: newsItem.genres,
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

  void _navigateToViewAllScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}