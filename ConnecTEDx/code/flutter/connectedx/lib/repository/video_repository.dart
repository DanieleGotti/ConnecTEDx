import 'package:connectedx/models/video_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoRepository {
  static const String apiUrl = 'https://3dwijdqjze.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag';
  static const String casualApiUrl = 'https://0oc6y6q9zj.execute-api.us-east-1.amazonaws.com/default/Get_Casual_Videos';

  Future<List<VideoItem>> fetchVideos(String tag, int page) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'tag': tag,
        'page': page,
        'doc_per_page': 6,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<List<VideoItem>> fetchCasualVideos(int page) async {
    final response = await http.post(
      Uri.parse(casualApiUrl),
      body: jsonEncode({
        'page': page,
        'doc_per_page': 6,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load casual videos');
    }
  }
}
