import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttie/fluttie.dart';
import 'package:flute_music_player/flute_music_player.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}
enum PlayerState { stopped, playing, paused }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Castit',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Castit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  PlayerState playerState = PlayerState.stopped;
  FluttieAnimationController gradient;
  FluttieAnimationController playPause;
  FluttieAnimationController flow;
  String kUrl = "http://123bpm.fm:50000/first";
  bool isPlaying = false;
  MusicFinder audioPlayer = new MusicFinder();

  Future play() async {
    final result = await audioPlayer.play(kUrl);
    if (result == 1)
      setState(() {
        print('_AudioAppState.play... PlayerState.playing');
        playerState = PlayerState.playing;
      });
  }

  stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
    });
  }

  prepareAnimation() async {
    // Checks if the platform we're running on is supported by the animation plugin
    bool canBeUsed = await Fluttie.isAvailable();
    if (!canBeUsed) {
      print("Animations are not supported on this platform");
      return;
    }

    var instance = new Fluttie();
    var myComposition = await instance.loadAnimationFromResource(
        "animations/gradient_animated_background.json",
        //replace with your asset file
        bundle: DefaultAssetBundle.of(context)
    );
    var playComp = await instance.loadAnimationFromResource(
        "animations/play,_pause.json",
        bundle: DefaultAssetBundle.of(context)
    );
    var flowComp = await instance.loadAnimationFromResource(
        "animations/flow.json",
        bundle: DefaultAssetBundle.of(context)
    );
    playPause = await instance.prepareAnimation(
        playComp, duration: const Duration(seconds: 1),
        repeatCount: const RepeatCount.infinite(),
        repeatMode: RepeatMode.REVERSE);
    gradient = await instance.prepareAnimation(
        myComposition, duration: const Duration(minutes: 2),
        repeatCount: const RepeatCount.infinite(),
        repeatMode: RepeatMode.START_OVER);
    flow = await instance.prepareAnimation(
        flowComp,
        repeatCount: const RepeatCount.infinite(),
        repeatMode: RepeatMode.START_OVER);
    setState(() {
      gradient.start();
    });
  }

  @override
  initState() {
    super.initState();

    /// Load and prepare our animations after this widget has been added
    prepareAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Positioned.fill(child: new FluttieAnimation(gradient)),
              new Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Container(
                        padding: new EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 150.0),
                        child: new Center(
                            child: new Text("Castit", style: new TextStyle(
                                color: Colors.white,
                                fontSize: 56.0,
                                fontWeight: FontWeight.w100),)
                        )
                    ),
                    new Padding(padding: new EdgeInsets.only(bottom: 50.0),
                        child: new InkWell(
                          onTap: () async {
                            playPause.unpause();
                            playerState == PlayerState.playing ? stop() : play();
                            playerState == PlayerState.playing ? flow.pause():flow.unpause();
                            await
                            new Future.delayed(new Duration(seconds: 1));
                            playPause.pause();
                          },
                          child: new FluttieAnimation(playPause),
                        )),
                    new Container(
                      padding: new EdgeInsets.only(bottom: 50.0),
                        child: new FluttieAnimation(flow),width: MediaQuery.of(context).size.width,)
                  ])
            ]
        )
    );
  }
}
