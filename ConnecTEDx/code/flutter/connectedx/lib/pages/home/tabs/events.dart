import 'package:connectedx/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:connectedx/models/event_item.dart';
import 'package:connectedx/pages/home/ui/event_view.dart';
import 'package:connectedx/repository/event_repository.dart';

class PageEvent extends StatefulWidget {
  final String loggedUser;

  const PageEvent({super.key, required this.loggedUser});

  @override
  // ignore: library_private_types_in_public_api
  _PageEventState createState() => _PageEventState();
}

class _PageEventState extends State<PageEvent> {
  final EventRepository _eventRepository = EventRepository();
  List<EventItem> _events = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isPreferredLocationChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _page = 1;
    });

    if (!_isPreferredLocationChecked) {
      try {
        final events = await _eventRepository.fetchCasualEvents(_page);
        setState(() {
          _events = events;
        });
      } catch (error) {
        _showErrorSnackBar('Errore nel caricamento degli eventi: $error');
        setState(() {});
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      try {
        final events = await _eventRepository.fetchEvents(loggedUser, _page);
        setState(() {
          _events = events;
        });
      } catch (error) {
        _showErrorSnackBar('Errore nel caricamento degli eventi: $error');
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
      List<EventItem> moreEvents;
      if (!_isPreferredLocationChecked) {
        moreEvents = await _eventRepository.fetchCasualEvents(_page);
      } else {
        moreEvents = await _eventRepository.fetchEvents(loggedUser, _page);
      }
      setState(() {
        _events.addAll(moreEvents);
      });
    } catch (error) {
      _showErrorSnackBar('Errore nel caricamento degli eventi: $error');
      setState(() {
        _page--;
      });
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
              IconButton(
                icon: Icon(
                  _isPreferredLocationChecked
                      ? Icons.location_on
                      : Icons.location_on_outlined,
                  color: _isPreferredLocationChecked
                      ? const Color(0xFF017DC7)
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPreferredLocationChecked = !_isPreferredLocationChecked;
                    _fetchEvents();
                  });
                },
              ),
              Text(
                'Vicini a me',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  return EventView(eventItem: _events[index], showDistance: _isPreferredLocationChecked);
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
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.white),
                foregroundColor:
                    WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return const Color(0xFF017DC7);
                  },
                ),
                overlayColor:
                    WidgetStateProperty.resolveWith<Color>(
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
