import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:screen/screen.dart';
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
  double _progressValue = 0.0;
  bool _loading = true;

  String _resultText = "";

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
        setState(() => _resultText = speech);
      },
    );

    _speechRecognition.setRecognitionCompleteHandler(() {
      print("setRecognitionCompleteHandler");
      setState(() => _isListening = false);
    });

    _speechRecognition.activate().then((result) {
      print("activate: " + result.toString());
      setState(() => _isAvailable = result);
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
            image: AssetImage('assets/background.png'), fit: BoxFit.cover),
      ),
      child: _loading
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 8,
                      child: Column(
                        children: <Widget>[
                          Expanded(flex: 3, child: Text('')),
                          Expanded(
                            flex: 4,
                            child: Tab(
                              icon: Image.asset(
                                "assets/notespeak_logo.jpg",
                              ),
                              iconMargin: EdgeInsets.only(
                                  left: width, right: width, top: height),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                'NoteSpeak',
                                style: TextStyle(
                                    fontSize: 50,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )),
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
                      child: SingleChildScrollView(
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
                          FloatingActionButton(
                            heroTag: "start",
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
                            heroTag: "stop",
                            child: Icon(
                              Icons.stop,
                            ),
//                    mini: true,
                            backgroundColor: Colors.deepPurple,
                            onPressed: () {
                              if (_isListening)
                                _speechRecognition.stop().then(
                                      (result) =>
                                          setState(() => _isListening = result),
                                    );
                            },
                          ),
                          FloatingActionButton(
                            heroTag: "generate notes",
                            child: Icon(
                              Icons.create,
                            ),
                            onPressed: () {
                              if (_isListening) {
                                _speechRecognition.cancel().then(
                                      (result) => setState(() {
                                        _isListening = result;
                                      }),
                                    );
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotesHome(_resultText)),
                              );
                            },

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
