import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekom_ui/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import '../video_widget/video_movie_screen.dart';

void main() {
  runApp(VOD());
}

// Models
class NetworkApi {
  final int id;
  final String name;
  final String logo;

  NetworkApi({required this.id, required this.name, required this.logo});

  factory NetworkApi.fromJson(Map<String, dynamic> json) {
    return NetworkApi(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] ?? 'No Name',
      logo: json['logo'] ?? localImage,
    );
  }
}

class ContentApi {
  final int id;
  final String name;
  final String banner;

  ContentApi({required this.id, required this.name, required this.banner});

  factory ContentApi.fromJson(Map<String, dynamic> json) {
    return ContentApi(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] ?? 'No Name',
      banner: json['banner'] ?? localImage,
    );
  }
}

class MovieDetailsApi {
  final int id;
  final String name;
  final String banner;
  final String poster;
  final String genres;
  final String status;

  MovieDetailsApi({
    required this.id,
    required this.name,
    required this.banner,
    required this.poster,
    required this.genres,
    required this.status,
  });

  factory MovieDetailsApi.fromJson(Map<String, dynamic> json) {
    return MovieDetailsApi(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] ?? 'No Name',
      banner: json['banner'] ?? localImage,
      poster: json['poster'] ?? localImage,
      genres: json['genres'] ?? 'Unknown',
      status: json['status'] ?? '0',
    );
  }
}

// Fetch Functions
Future<List<NetworkApi>> fetchNetworks() async {
  final response = await https.get(
    Uri.parse('https://api.ekomflix.com/android/getNetworks'),
    headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
  );

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => NetworkApi.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load networks');
  }
}

Future<List<ContentApi>> fetchContent(int networkId) async {
  final response = await https.get(
    Uri.parse(
        'https://api.ekomflix.com/android/getAllContentsOfNetwork/$networkId'),
    headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
  );

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => ContentApi.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load content');
  }
}

Future<MovieDetailsApi> fetchMovieDetails(int contentId) async {
  final response = await https.get(
    Uri.parse('https://api.ekomflix.com/android/getMovieDetails/$contentId'),
    headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = json.decode(response.body);
    return MovieDetailsApi.fromJson(body);
  } else {
    throw Exception('Failed to load movie details');
  }
}

Future<Map<String, String>> fetchMoviePlayLink(int movieId) async {
  final response = await https.get(
    Uri.parse('https://api.ekomflix.com/android/getMoviePlayLinks/$movieId/0'),
    headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    if (body.isNotEmpty) {
      final Map<String, dynamic> firstItem = body.first as Map<String, dynamic>;
      return {'url': firstItem['url'] ?? '', 'type': firstItem['type'] ?? ''};
    }
    return {'url': '', 'type': ''};
  } else {
    throw Exception('Failed to load movie play link');
  }
}

// Widgets
class FocusableGridItem extends StatefulWidget {
  final NetworkApi network;
  final VoidCallback onTap;

  FocusableGridItem({required this.network, required this.onTap});

  @override
  _FocusableGridItemState createState() => _FocusableGridItemState();
}

class _FocusableGridItemState extends State<FocusableGridItem> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select) {
              widget.onTap();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  width: screenwdt * 0.15,
                  height: screenhgt * 0.2,
                  duration: const Duration(milliseconds: 3),
                  decoration: BoxDecoration(
                    border: _focusNode.hasFocus
                        ? Border.all(
                            color: hintColor,
                            width: 5.0,
                          )
                        : Border.all(
                            color: Colors.transparent,
                            width: 5.0,
                          ),
                    // borderRadius: BorderRadius.circular(10),
                  ),
                    child: CachedNetworkImage(
                      imageUrl: widget.network.logo,
                      placeholder: (context, url) => localImage,
                      fit: BoxFit.cover,
                      width: screenwdt * 0.15,
                      height: screenhgt * 0.2,
                    ),
                ),
                Positioned(
                    left: _focusNode.hasFocus ? 5 : 0,
                    right: _focusNode.hasFocus ? 5 : 0,
                    top: _focusNode.hasFocus ? 5 : 0,
                    bottom: _focusNode.hasFocus ? 5 : 0,
                    child: Container(
                      color: Colors.black45,
                    ))
              ],
            ),
            Container(
              width: screenwdt * 0.15,
              child: Text(
                widget.network.name,
                style: TextStyle(
                  color: _focusNode.hasFocus ? highlightColor : Colors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FocusableGridItemContent extends StatefulWidget {
  final ContentApi content;
  final VoidCallback onTap;

  FocusableGridItemContent({required this.content, required this.onTap});

  @override
  _FocusableGridItemContentState createState() =>
      _FocusableGridItemContentState();
}

class _FocusableGridItemContentState extends State<FocusableGridItemContent> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select) {
              widget.onTap();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                width: screenwdt * 0.15,
                height: screenhgt * 0.2,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  border:_focusNode.hasFocus ? Border.all(
                    color: hintColor,
                    width: 5.0,
                  )
                  : Border.all(
                    color:  Colors.transparent,
                    width: 5.0,
                  ),
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: widget.content.banner,
                    placeholder: (context, url) => localImage,
                    fit: BoxFit.cover,
                    width: screenwdt * 0.15,
                    height: screenhgt * 0.2,
                  ),
                ),
              ),
              Container(
                width: screenwdt * 0.15,
                child: Text(
                  widget.content.name,
                  style: TextStyle(
                    color: _focusNode.hasFocus ? highlightColor : Colors.white,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class VOD extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'VOD',
//       theme: ThemeData.dark(),
//       home: HomeScreen(),
//     );
//   }
// }

class VOD extends StatefulWidget {
  @override
  _VODState createState() => _VODState();
}

class _VODState extends State<VOD> {
  late Future<List<NetworkApi>> _networksFuture;

  @override
  void initState() {
    super.initState();
    _networksFuture = fetchNetworks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: FutureBuilder<List<NetworkApi>>(
        future: _networksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                color: borderColor,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Networks Available'));
          } else {
            final networks = snapshot.data!;
            return Container(
              margin:  EdgeInsets.only(top:screenhgt*0.1),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  // crossAxisSpacing: 10,
                  // mainAxisSpacing: 10,
                ),
                itemCount: networks.length,
                itemBuilder: (context, index) {
                  return FocusableGridItem(
                    network: networks[index],
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ContentScreen(networkId: networks[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class ContentScreen extends StatefulWidget {
  final int networkId;

  ContentScreen({required this.networkId});

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late Future<List<ContentApi>> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = fetchContent(widget.networkId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: FutureBuilder<List<ContentApi>>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                color: borderColor,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Content Available'));
          } else {
            final content = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                // crossAxisSpacing: 10,
                // mainAxisSpacing: 10,
              ),
              itemCount: content.length,
              itemBuilder: (context, index) {
                return FocusableGridItemContent(
                  content: content[index],
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsPage(content: content[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final ContentApi content;

  DetailsPage({required this.content});

  @override
  Widget build(BuildContext context) {
    bool _isNavigating = false;
    bool _isLoadingVideo = false;

    return Scaffold(
      backgroundColor: cardColor,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<MovieDetailsApi>(
          future: fetchMovieDetails(content.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: SpinKitFadingCircle(
                color: borderColor,
                size: 50.0,
              ));
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Something Went Wrong', style: TextStyle(fontSize: 20)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(
                      'Go Back',
                      style: TextStyle(fontSize: 25, color: borderColor),
                    ),
                  ),
                ],
              );
            } else if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Something Went Wrong', style: TextStyle(fontSize: 20)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(
                      'Go Back',
                      style: TextStyle(fontSize: 25, color: borderColor),
                    ),
                  ),
                ],
              );
            } else {
              final movieDetails = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (movieDetails.status == '1') // Check if status is '1'
                    Container(
                      width: screenwdt * 0.8,
                      height: screenhgt * 0.6,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        imageUrl: movieDetails.banner,
                        placeholder: (context, url) => localImage,
                        fit: BoxFit.cover,
                        width: screenwdt * 0.8,
                        height: screenhgt * 0.6,
                      ),
                    ),
                  Center(
                    child: Text(
                      movieDetails.name,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 1, // Assume we have only one detail item
                      itemBuilder: (context, index) {
                        return FocusableGridItemContent(
                          content: content,
                          onTap: () async {
                            if (_isNavigating)
                              return; // Check if navigation is already in progress
                            _isNavigating = true; // Set the flag to true
                            _isLoadingVideo = true; // Start loading video

                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                  child: SpinKitFadingCircle(
                                color: borderColor,
                                size: 50.0,
                              )),
                            );

                            try {
                              final playLink =
                                  await fetchMoviePlayLink(content.id);

                              if (playLink['type'] == 'Youtube' ||
                                  playLink['type'] == 'YoutubeLive') {
                                final response = await https.get(
                                  Uri.parse(
                                      'https://test.gigabitcdn.net/yt-dlp.php?v=' +
                                          playLink['url']!),
                                  headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
                                );

                                if (response.statusCode == 200) {
                                  playLink['url'] =
                                      json.decode(response.body)['url'];
                                  playLink['type'] = "M3u8";
                                } else {
                                  throw Exception('Failed to load video URL');
                                }
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoMovieScreen(
                                    videoUrl: playLink['url']!,
                                    videoTitle: movieDetails.name,
                                    channelList: [],
                                    videoBanner: movieDetails.banner,
                                    onFabFocusChanged: (bool focused) {},
                                    genres: movieDetails.genres,
                                    videoType: playLink['type']!,
                                    url: playLink['url']!,
                                    type: playLink['type']!,
                                  ),
                                ),
                              ).then((_) {
                                // Reset the flag after the navigation is completed
                                _isNavigating = false;
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              });
                            } catch (e) {
                              Navigator.of(context, rootNavigator: true).pop();
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                  'Something Went Wrong',
                                  style: TextStyle(fontSize: 20),
                                )),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
