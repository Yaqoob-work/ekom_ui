import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final List<NewsItemModel> _entertainmentList = [];
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  int _maxRetries = 3;
  int _retryDelay = 5; // seconds
  String _selectedCategory = 'Music'; // Default category

  final List<String> categories = [
    'Live',
    'Entertainment',
    'Music',
    'Movie',
    'News',
    'Sports',
    'Religious'
  ];

  Map<String, FocusNode> categoryFocusNodes = {};

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
    fetchData();
    
    // Initialize focus nodes for each category
    for (var category in categories) {
      categoryFocusNodes[category] = FocusNode();
    }
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _apiService.fetchSettings();
      await _apiService.fetchEntertainment();
      setState(() {
        _entertainmentList.clear();
        // Use the selected category to determine which list to add
        switch (_selectedCategory.toLowerCase()) {
          case 'live':
            _entertainmentList.addAll(_apiService.allChannelList);
            break;
          case 'entertainment':
            _entertainmentList.addAll(_apiService.entertainmentList);
            break;
          case 'music':
            _entertainmentList.addAll(_apiService.musicList);
            break;
          case 'movie':
            _entertainmentList.addAll(_apiService.movieList);
            break;
          case 'news':
            _entertainmentList.addAll(_apiService.newsList);
            break;
          case 'sports':
            _entertainmentList.addAll(_apiService.sportsList);
            break;
          case 'religious':
            _entertainmentList.addAll(_apiService.religiousList);
            break;
          default:
            _entertainmentList.addAll(_apiService.musicList);
        }
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
      body: Column(
        children: [
          SizedBox(height: screenhgt*0.03,),
          _buildCategoryButtons(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Container(
      height: screenhgt * 0.1,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) {
          return Focus(
            focusNode: categoryFocusNodes[category],
            onKey: (FocusNode node, RawKeyEvent event) {
              if (event is RawKeyDownEvent && 
                  (event.logicalKey == LogicalKeyboardKey.enter || 
                   event.logicalKey == LogicalKeyboardKey.select)) {
                _selectCategory(category);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Builder(
              builder: (BuildContext context) {
                final bool hasFocus = Focus.of(context).hasFocus;
                return IconButton(
                  icon: Text(
                    category,
                    style: TextStyle(
                      color: _selectedCategory == category
                        ? borderColor
                        : (hasFocus ? Colors.lightBlue : hintColor),
                      fontWeight: _selectedCategory == category || hasFocus
                        ? FontWeight.bold
                        : FontWeight.normal,
                    ),
                  ),
                  onPressed: () => _selectCategory(category),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.focused)) {
                          return Colors.transparent;
                        }
                        return Colors.transparent;
                      },
                    ),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedCategory == category
                            ? borderColor
                            : (hasFocus ? Colors.lightBlue : Colors.transparent),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    fetchData();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingIndicator();
    } else if (_errorMessage.isNotEmpty) {
      return ErrorMessage(message: _errorMessage);
    } else if (_entertainmentList.isEmpty) {
      return EmptyState(message: 'No items found for $_selectedCategory');
    } else {
      return _buildNewsList();
    }
  }

  Widget _buildNewsList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _entertainmentList.length + 1,  // Always add one for the "view all" item
      itemBuilder: (context, index) {
        if (index == _entertainmentList.length) {
          return _buildViewAllItem();
        }
        return _buildNewsItem(_entertainmentList[index]);
      },
    );
  }

  Widget _buildViewAllItem() {
    return NewsItem(
      key: Key('view_all'),
      item: NewsItemModel(
        id: 'view_all',
        name: _selectedCategory.toUpperCase(),  // Use the selected category name
        description: 'See all $_selectedCategory channels',
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
    // Dispose focus nodes
    categoryFocusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }
}