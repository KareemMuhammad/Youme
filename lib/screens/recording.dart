import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/ripple_animation.dart';

class RecordMemory extends StatefulWidget {
  final Function onSaved;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;
  const RecordMemory({Key key, this.onSaved, this.userProvider, this.diaryProvider}) : super(key: key);

  @override
  _RecordMemoryState createState() => _RecordMemoryState();
}

enum RecordingState {
  UnSet,
  Set,
  Recording,
  Stopped,
}

enum PlayingState {
  Resumed,
  Played,
  Stopped,
}

class _RecordMemoryState extends State<RecordMemory> with SingleTickerProviderStateMixin{

  bool _isRecording = false;
  PlayingState _playingState = PlayingState.Played;
  RecordingState _recordingState = RecordingState.UnSet;
  Directory appDirectory;
  bool _isPlaying = false;
  String path = '';
  AudioPlayer _audioPlayer = AudioPlayer();
  String currentTime = "00:00";
  String completeTime= "00:00";
  bool playRecord = false;
  final _audioRecorder = Record();
  final formKey = GlobalKey<FormState>();
  double _duration= 0;
  double _position = 0;
  TextEditingController textController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    checkPermission();
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
    _recordingState = RecordingState.UnSet;
    appDirectory = null;
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Record an Audio',style: TextStyle(fontSize: 19,color: textColor),),
        leading: IconButton(
          onPressed: (){
            _deleteRecord();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
         _isRecording == false ?  Container(
             alignment: Alignment.center,
             child: toggle())
                :
             RippleAnimation(onPressed: _onRecordButtonPressed,),
            SizedBox(height: 10,),
            playRecord ? toggle2(path) : Container(),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18,vertical: 1),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: buttons,
                elevation: 2,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () async{
                    if(path.isNotEmpty) {
                      widget.userProvider.uploadRecord(path);
                      widget.userProvider.reloadPostChoice(Utils.OTHERS);
                      Navigator.pop(context);
                    }else{
                      Utils.showToast('Please set a record!');
                    }
                  },
                  child: Text('Submit',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

Widget toggle() {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: GestureDetector(
      onTap: ()async{
        _onRecordButtonPressed();
      },
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: float,
          borderRadius: BorderRadius.all(Radius.circular(60)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(.3),
              blurRadius: 15,
              offset: Offset(5, 5),
            )
          ],
        ),
        child: Icon(
          Icons.mic,
          size: 80,
          color: textColor,
        ),
      ),
    ),
  );
}

Widget toggle2(String filePath) {
  return Stack(
    children: [
      Container(
        color: buttons,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(10),
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
                    backgroundColor: float,
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
                    backgroundColor: float,
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
    ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: (){
             _deleteRecord();
            },
            child: CircleAvatar(
                backgroundColor: icons,
                radius: 20,
                child: Icon(Icons.close,size: 25,color: textColor,)
            ),),
        ),
      )
  ]
  );
}

  void checkPermission()async{
    if(await _audioRecorder.hasPermission()){
      _recordingState = RecordingState.Set;
      appDirectory = await getApplicationDocumentsDirectory();
    }else{
      _recordingState = RecordingState.UnSet;
    }
  }

  Future<void> _onRecordButtonPressed() async {
    switch (_recordingState) {
      case RecordingState.Set:
        setState(() {
          _isRecording = true;
        });
        await _recordVoice();
        break;

      case RecordingState.Recording:
        setState(() {
          _isRecording = false;
        });
        await _stopRecording();
        _recordingState = RecordingState.Stopped;
        break;

      case RecordingState.Stopped:
        setState(() {
          _isRecording = true;
        });
        await _recordVoice();
        break;

      case RecordingState.UnSet:
        setState(() {
          _isRecording = false;
        });
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Please allow recording from settings.'),
        ));
        break;
    }
  }

  _initRecorder() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String filePath = appDirectory.path + '/' +
        DateTime.now().millisecondsSinceEpoch.toString() + '.aac';
     await _audioRecorder.start(path: filePath);
  }

  _stopRecording() async {
    final recordPath = await _audioRecorder.stop();
   _onRecordComplete(recordPath);
  }

  Future<void> _recordVoice() async {
      await _initRecorder();
      bool isRecording = await _audioRecorder.isRecording();
      if(isRecording) {
        _recordingState = RecordingState.Recording;
        _audioPlayer.onAudioPositionChanged.listen((Duration duration){
          setState(() {
            currentTime = duration.toString().split(".")[0];
          });
        });
      }
  }

_onRecordComplete(String recordPath) async{
  setState(() {
    path = recordPath;
    playRecord = true;
  });
  print(path);
}

_deleteRecord() async{
  if(path.isNotEmpty) {
    final file = File(path);
    await file.delete();
    setState(() {
      path = '';
      playRecord = false;
    });
    widget.userProvider.setRecordPath('');
  }
}

Future<void> _onPlayButtonPressed() async {
  switch (_playingState) {
    case PlayingState.Played:
      _onPlay(filePath: path);
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
    _audioPlayer.play(filePath, isLocal: true);
    _playingState = PlayingState.Stopped;
    setState(() {
      _isPlaying = true;
    });
  }else{
    Utils.showToast('Please record anything!');
  }
}
}