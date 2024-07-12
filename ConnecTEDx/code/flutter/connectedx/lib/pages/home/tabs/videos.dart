import 'package:connectedx/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:connectedx/models/video_item.dart';
import 'package:connectedx/pages/home/ui/video_view.dart';
import 'package:connectedx/repository/video_repository.dart';
import 'package:connectedx/repository/percentage_repository.dart'; 
import 'package:connectedx/models/percentage_item.dart'; 

class PageVideo extends StatefulWidget {
  final String loggedUser;

  const PageVideo({super.key, required this.loggedUser});

  @override
  // ignore: library_private_types_in_public_api
  _PageVideoState createState() => _PageVideoState();
}

class _PageVideoState extends State<PageVideo> {
  final TextEditingController _tagController = TextEditingController();
  final VideoRepository _videoRepository = VideoRepository();
  List<VideoItem> _videos = [];
  int _page = 1;
  String _currentTag = '';
  bool _isLoading = false;
  bool _isPreferredTagChecked = false; 
  String myTag = ""; 

  @override
  void initState() {
    super.initState();
    _fetchInitialTag(); 
    _fetchVideos(); 

    _tagController.addListener(() {
      if (_tagController.text.isEmpty && !_isPreferredTagChecked) {
        _fetchVideos();
      } else if (_tagController.text != myTag && _isPreferredTagChecked) {
        setState(() {
          _isPreferredTagChecked = false;
        });
      }
    });
  }

  Future<void> _fetchInitialTag() async {
    try {
      final repo = PercentageRepository();
      List<UserPercentage> percentages = await repo.fetchPercentagesById(loggedUser);
      if (percentages.isNotEmpty) {
        setState(() {
          myTag = percentages[0].tag; 
        });
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error fetching initial tag: $error');
    }
  }

  void _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _page = 1;
    });

    if (_tagController.text.isEmpty && !_isPreferredTagChecked) {
      try {
        final videos = await _videoRepository.fetchCasualVideos(_page);
        setState(() {
          _videos = videos;
          _currentTag = '';
        });
      } catch (error) {
        setState(() {});
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      final tag = _isPreferredTagChecked ? myTag : _tagController.text;
      try {
        final videos = await _videoRepository.fetchVideos(tag, _page);
        setState(() {
          _videos = videos;
          _currentTag = tag;
        });
      } catch (error) {
        setState(() {});
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadMore() async {
    setState(() {
      _isLoading = true;
    });

    _page++;
    try {
      List<VideoItem> moreVideos;
      if (_tagController.text.isEmpty && !_isPreferredTagChecked) {
        moreVideos = await _videoRepository.fetchCasualVideos(_page);
      } else {
        moreVideos = await _videoRepository.fetchVideos(_currentTag, _page);
      }
      setState(() {
        _videos.addAll(moreVideos);
      });
    } catch (error) {
      setState(() {
        _page--; 
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nel caricamento dei video. $error'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    labelText: 'Cerca per tag',
                    labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF017DC7),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), 
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF017DC7)),
                onPressed: () {
                  setState(() {
                    _isPreferredTagChecked = false;
                  });
                  _fetchVideos();
                  _page = 1;
                },
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: Icon(
                  _isPreferredTagChecked ? Icons.star : Icons.star_border,
                  color: _isPreferredTagChecked ? const Color(0xFF017DC7) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPreferredTagChecked = !_isPreferredTagChecked;
                    if (_isPreferredTagChecked) {
                      _tagController.text = myTag;
                      _fetchVideos();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  return VideoView(videoItem: _videos[index]);
                },
              ),
              if (_isLoading)
                Container(
                  color: const Color(0xFFF1F1F1).withOpacity(0.75),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF017DC7),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _loadMore,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return const Color(0xFF017DC7);
                  },
                ),
                overlayColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color(0xFF017DC7);
                    }
                    return Colors.white;
                  },
                ),
              ),
              child: const Text('Carica altri'),
            ),
          ),
      ],
    );
  }
}
