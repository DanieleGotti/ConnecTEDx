import 'package:flutter/material.dart';
import 'package:connectedx/models/video_item.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoView extends StatelessWidget {
  final VideoItem videoItem;

  const VideoView({super.key, required this.videoItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Card(
      color: Colors.white,
      child: InkWell(
        // ignore: deprecated_member_use
        onTap: () => launch(videoItem.url),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Container(
                  margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Image.network(
                    videoItem.urlImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    videoItem.title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 20.0),
                  child: Text(
                    videoItem.speakers,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
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
