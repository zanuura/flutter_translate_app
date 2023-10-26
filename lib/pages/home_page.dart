import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:language_picker/language_picker_cupertino.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/language_picker_dropdown.dart';
import 'package:language_picker/languages.dart';
import 'package:redi/repositorys/dictionary_repo.dart';
import 'package:google_translator/google_translator.dart';
import 'package:translator/translator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  TextEditingController tranlateController = TextEditingController();
  String _url = "https://api.dictionaryapi.dev/api/v2/entries/en/";
  String _token = "YOUR API KEY HERE";
  Language _selectedLanguage = Languages.english;

  late StreamController _streamController;
  late Stream _stream;
  var currentLenguage = 'english';
  var currentLenguageIso = 'en';

  late Timer _debounce;
  AudioPlayer player = AudioPlayer();
  late Duration _position;
  late Duration _duration;
  bool isLoad = true;
  var tranlated = '';
  bool isREDI = true;
  var originLeng = 'indonesian';
  var destLeng = 'english';
  var langFrom = 'id';
  var langTo = 'en';
  var translation;
  var selectedType = '';

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }

    _streamController.add("waiting");
    var getDictionaryResponse =
        await DictionaryRepo().getDictionary(_controller.text);
    _streamController.add(getDictionaryResponse);
    setState(() {});
    // print(_streamController);
  }

  loadWords(searchWords) async {
    if (searchWords.toString().isEmpty)
      _streamController.add('waiting');
    else
      setState(() {
        isLoad = false;
      });
    await _search();
  }

  _play(audioasset) async {
    final result = player.play(
      UrlSource(audioasset),
    );
    player.setPlaybackRate(1.0);
    return result;
    // if (result == 1) {
    //   //play success
    //   print("Sound playing successful.");
    //   return result;
    // } else {
    //   print("Error while playing sound.");
    // }
  }

  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
    _controller = TextEditingController(text: 'halo');
    _search();
    getWords();
  }

  fetchAll() {
    if (selectedType == '') {
      getWords();
    } else if (selectedType == 'words') {
      return DictionaryRepo().getWords('en-gb', 'halo');
    } else if (selectedType == 'thesaurus') {
      return DictionaryRepo().getThesaurus('halo', 'en-us');
    }
  }

  getWords() async {
    var oxfordDictionary =
        await DictionaryRepo().getOxfordDictionary('halo', 'en-us');
    print(oxfordDictionary);
  }

  filterType(String type) {
    setState(() {
      selectedType = type;
    });
    fetchAll();
  }

  void swapLenguageCode(var from, var too, var text) async {
    var temp;

    setState(() {
      temp = from;
      from = too;
      too = temp;

      langFrom = from;
      langTo = too;
    });
    tranlateController = TextEditingController(text: text);
    translation = await GoogleTranslator().translate(text, from: from, to: too);
    tranlated = translation.toString();
    setState(() {});
    print(from + " " + too);
  }

  void swapLenguage(var from, var too) {
    var temp;

    setState(() {
      temp = from;
      from = too;
      too = temp;

      originLeng = from;
      destLeng = too;
    });
    print(from + " " + too);
  }

  // It's sample code of Dialog Item.
  Widget _buildLanguageItem(Language language) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(language.name),
          SizedBox(width: 8.0),
          Flexible(child: Text("(${language.isoCode})"))
        ],
      );

  void _openCurrentLanguagePicker() => showDialog(
      barrierColor: Colors.white.withOpacity(0.50),
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LanguagePickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.grey[300],
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Select your language'),
              onValuePicked: (Language language) {
                setState(() {
                  _selectedLanguage = language;
                  print(_selectedLanguage.name);
                  print(_selectedLanguage.isoCode);
                  currentLenguage = _selectedLanguage.name;
                  currentLenguageIso = _selectedLanguage.isoCode;
                });
              },
              itemBuilder: _buildLanguageItem),
        );
      });

  void _openLanguagePickerDialogFrom() => showDialog(
      barrierColor: Colors.white.withOpacity(0.50),
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LanguagePickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.grey[300],
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Select your language'),
              onValuePicked: (Language language) {
                setState(() {
                  _selectedLanguage = language;
                  print(_selectedLanguage.name);
                  print(_selectedLanguage.isoCode);
                  originLeng = _selectedLanguage.name;
                  langFrom = _selectedLanguage.isoCode;
                });
              },
              itemBuilder: _buildLanguageItem),
        );
      });

  void _openLanguagePickerDialogToo() => showDialog(
      barrierColor: Colors.white.withOpacity(0.50),
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LanguagePickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.grey[300],
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Select your language'),
              onValuePicked: (Language language) {
                setState(() {
                  _selectedLanguage = language;
                  print(_selectedLanguage.name);
                  print(_selectedLanguage.isoCode);
                  destLeng = _selectedLanguage.name;
                  langTo = _selectedLanguage.isoCode;
                });
              },
              itemBuilder: _buildLanguageItem),
        );
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R E D I',
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        _openCurrentLanguagePicker();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentLenguage,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currentLenguageIso,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 15),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         ' Revolt Dictionary',
              //         style:
              //             TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              //       ),
              //       Row(
              //         children: [
              //           InkWell(
              //             onTap: () {
              //               setState(() {
              //                 isREDI = true;
              //               });
              //             },
              //             child: Text(
              //               'Kamus',
              //               style: TextStyle(
              //                   fontSize: isREDI ? 15 : 14,
              //                   decoration: isREDI
              //                       ? TextDecoration.underline
              //                       : TextDecoration.none,
              //                   color: isREDI ? Colors.black : Colors.grey,
              //                   fontWeight: isREDI
              //                       ? FontWeight.bold
              //                       : FontWeight.normal),
              //             ),
              //           ),
              //           SizedBox(
              //             width: 10,
              //           ),
              //           InkWell(
              //             onTap: () {
              //               setState(() {
              //                 isREDI = false;
              //               });
              //             },
              //             child: Text(
              //               'Translate',
              //               style: TextStyle(
              //                   fontSize: !isREDI ? 15 : 14,
              //                   decoration: !isREDI
              //                       ? TextDecoration.underline
              //                       : TextDecoration.none,
              //                   color: !isREDI ? Colors.black : Colors.grey,
              //                   fontWeight: !isREDI
              //                       ? FontWeight.bold
              //                       : FontWeight.normal),
              //             ),
              //           ),
              //         ],
              //       )
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
              // !isREDI
              selectedType == 'translate'
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        // margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.grey, blurRadius: 2.5)
                            ]),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onChanged: (String text) {
                                  // if (_debounce.isActive) _debounce.cancel();
                                  // _debounce =
                                  //     Timer(const Duration(milliseconds: 1000), () {
                                  //   _search();
                                  // });
                                  loadWords(text);
                                },
                                onSubmitted: (value) {
                                  if (isLoad) {
                                    _search();
                                  }
                                },
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Search for a word",
                                  contentPadding:
                                      const EdgeInsets.only(left: 24.0),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _controller.text != '' ? true : false,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.text = '';
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _search();
                              },
                            )
                          ],
                        ),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              listType(),

              selectedType == 'translate' ? tranlatorBody() : Container(),
              SizedBox(
                height: 10,
              ),
              dictionaryBody(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              )
            ],
          ),
        ),
      ),
    );
  }

  listType() {
    return SizedBox(
      height: 35,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        children: [
          InkWell(
            onTap: () {
              filterType('');
            },
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: selectedType == '' ? Colors.black : Colors.white),
              child: Text(
                'Dicrionary',
                style: TextStyle(
                    color: selectedType == '' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              filterType('translate');
            },
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: selectedType == 'translate'
                      ? Colors.black
                      : Colors.white),
              child: Text(
                'Translate',
                style: TextStyle(
                    color: selectedType == 'translate'
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              filterType('words');
            },
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: selectedType == 'words' ? Colors.black : Colors.white),
              child: Text(
                'Words',
                style: TextStyle(
                    color:
                        selectedType == 'words' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              filterType('sentences');
            },
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: selectedType == 'sentences'
                      ? Colors.black
                      : Colors.white),
              child: Text(
                'Sentences',
                style: TextStyle(
                    color: selectedType == 'sentences'
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              filterType('thesaurus');
            },
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: selectedType == 'thesaurus'
                      ? Colors.black
                      : Colors.white),
              child: Text(
                'Thesaurus',
                style: TextStyle(
                    color: selectedType == 'thesaurus'
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  tranlatorBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                    onPressed: () {
                      _openLanguagePickerDialogFrom();
                    },
                    child: Text(
                      originLeng,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
              ),
              IconButton(
                  onPressed: () {
                    swapLenguageCode(langFrom, langTo, tranlated);
                    swapLenguage(originLeng, destLeng);
                  },
                  icon: Icon(
                    Icons.compare_arrows_rounded,
                    size: 30,
                  )),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      _openLanguagePickerDialogToo();
                    },
                    child: Text(
                      destLeng,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2.5)]),
            child: Column(
              children: [
                TextField(
                  minLines: 2,
                  maxLines: null,
                  controller: tranlateController,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  onChanged: (text) async {
                    // final translator = GoogleTranslator();
                    translation = await GoogleTranslator()
                        .translate(text, from: langFrom, to: langTo);
                    tranlated = translation.text.toString();
                    setState(() {});
                    print(langFrom + " to " + langTo);
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      hintText: 'Masukan Teks',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                      border: InputBorder.none),
                ),
                tranlateController.text == ''
                    ? SizedBox(
                        height: 0,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  tranlateController.text = '';
                                  tranlated = '';
                                });
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                size: 35,
                                color: Colors.grey,
                              ))
                        ],
                      ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 2,
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                      minHeight: 100,
                      maxHeight: double.infinity,
                      minWidth: double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        tranlated,
                        style: TextStyle(
                          color: Colors.indigoAccent[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                        ClipboardData(text: tranlated))
                                    .then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor: Colors.grey[300],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          content: Text(
                                            "Copied to clipboard",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          )));
                                });
                              },
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 35,
                                color: Colors.grey,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  dictionaryBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Center(
                  child: Text("Enter a search word"),
                ),
              );
            }

            if (snapshot.data == "waiting") {
              return SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                print(snapshot.data.length);
                var meanings = snapshot.data[index]['meanings'];
                print(meanings.length);
                var phonetic = snapshot.data[index]['phonetic'] != null
                    ? snapshot.data[index]['phonetic']
                    : '';
                var phonetics = snapshot.data[index]['phonetics'];
                print('phonetics: ' + phonetics.length.toString());
                return ListBody(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.grey, blurRadius: 2.5)
                          ]),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${snapshot.data[index]['word']}  ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  phonetic,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: ListView.builder(
                                      itemCount: 1,
                                      shrinkWrap: true,
                                      itemBuilder: (context, phoIndex) {
                                        print('audio: ' +
                                            phonetics[phoIndex]['audio']
                                                .toString());
                                        var audio =
                                            phonetics[phoIndex]['audio'];
                                        return InkWell(
                                          onTap: audio == ''
                                              ? null
                                              : () async {
                                                  String audioasset =
                                                      phonetics[phoIndex]
                                                          ['audio'];
                                                  _play(audioasset);

                                                  // AssetsAudioPlayer.playAndForget(
                                                  //     Audio.network(
                                                  //         phonetics[
                                                  //                 phoIndex]
                                                  //             ['audio'],
                                                  //         // '',
                                                  //         metas: Metas(
                                                  //             title:
                                                  //                 "${snapshot.data[index]['word']}")));
                                                },
                                          child: Icon(
                                            audio == ''
                                                ? Icons.volume_off_rounded
                                                : Icons.volume_up_rounded,
                                            size: 35,
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: ListView.builder(
                          shrinkWrap: true,
                          // itemCount: meanings.length,
                          itemCount: 1,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, meanIndex) {
                            var defnisi = meanings[meanIndex]['definitions'];
                            var partOfSpeech =
                                meanings[meanIndex]['partOfSpeech'];
                            return ListView.builder(
                              shrinkWrap: true,
                              // itemCount: defnisi.length,
                              itemCount: 1,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, defIndex) {
                                var example =
                                    defnisi[defIndex]['example'] != null
                                        ? defnisi[defIndex]['example']
                                        : '_';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$partOfSpeech',
                                      // GoogleTranslator().translate('$partOfSpeech' ,from: 'en', to: currentLenguageIso),
                                      style: TextStyle(
                                          color: Colors.indigoAccent[700],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Definition : ${defnisi[defIndex]['definition']}',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'example : ${example}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                barrierColor: Colors.grey
                                                    .withOpacity(0.50),
                                                isScrollControlled: true,
                                                constraints: BoxConstraints(
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height -
                                                            200),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(12),
                                                            topRight:
                                                                Radius.circular(
                                                                    12))),
                                                context: context,
                                                builder: (context) {
                                                  return ListTile(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: 20),
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "${snapshot.data[index]['word']}  ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              phonetic,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            SizedBox(
                                                              height: 30,
                                                              width: 30,
                                                              child: ListView
                                                                  .builder(
                                                                      itemCount:
                                                                          1,
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemBuilder:
                                                                          (context,
                                                                              phoIndex) {
                                                                        print('audio: ' +
                                                                            phonetics[phoIndex]['audio'].toString());
                                                                        var audio =
                                                                            phonetics[phoIndex]['audio'];
                                                                        return InkWell(
                                                                          onTap: audio == ''
                                                                              ? null
                                                                              : () {
                                                                                  String audioasset = phonetics[phoIndex]['audio'];
                                                                                  _play(audioasset);
                                                                                },
                                                                          child:
                                                                              Icon(
                                                                            audio == ''
                                                                                ? Icons.volume_off_rounded
                                                                                : Icons.volume_up_rounded,
                                                                            size:
                                                                                35,
                                                                          ),
                                                                        );
                                                                      }),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          meanings.length,
                                                      physics: ScrollPhysics(),
                                                      itemBuilder:
                                                          (context, meanIndex) {
                                                        var defnisi =
                                                            meanings[meanIndex]
                                                                ['definitions'];
                                                        var partOfSpeech =
                                                            meanings[meanIndex][
                                                                'partOfSpeech'];
                                                        return ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              defnisi.length,
                                                          // itemCount: 1,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemBuilder: (context,
                                                              defIndex) {
                                                            return Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Speech :  $partOfSpeech',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .orange,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  'Definition : ${defnisi[defIndex]['definition']}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  'example : ${example}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              'More',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      // child: Text(snapshot.data["definitions"][index]["definition"]),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
