import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_design/UIElement/CircleClipper.dart';
import 'package:music_design/UIElement/bottom_control.dart';
import 'package:music_design/songs.dart';
import 'package:music_design/theme.dart';
import 'package:music_design/utility/gestures.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              color: Color(0xFFDDDDDD),
              onPressed: () {}),
          title: new Text(''),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.menu),
                color: Color(0xFFDDDDDD),
                onPressed: () {
                  //TODO
                }),
          ],
        ),
        body: new Column(
          children: <Widget>[
            // Seek bar
            new Expanded(
                child: RadialSeekBar()),
            // Visualizer
            new Container(
              width: double.infinity,
              height: 125.0,
            ),

            // Song title, artist name, and controls
            new ButtomControls()
          ],
        ));
  }
}


class RadialSeekBar extends StatefulWidget {


  final double seekPercent;

  RadialSeekBar({
    this.seekPercent = 0.0
  });

  @override
  RadialSeekBarState createState() {
    return new RadialSeekBarState();
  }
}

class RadialSeekBarState extends State<RadialSeekBar> {
  double _seekPercent = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;


  @override
  void initState() {
    _seekPercent = widget.seekPercent;
  }


  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seekPercent = widget.seekPercent;
  }

  void _onDragStart(PolarCoord coord) {
    _startDragCoord = coord;
    _startDragPercent = _seekPercent;
  }

  void _onDragUpdate(PolarCoord coord) {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);

    setState(() => _currentDragPercent = (_startDragPercent + dragPercent) % 1.0);
  }

  void _onDragEnd() {
    setState(() {
      _seekPercent = _currentDragPercent;
      _currentDragPercent = null;
      _startDragPercent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: new Center(
          child: new Container(
            width: 140.0,
            height: 140.0,
            child: RadialProgressBar(
              progressPercent: _currentDragPercent ?? _seekPercent,
              progressColor: accentColor,
              thumbColor: lightAccentColor,
              trackColor: const Color(0xFFDDDDDD),
              thumbPosition: _currentDragPercent ?? _seekPercent,
              innerPadding: const EdgeInsets.all(10.0),
              child: ClipOval(
                // don't understand this part
                clipper: new CircleClipper(),
                child: new Image.network(
                  demoPlaylist.songs[0].albumArtUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final double progressPercent;
  final Color progressColor;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar({this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.thumbSize = 10.0,
    this.thumbColor = Colors.black,
    this.progressPercent = 0.0,
    this.thumbPosition = 0.0,
    this.outerPadding = const EdgeInsets.all(0.0),
    this.innerPadding = const EdgeInsets.all(0.0),
    this.child});

  @override
  State<StatefulWidget> createState() {
    return new _RadialProgressBarState();
  }
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsForPainter() {
    // Make room for the painted track, progress, and thumb. We divide by 2.0 because we want to allow flush painting against the track, so we only need to account the thickness outside the track, not inside
    final outerThickness =
    max(widget.trackWidth, max(widget.progressWidth, widget.thumbSize));
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: widget.outerPadding,
      child: new CustomPaint(
        foregroundPainter: new RadialSeekBarPainter(
            trackWidth: widget.trackWidth,
            trackColor: widget.trackColor,
            progressWidth: widget.progressWidth,
            progressColor: widget.progressColor,
            progressPercent: widget.progressPercent,
            thumbSize: widget.thumbSize,
            thumbColor: widget.thumbColor,
            thumbPosition: widget.thumbPosition),
        child: new Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final double progressPercent;
  final Paint progressPaint;
  final double thumbSize;
  final Paint thumbPaint;
  final double thumbPosition;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required this.progressPercent,
    @required progressColor,
    @required this.thumbSize,
    @required thumbColor,
    @required this.thumbPosition,
  })
      : trackPaint = new Paint()
    ..color = trackColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = trackWidth,
        progressPaint = new Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = new Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    Size constraintedSize =
    new Size(size.width - outerThickness, size.height - outerThickness);

    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(constraintedSize.width, constraintedSize.height) / 2;
    // Paint track.
    canvas.drawCircle(center, radius, trackPaint);

    // Paint Progress
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        progressAngle, false, progressPaint);

    // Paint thumb,
    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = new Offset(thumbX, thumbY) + center;
    final thumbRaius = thumbSize / 2.0;
    canvas.drawCircle(thumbCenter, thumbRaius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
