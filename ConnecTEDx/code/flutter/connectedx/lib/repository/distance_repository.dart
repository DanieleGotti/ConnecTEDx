import 'dart:convert';
import 'package:connectedx/models/distance_item.dart';
import 'package:http/http.dart' as http;


class DistanceRepository {
  final String apiUrl = 'https://jaowcl2f33.execute-api.us-east-1.amazonaws.com/default/Get_Distance';

  Future<List<UserDistance>> fetchDistance(String id, int page) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'id': id,
        'page': page,
        'doc_per_page': 6,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => UserDistance.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
