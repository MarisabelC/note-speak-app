import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'notes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceHome(),
    );
  }
}

class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) {
        print("setAvailabilityHandler: " + result.toString());
//        setState(() => _isAvailable = result);
      },
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) {
        print("setResultText");
        setState(() => resultText = speech);
      },
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () {
        print("setRecognitionCompleteHandler");
        setState(() => _isListening = false);
      }
    );

    _speechRecognition.activate().then(
          (result) {
            print("activate: " + result.toString());
            setState(() => _isAvailable = result);
          }
        );
  }

  _launchURL(url) async {
//    const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: "btn2",
                    child: Icon(Icons.cancel),
                    mini: true,
                    backgroundColor: Colors.deepOrange,
                    onPressed: () {
                      if (_isListening)
                        _speechRecognition.cancel().then(
                              (result) => setState(() {
                                    _isListening = result;
                                    resultText = "";
                                  }),
                            );
                    },
                  ),
                  FloatingActionButton(
                    heroTag: "btn1",
                    child: Icon(Icons.mic),
                    onPressed: () {
                      if (_isAvailable && !_isListening)
                        _speechRecognition
                            .listen(locale: "en_US")
                            .then((result) => print('$result'));
                    },
                    backgroundColor: Colors.pink,
                  ),
                  FloatingActionButton(
                    heroTag: "btn3",
                    child: Icon(Icons.stop),
                    mini: true,
                    backgroundColor: Colors.deepPurple,
                    onPressed: () {
                      if (_isListening)
                        _speechRecognition.stop().then(
                              (result) => setState(() => _isListening = result),
                            );
                    },
                  ),
                ],
              ),
            ),
            new Flexible(
              flex: 5,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent[100],
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  child: new SingleChildScrollView( child: Text(
                    resultText,
                    style: TextStyle(fontSize: 24.0),
                  ),
                  ),
                ),
            ),
            new Flexible(
              flex: 1,
              child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        if (_isListening) {
                          _speechRecognition.cancel().then(
                                (result) =>
                                setState(() {
                                  _isListening = result;
                                }),
                          );
                        }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotesHome(resultText)),
                          );
                      },
                      child: const Text(
                          'Generate Notes',
                          style: TextStyle(fontSize: 20)
                      ),
                    ),
              ],
            )
            )
          ],
        ),
      ),
    );
  }
}
