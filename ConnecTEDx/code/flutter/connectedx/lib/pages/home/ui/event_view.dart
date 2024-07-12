import 'package:flutter/material.dart';
import 'package:connectedx/models/event_item.dart';
import 'package:url_launcher/url_launcher.dart';

class EventView extends StatelessWidget {
  final EventItem eventItem;
  final bool showDistance; 

  const EventView({super.key, required this.eventItem, this.showDistance = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.white,
        child: InkWell(
          // ignore: deprecated_member_use
          onTap: () => launch(eventItem.url),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Image.network(
                  eventItem.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  eventItem.title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  eventItem.date,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  eventItem.location,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 20.0),
                child: Text(
                  eventItem.displayPrice, 
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (showDistance && eventItem.distance != null) 
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 20.0),
                  child: Text(
                    'Distanza: ${eventItem.distance}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
