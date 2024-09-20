


// import 'dart:async';
// import 'package:ekom_ui/main.dart';
// import 'package:ekom_ui/menu_two_items/news_grid_screen.dart';
// import 'package:ekom_ui/video_widget/socket_service.dart';
// import 'package:ekom_ui/video_widget/video_screen.dart';
// import 'package:ekom_ui/widgets/items/news_item.dart';
// import 'package:ekom_ui/widgets/models/news_item_model.dart';
// import 'package:ekom_ui/widgets/services/api_service.dart';
// import 'package:ekom_ui/widgets/small_widgets/empty_state.dart';
// import 'package:ekom_ui/widgets/small_widgets/error_message.dart';
// import 'package:ekom_ui/widgets/small_widgets/loading_indicator.dart';
// import 'package:flutter/material.dart';


// class NewsScreen extends StatefulWidget {
//   List<NewsItemModel> get entertainmentList => [];

//   @override
//   _NewsScreenState createState() => _NewsScreenState();
// }

// class _NewsScreenState extends State<NewsScreen> {
//   final List<NewsItemModel> _entertainmentList = [];
//   final SocketService _socketService = SocketService();
//   final ApiService _apiService = ApiService();
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;
//   int _maxRetries = 3;
//   int _retryDelay = 5; // seconds

//   @override
//   void initState() {
//     super.initState();
//     _socketService.initSocket();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     try {
//       await _apiService.fetchSettings();
//       await _apiService.fetchEntertainment();
//       setState(() {
//         _entertainmentList.addAll(_apiService.newsList);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Something Went Wrong';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return LoadingIndicator();
//     } else if (_errorMessage.isNotEmpty) {
//       return ErrorMessage(message: _errorMessage);
//     } else if (_entertainmentList.isEmpty) {
//       return EmptyState(message: 'Something Went Wrong');
//     } else {
//       return _buildNewsList();
//     }
//   }

//   Widget _buildNewsList() {
//     return Padding(
//       padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _entertainmentList.length > 10 ? 11 : _entertainmentList.length,
//         itemBuilder: (context, index) {
//           if (index == 10) {
//             return _buildViewAllItem();
//           }
//           return _buildNewsItem(_entertainmentList[index]);
//         },
//       ),
//     );
//   }



//   Widget _buildViewAllItem() {
//     return NewsItem(
//       key: Key('view_all'),
//       item: NewsItemModel(
//         id: 'view_all',
//         name: 'VIEW ALL',
//         description: 'See all news channels',
//         banner: '',
//         url: '',
//         streamType: '',
//         genres: '',
//         status: '',
//       ),
//       onTap: _navigateToViewAllScreen,
//       onEnterPress: _handleEnterPress,
//     );
//   }

//   Widget _buildNewsItem(NewsItemModel item) {
//     return NewsItem(
//       key: Key(item.id),
//       item: item,
//       onTap: () => _navigateToVideoScreen(item),
//       onEnterPress: _handleEnterPress,
//     );
//   }

//   void _handleEnterPress(String itemId) {
//     if (itemId == 'view_all') {
//       _navigateToViewAllScreen();
//     } else {
//       final selectedItem = _entertainmentList.firstWhere((item) => item.id == itemId);
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
//           child: LoadingIndicator(),
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
//               channelList: _entertainmentList,
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
//         builder: (context) => NewsGridScreen(),
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
import 'package:ekom_ui/menu_two_items/news_grid_screen.dart';
import 'package:ekom_ui/video_widget/socket_service.dart';
import 'package:ekom_ui/video_widget/video_screen.dart';
import 'package:ekom_ui/widgets/items/news_item.dart';
import 'package:ekom_ui/widgets/models/news_item_model.dart';
import 'package:ekom_ui/widgets/services/api_service.dart';
import 'package:ekom_ui/widgets/small_widgets/empty_state.dart';
import 'package:ekom_ui/widgets/small_widgets/error_message.dart';
import 'package:ekom_ui/widgets/small_widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<NewsItemModel> _entertainmentList = [];
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
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await _apiService.fetchSettings();
      await _apiService.fetchEntertainment();
      setState(() {
        _entertainmentList.addAll(_apiService.newsList);
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
    } else if (_entertainmentList.isEmpty) {
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
        itemCount: _entertainmentList.length > 10 ? 11 : _entertainmentList.length,
        itemBuilder: (context, index) {
          if (index == 10) {
            return _buildViewAllItem();
          }
          return _buildNewsItem(_entertainmentList[index]);
        },
      ),
    );
  }

  Widget _buildViewAllItem() {
    return NewsItem(
      key: Key('view_all'),
      item: NewsItemModel(
        id: 'view_all',
        name: 'VIEW ALL',
        description: 'See all news channels',
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
      final selectedItem = _entertainmentList.firstWhere((item) => item.id == itemId);
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
              channelList: _entertainmentList,
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
        builder: (context) => NewsGridScreen(newsList: _entertainmentList),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}