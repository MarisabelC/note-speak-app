import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'notes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:screen/screen.dart';

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
  String _lastWords = '';
  bool _isListening = false;

  double _progressValue = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
    _updateProgress();
    Screen.keepOn(true);

  }

  void _updateProgress() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
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
    _speechRecognition.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: false);
  }

  void stopListening() {
    print('stop');
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
      _isListening = false;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      if (_resultText.length > 6)
        _resultText = _resultText.substring(0, _resultText.length - 6) + '. ';
      _resultText += "${result.recognizedWords} - ${result.finalResult}";
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
    Timer.periodic(oneSec, (Timer t) {
      if (_isListening) {
        startListening();
      }else
        t.cancel();
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
            image: AssetImage('assets/green_dust_scratch.png'),
            fit: BoxFit.cover),
      ),
      child: _loading
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 8,
                      child: Tab(
                          icon: Image.asset("assets/notespeak_logo.jpg"),
                          iconMargin: EdgeInsets.only(
                              left: width, right: width, top: height),
                          text: "Notespeak")),
                  Expanded(flex: 1, child: Text('loading...')),
                  Expanded(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(bottom: height / 2),
                        padding: EdgeInsets.only(left: width, right: width),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                        )),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          alignment: Alignment.topCenter,
                          child: Text('${(_progressValue * 100).round()}%'))),
                ],
              ),
            )
          : Container(
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
                          _resultText.length != 0
                              ? _resultText.substring(0, _resultText.length - 6)
                              : _resultText,
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
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: .26,
                                    spreadRadius: _level * 1.5,
                                    color: Colors.black.withOpacity(.5))
                              ],
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: FloatingActionButton(
                              heroTag: "btn1",
                              child: Icon(Icons.mic),
                              onPressed: () {
                                setState(() {
                                  _isListening = true;
                                  _resultText = '';
                                });
                                if (_isAvailable &&
                                    !_speechRecognition.isListening)
                                  startListening();
                                continueListening();
                              },
                              backgroundColor: Colors.pink,
                            ),
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
                              Screen.keepOn(false);

                              if (_speechRecognition.isListening || _isListening) {

                                cancelListening();
                              }


                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotesHome(_resultText.substring(0,_resultText.length-6))),
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
