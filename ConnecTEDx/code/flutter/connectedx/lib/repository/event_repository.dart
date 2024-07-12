import 'package:connectedx/models/event_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventRepository {
  static const String apiUrl = 'https://x5q0notlzb.execute-api.us-east-1.amazonaws.com/default/Get_Events_By_Distance'; 
  static const String casualApiUrl = 'https://pcabt8bxy7.execute-api.us-east-1.amazonaws.com/default/Get_Casual_Events'; 

  Future<List<EventItem>> fetchEvents(String id, int page) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        '_id': id,
        'page': page,
        'doc_per_page': 6,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => EventItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<EventItem>> fetchCasualEvents(int page) async {
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
      return body.map((dynamic item) => EventItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load casual events');
    }
  }
}
