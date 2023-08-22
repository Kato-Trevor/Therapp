import 'package:http/http.dart' as http;
import 'globals.dart';
import 'dart:convert';

Future<String> getAuthenticationKey() async {
  var creds = {'username': username, 'password': password};

  final response = await http.Client().post(
    Uri.parse(api_url + "/auth/token"),
    body: creds,
  );

  return jsonDecode(response.body)["access_token"];
}

Future<String> Translate(
    String text, String target, String source, String token) async {
  var headers = <String, String>{
    "Authorization": "Bearer $token",
    "Content-Type": "application/json"
  };

  var payload = jsonEncode(<String, String>{
    "source_language": source,
    "target_language": target,
    "text": text
  });

  final response = await http.Client().post(
      Uri.parse(api_url + "/tasks/translate"),
      headers: headers,
      body: payload);

  if (response.statusCode == 200) {
    String translated_text = jsonDecode(response.body)["text"];
    return translated_text;
  } else
    print("Error: " + response.statusCode.toString());
  return response.body;
}

List<String> generateBatch(String text) {
  List<String> words = text.split(' ');
  List<String> batches = [];
  String batch = '';
  for (String word in words) {
    if (batch.length + word.length + 1 <= 200) {
      batch += word + " ";
    } else {
      batches.add(batch);
      batch = word;
    }
  }
  if (batch.isNotEmpty) {
    batches.add(batch);
  }
  return batches;
}

Future<String> generate_translation(
    String text, String target, String source, String token) async {
  var batches = generateBatch(text);

  var translation = "";
  for (var batch in batches) {
    await Translate(batch, target, source, token)
        .then((value) => {translation += value + " "});
  }

  return translation;
}
