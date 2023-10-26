import 'dart:convert';

import 'package:intl/intl.dart';

DictionaryResponse dictionaryResponseFromJson(String str) =>
    DictionaryResponse.fromJson(json.decode(str));

String dictionaryResponseToJson(DictionaryResponse data) =>
    json.encode(data.toJson());

class DictionaryResponse {
  DictionaryResponse({
    this.word = '',
    this.phonetic = '',
    required this.phonetics,
    this.origin = '',
    required this.meanings,
  });

  String word;
  String phonetic;
  List<Phonetics> phonetics;
  String origin;
  List<Meanings> meanings;

  factory DictionaryResponse.fromJson(Map<String, dynamic> json) =>
      DictionaryResponse(
          word: json['word'],
          phonetic: json['phonetic'],
          phonetics: List<Phonetics>.from(
              json["phonetics"].map((x) => Phonetics.fromJson(x))),
          origin: json['origin'],
          meanings: List<Meanings>.from(
              json["meanings"].map((x) => Meanings.fromJson(x))));

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'phonetics': List<dynamic>.from(phonetics.map((x) => x.toJson())),
        'origin': origin,
        'meanings': List<dynamic>.from(meanings.map((x) => x.toJson())),
      };
}

class Phonetics {
  Phonetics({
    this.text = '',
    this.audio,
  });

  String text;
  var audio;

  factory Phonetics.fromJson(Map<String, dynamic> json) => Phonetics(
        text: json['text'],
        audio: json['audio'],
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'audio': audio,
      };
}

class Meanings {
  Meanings({
    this.partOfSpeech = '',
    required this.definitions,
  });

  String partOfSpeech;
  List<Definitions> definitions;

  factory Meanings.fromJson(Map<String, dynamic> json) => Meanings(
        partOfSpeech: json['partOfSpeech'],
        definitions: json['definitions'],
      );

  Map<String, dynamic> toJson() => {
        'partOfSpeech': partOfSpeech,
        'definitions': definitions,
      };
}

class Definitions {
  Definitions({
    this.definition = '',
    this.example = '',
    required this.synonyms,
    required this.antonyms,
  });

  String definition;
  String example;
  List<dynamic> synonyms;
  List<dynamic> antonyms;

  factory Definitions.fromJson(Map<String, dynamic> json) => Definitions(
        definition: json['definition'],
        example: json['example'],
        synonyms: json['synonyms'],
        antonyms: json['synonyms'],
      );

  Map<String, dynamic> toJson() => {
        'definition': definition,
        'example': example,
        'synonyms': synonyms,
        'antonyms': antonyms,
      };
}
