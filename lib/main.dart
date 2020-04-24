import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  SpeechToText _speechRecognition;
  bool _isAvailable = false;
  double _level = 0.0;
  String _resultText = "";
  bool _isListening = false;

  double _progressValue = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
    _updateProgress();
  }

  void _updateProgress() {
    const oneSec = const Duration(seconds: 1);
    new Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue += 0.25;
        // we "finish" downloading here
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          t.cancel();
          _loading = false;
          return;
        }
      });
    });
  }

  Future<void> initSpeechRecognizer() async {
    _speechRecognition = SpeechToText();
    bool hasSpeech = await _speechRecognition.initialize(
        onError: errorListener, onStatus: statusListener);
    if (!mounted) return;
    setState(() {
      _isAvailable = hasSpeech;
    });
  }

  void startListening() {
    var currentLocaleId = 'en_US';
    _resultText = "";
    _speechRecognition.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true);
  }

  void stopListening() {
    _speechRecognition.stop();
    setState(() {
      _level = 0.0;
      _isListening = false;
    });
  }

  void cancelListening() {
    _speechRecognition.cancel();
    setState(() {
      _level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      _resultText = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      _level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
//      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    setState(() {
//      lastStatus = "$status";
    });
  }

  void continueListening() {
    const oneSec = const Duration(seconds: 1);
    var timer = new Timer.periodic(oneSec, (Timer timer) {
      if (_isListening) {
        startListening();
      }
    });
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
    double width = MediaQuery.of(context).size.width * .1;
    double height = MediaQuery.of(context).size.height * .1;
    return Scaffold(
        body: DecoratedBox(
      position: DecorationPosition.background,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/green_dust_scratch.png'), fit: BoxFit.cover),
      ),
     child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: new SingleChildScrollView(
                        child: Text(
                          _resultText,
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
//                  FloatingActionButton(
//                    heroTag: "btn2",
//                    child: Icon(Icons.cancel),
//                    mini: true,
//                    backgroundColor: Colors.deepOrange,
//                    onPressed: _speechRecognition.isListening ? cancelListening : null
//                  ),
                          FloatingActionButton(
                            heroTag: "btn1",
                            child: Icon(Icons.mic),
                            onPressed: () {
                              if (_isAvailable &&
                                  !_speechRecognition.isListening)
                                startListening();
                              continueListening();
                            },
                            backgroundColor: Colors.pink,
                          ),
                          FloatingActionButton(
                            heroTag: "btn2",
                            child: Icon(Icons.stop),
                            mini: true,
                            backgroundColor: Colors.deepPurple,
                            onPressed: _speechRecognition.isListening
                                ? stopListening
                                : null,
                          ),
                          RaisedButton(
                            onPressed: () {
                              _speechRecognition.isListening
                                  ? cancelListening
                                  : null;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotesHome(_resultText)),
                              );
                            },
                            child: const Text('Generate Notes',
                                style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    ));
  }
}
