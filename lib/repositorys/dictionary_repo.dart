import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:redi/models/dictionary_response.dart';

var appId = '7d6d3c70';
var appKey = 'b46748f340c812c67091b12905d20887';

class DictionaryRepo {
  Future<List> getDictionary(String word) async {
    Uri url =
        Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word");
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer",
      // "App-Language": app_language.$,
    });
    print("body: " + response.body);
    return json.decode(response.body);
    // return dictionaryResponseFromJson(response.body);
    // List jsonResponse = dictionaryResponseFromJson(response.body) as List;
    // return jsonResponse.map((str) => DictionaryResponse.fromJson(str)).toList();
  }

  Future<List> getOxfordDictionary(String word, String lenguage) async {
    Uri url = Uri.parse(
        'https://od-api.oxforddictionaries.com/api/v2/entries/$lenguage/${word.toLowerCase()}');
    final response = await http.get(url, headers: {
      "app_id": appId,
      "app_key": appKey,
      // "App-Language": app_language.$,
    });
    print("oxford: " + response.body);
    return json.decode(response.body);
    // return dictionaryResponseFromJson(response.body);
    // List jsonResponse = dictionaryResponseFromJson(response.body) as List;
    // return jsonResponse.map((str) => DictionaryResponse.fromJson(str)).toList();
  }

  Future<List> getLemmas(
    String word,
  ) async {
    Uri url = Uri.parse(
        'https://od-api.oxforddictionaries.com/api/v2/lemmas/${word.toLowerCase()}');
    final response = await http.get(url, headers: {
      "app_id": appId,
      "app_key": appKey,
      // "App-Language": app_language.$,
    });
    print("oxford: " + response.body);
    return json.decode(response.body);
  }

  Future<List> getThesaurus(String word, String lenguage) async {
    Uri url = Uri.parse(
        'https://od-api.oxforddictionaries.com/api/v2/thesaurus/$lenguage/${word.toLowerCase()}');
    final response = await http.get(url, headers: {
      "app_id": appId,
      "app_key": appKey,
      // "App-Language": app_language.$,
    });
    print("oxford: " + response.body);
    return json.decode(response.body);
    // return dictionaryResponseFromJson(response.body);
    // List jsonResponse = dictionaryResponseFromJson(response.body) as List;
    // return jsonResponse.map((str) => DictionaryResponse.fromJson(str)).toList();
  }

  Future<List> getWords(String source_lang, String q) async {
    Uri url = Uri.parse(
        'https://od-api.oxforddictionaries.com/api/v2/words/en-gb?q=$q}');
    final response = await http.get(url, headers: {
      "app_id": appId,
      "app_key": appKey,
      // "App-Language": app_language.$,
    });
    print("oxford: " + response.body);
    return json.decode(response.body);
    // return dictionaryResponseFromJson(response.body);
    // List jsonResponse = dictionaryResponseFromJson(response.body) as List;
    // return jsonResponse.map((str) => DictionaryResponse.fromJson(str)).toList();
  }
}
