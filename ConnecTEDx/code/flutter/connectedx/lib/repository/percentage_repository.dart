import 'package:connectedx/models/percentage_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PercentageRepository {
  static const String apiUrl = 'https://qo0f5hn90k.execute-api.us-east-1.amazonaws.com/default/Get_Percentage';

  Future<List<UserPercentage>> fetchPercentagesById(String id) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'id': id,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => UserPercentage.fromJson(item)).toList();
    } else {
      // ignore: avoid_print
      print('Failed to load percentages. Status code: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
      throw Exception('Failed to load percentages');
    }
  }
}
