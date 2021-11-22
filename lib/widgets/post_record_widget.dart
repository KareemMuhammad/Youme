import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:umee/utils/shared.dart';

class PostRecordWidget extends StatefulWidget {
  final String path;

  const PostRecordWidget({Key key, this.path}) : super(key: key);
  @override
  _PostRecordWidgetState createState() => _PostRecordWidgetState();
}
enum PlayingState {
  Resumed,
  Played,
  Stopped,
}
class _PostRecordWidgetState extends State<PostRecordWidget> {
  bool playRecord = false;
  PlayingState _playingState = PlayingState.Played;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String currentTime = "00:00";
  String completeTime= "00:00";
  double _duration= 0;
  double _position = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setUrl(widget.path);
    _audioPlayer.onAudioPositionChanged.listen((Duration duration){
      setState(() {
        currentTime = duration.toString().split(".")[0];
        _position = duration.inSeconds.toDouble();
      });
    });
    _audioPlayer.onDurationChanged.listen((Duration duration){
      setState(() {
        completeTime = duration.toString().split(".")[0];
        _duration = duration.inSeconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
            color: buttons,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        _onPlayButtonPressed();
                      },
                      child: CircleAvatar(
                        child:  Icon(_isPlaying ? Icons.pause : Icons.play_arrow,color: textColor,size: 40,),
                        radius: 30,
                        backgroundColor: background,
                      ),
                    ),
                    SizedBox(width: 50,),
                    InkWell(
                      onTap: (){
                        _audioPlayer.stop();
                        _playingState = PlayingState.Played;
                        setState(() {
                          _isPlaying = false;
                          currentTime = "00:00";
                          _position = 0.0;
                        });
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: background,
                        child:  Icon(Icons.stop,color: textColor,size: 40,),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(currentTime, style: TextStyle(fontWeight: FontWeight.w700,color: textColor),),
                    Text(" | ",style: TextStyle(fontWeight: FontWeight.bold,color: textColor),),
                    Text(completeTime, style: TextStyle(fontWeight: FontWeight.w300,color: textColor),),
                  ],
                ),
                Slider(
                    value: _position,
                    min: 0.0,
                    max: _duration,
                    onChanged: (double value) {
                      setState(() {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      });}
                ),
              ],
            ),
    );
  }

  Future<void> _onPlayButtonPressed() async {
    switch (_playingState) {
      case PlayingState.Played:
        _onPlay(filePath: widget.path);
        break;

      case PlayingState.Resumed:
        _audioPlayer.resume();
        _playingState = PlayingState.Stopped;
        setState(() {
          _isPlaying = true;
        });
        break;

      case PlayingState.Stopped:
        _audioPlayer.pause();
        _playingState = PlayingState.Resumed;
        setState(() {
          _isPlaying = false;
        });
        break;
    }
  }

  Future<void> _onPlay({@required String filePath}) async {
    if(filePath.isNotEmpty || filePath == null) {
      _audioPlayer.play(filePath);
      _playingState = PlayingState.Stopped;
      setState(() {
        _isPlaying = true;
      });
    }
  }
}
