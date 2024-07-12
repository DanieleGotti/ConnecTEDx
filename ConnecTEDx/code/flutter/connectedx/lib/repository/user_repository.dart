import 'package:connectedx/models/user_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRepository {
  static const String apiUrl = 'https://d5h8r1q8bf.execute-api.us-east-1.amazonaws.com/default/Get_User_By_Id';
  static const String casualApiUrl = 'https://21ggtaqrr8.execute-api.us-east-1.amazonaws.com/default/Get_Casual_Users';

  Future<UserItem> fetchUserById(String id) async {
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
      Map<String, dynamic> body = jsonDecode(response.body);
      return UserItem.fromJson(body);
    } else {
      throw Exception('Failed to load user');
    }
  }

    Future<List<UserItem>> fetchCasualUsers(int page) async {
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
      return body.map((dynamic item) => UserItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load casual events');
    }
  }
}
