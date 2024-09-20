import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';




Map<String, dynamic> settings = {};

Future<void> fetchSettings() async {
  final response = await https.get(
    Uri.parse('https://api.ekomflix.com/android/getSettings'),
    headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
  );

  if (response.statusCode == 200) {
    settings = json.decode(response.body);
  } else {
    throw Exception('Failed to load settings');
  }
}

Future<List<Category>> fetchCategories() async {
  await fetchSettings();

  final response = await https.get(
    Uri.parse('https://api.ekomflix.com/android/getSelectHomeCategory'),
    headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    List<Category> categories =
        jsonResponse.map((category) => Category.fromJson(category)).toList();

    if (settings['tvenableAll'] == 0) {
      for (var category in categories) {
        category.channels.retainWhere(
            (channel) => settings['channels'].contains(int.parse(channel.id)));
      }
    }

    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}

class HomeCategory extends StatefulWidget {
  @override
  _HomeCategoryState createState() => _HomeCategoryState();
}

class _HomeCategoryState extends State<HomeCategory> {
  late Future<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: FutureBuilder<List<Category>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Category> categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryWidget(category: categories[index]);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }

          return Container(
              color: Colors.black,
              child: Center(
                  child: SpinKitFadingCircle(
                color: borderColor,
                size: 50.0,
              )));
        },
      ),
    );
  }
}

class Category {
  final String id;
  final String text;
  List<Channel> channels;

  Category({
    required this.id,
    required this.text,
    required this.channels,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var list = json['channels'] as List;
    List<Channel> channelsList = list.map((i) => Channel.fromJson(i)).toList();

    return Category(
      id: json['id'],
      text: json['text'],
      channels: channelsList,
    );
  }
}

class Channel {
  final String id;
  final String name;
  final String description;
  final String banner;
  final String genres;
  String url;
  String streamType;
  String type;
  String status;

  Channel( {
    required this.id,
    required this.name,
    required this.description,
    required this.banner,
    required this.genres,
    required this.url,
    required this.streamType,
    required this.type,
    required this.status,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      banner: json['banner'],
      genres: json['genres'],
      url: json['url'] ?? '',
      streamType: json['stream_type'] ?? '',
      type: json['Type'] ?? '',
      status: json['status'] ?? '', 
      description:json ['description']??'no description',
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Category category;

  CategoryWidget({required this.category});

  void _showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: SpinKitFadingCircle(
          color: borderColor,
          size: 50.0,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Channel> filteredChannels =
        category.channels.where((channel) => channel.url.isNotEmpty).toList();

    return filteredChannels.isNotEmpty
        ? Container(
            color: cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                  child: Text(
                    category.text.toUpperCase(),
                    style: TextStyle(
                      color: hintColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredChannels.length > 5 ? 6 : filteredChannels.length,
                    itemBuilder: (context, index) {
                      if (index == 5 && filteredChannels.length > 5) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: ViewAllWidget(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryGridView(
                                    category: category,
                                    filteredChannels: filteredChannels,
                                  ),
                                ),
                              );
                            },
                            categoryText: category.text.toUpperCase(),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ChannelWidget(
                          channel: filteredChannels[index],
                          onTap: () async {
                            _showLoadingIndicator(context);
                            await _playVideo(context, filteredChannels, index);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> _playVideo(BuildContext context, List<Channel> channels, int index) async {
    try {
      if (channels[index].streamType == 'YoutubeLive') {
        final response = await https.get(
          Uri.parse('https://test.gigabitcdn.net/yt-dlp.php?v=' + channels[index].url),
          headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
        );

        if (response.statusCode == 200 && json.decode(response.body)['url'] != '') {
          channels[index].url = json.decode(response.body)['url'];
          channels[index].streamType = "M3u8";
        } else {
          throw Exception('Failed to load networks');
        }
      }
      Navigator.of(context, rootNavigator: true).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(
            channels: channels,
            initialIndex: index,
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link Error')),
      );
    }
  }
}



class ChannelWidget extends StatefulWidget {
  final Channel channel;
  final VoidCallback onTap;

  ChannelWidget({required this.channel, required this.onTap});

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  bool isFocused = false;
  Color focusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _updateFocusColor();
  }

  Future<void> _updateFocusColor() async {
    if (widget.channel.status == '1') {
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.channel.banner),
        size: Size(150, 150),
      );
      setState(() {
        focusColor = paletteGenerator.dominantColor?.color ?? Colors.grey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showBanner = widget.channel.status == '1';

    return FocusableActionDetector(
      onFocusChange: (hasFocus) {
        setState(() {
          isFocused = hasFocus;
        });
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showBanner)
              Stack(
                children: [
                  AnimatedContainer(
                    width: screenwdt * 0.18,
                    height: isFocused ? screenhgt * 0.24 : screenhgt * 0.21,
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      border: isFocused
                          ? Border.all(
                              color: focusColor,
                              width: 4.0,
                            )
                          : Border.all(
                              color: Colors.transparent,
                              width: 4.0,
                            ),
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: focusColor.withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.channel.banner,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey),
                      width: screenwdt * 0.18,
                      height: isFocused ? screenhgt * 0.24 : screenhgt * 0.21,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
            Container(
              width: screenwdt * 0.17,
              child: Column(
                children: [
                  Text(
                    widget.channel.name,
                    style: TextStyle(
                      color: isFocused ? focusColor : Colors.grey,
                      fontWeight: FontWeight.bold,fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.channel.description,
                    style: TextStyle(
                      color: isFocused ? focusColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      // fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewAllWidget extends StatefulWidget {
  final VoidCallback onTap;
  final String categoryText;

  ViewAllWidget({required this.onTap, required this.categoryText});

  @override
  _ViewAllWidgetState createState() => _ViewAllWidgetState();
}

class _ViewAllWidgetState extends State<ViewAllWidget> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onFocusChange: (hasFocus) {
        setState(() {
          isFocused = hasFocus;
        });
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              width: screenwdt * 0.18,
              height: isFocused ? screenhgt * 0.24 : screenhgt * 0.21,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isFocused ? hintColor : Colors.transparent,
                  width: 4.0,
                ),
                color: Colors.grey[800],
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: hintColor.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 10,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    widget.categoryText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: screenwdt * 0.17,
              child: Text(
                "View All",
                style: TextStyle(
                  color: isFocused ? borderColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class CategoryGridView extends StatelessWidget {
  final Category category;
  final List<Channel> filteredChannels;

  CategoryGridView({required this.category, required this.filteredChannels});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          // childAspectRatio: 16 / 9,
          // crossAxisSpacing: 10,
          // mainAxisSpacing: 10,
        ),
        itemCount: filteredChannels.length,
        itemBuilder: (context, index) {
          return ChannelWidget(
            channel: filteredChannels[index],
            onTap: () async {
              if (filteredChannels[index].streamType == 'YoutubeLive') {
                final response = await https.get(
                  Uri.parse('https://test.gigabitcdn.net/yt-dlp.php?v=' +
                      filteredChannels[index].url),
                  headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
                );

                if (response.statusCode == 200 &&
                    json.decode(response.body)['url'] != '') {
                  filteredChannels[index].url =
                      json.decode(response.body)['url'];
                  filteredChannels[index].streamType = "M3u8";
                } else {
                  throw Exception('Failed to load networks');
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoScreen(
                    channels: filteredChannels,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final List<Channel> channels;
  final int initialIndex;
  // final String videoUrl;
  // final String videoTitle;

  VideoScreen({
    required this.channels,
    required this.initialIndex,
    // required this.videoUrl,
    // required this.videoTitle,
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isError = false;
  bool showControls = true;
  Timer? _controlsTimer;
  final FocusNode _focusNode = FocusNode();
  bool _isConnected = true;
  Timer? _connectivityCheckTimer;

  @override
  void initState() {
    super.initState();
    KeepScreenOn.turnOn();
    WidgetsBinding.instance.addObserver(this);
    // _initializeVideoPlayer(widget.videoUrl);
    _initializeVideoPlayer(widget.channels[widget.initialIndex].url);
    RawKeyboard.instance.addListener(_handleKeyEvent);
    _focusNode.requestFocus();
    _resetControlsTimer();
    _startConnectivityCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    KeepScreenOn.turnOff();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _connectivityCheckTimer?.cancel();
    _controlsTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      _controller.play();
    }
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        showControls = false;
      });
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select) {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
        _showControls();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _showControls();
      }
    }
  }

  void _showControls() {
    setState(() {
      showControls = true;
    });
    _resetControlsTimer();
  }

  void _initializeVideoPlayer(String videoUrl) {
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).catchError((error) {
        setState(() {
          _isError = true;
        });
      });
  }

  void _startConnectivityCheck() {
    _connectivityCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _updateConnectionStatus(true);
        } else {
          _updateConnectionStatus(false);
        }
      } on SocketException catch (_) {
        _updateConnectionStatus(false);
      }
    });
  }

  void _updateConnectionStatus(bool isConnected) {
    if (isConnected != _isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
      if (!isConnected) {
        _controller.pause();
      } else if (_controller.value.isBuffering ||
          !_controller.value.isPlaying) {
        _controller.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: GestureDetector(
        onTap: _showControls,
        child: Center(
            child: _isError
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Something Went Wrong',
                          style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: const Text('Go Back',
                            style: TextStyle(fontSize: 25, color: Colors.red)),
                      )
                    ],
                  )
                : _controller.value.isInitialized
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          if (showControls)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 20,
                              child: Focus(
                                focusNode: _focusNode,
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: IconButton(
                                          icon: Icon(
                                            _controller.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_controller.value.isPlaying) {
                                                _controller.pause();
                                              } else {
                                                _controller.play();
                                              }
                                            });
                                            _showControls();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 15,
                                        child: Center(
                                          child: VideoProgressIndicator(
                                            _controller,
                                            allowScrubbing: true,
                                            colors: VideoProgressColors(
                                                playedColor: borderColor,
                                                bufferedColor: Colors.green,
                                                backgroundColor: Colors.yellow),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      const Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: Colors.red,
                                                size: 15,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Live',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : SpinKitFadingCircle(
                        color: borderColor,
                        size: 50.0,
                      )),
      ),
    );
  }
}
