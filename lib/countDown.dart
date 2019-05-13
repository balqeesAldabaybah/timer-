import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:screen/screen.dart';
import 'dart:async';
import 'package:firebase_admob/firebase_admob.dart';
import 'FavoriteModel.dart';
import 'DataBase.dart';
import 'main.dart';
import 'package:flutter/services.dart';


class CountDown extends StatefulWidget {
  int seconds;
  CountDown(this.seconds);
  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> with TickerProviderStateMixin,WidgetsBindingObserver {



  List<FavoriteTime> _favoritLst = [];
  List<FavoriteTime> _allTimers = [];
  final myController = TextEditingController();
  final updateController = TextEditingController();
  bool isDismessed = false;
  Icon _favoriteIcon = Icon(Icons.favorite_border); 
  FavoriteTime currentStateTime = new FavoriteTime() ;
  String currenttimerName="";
  String updatetimerName="";
  bool _Play_pause = false;
  Icon _Play_pause_icon = Icon(Icons.play_arrow);

  AppLifecycleState _appLifecycleState;
  static const platform = const MethodChannel('runAlarm');

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['business','education','pandora charm bracelet','chest','games','golf','cook','recipe','children','kid','random','shuffle','home','smart','generator','ads','manager','list','ToDo','letters','teaching','schools','winner','music','sounds','flutter','modanisa','hijab','shopping','laptop','Technology','red','hospital','mediciine','booking.com','hotels','donate','charity','live','apple','goverment'
      ,'cars','LG','IKEA','empathy','pubg','run','marathon','kitchen','beko','swimming','socks','hp','health','parking','Netflix','trainer','IOT','IT','glasses','shoes','teeth','paste','scarfs','accessories','GPU','CPU','mouse','rain','romance','books','good reader','secrests'
      'joly','saiva ','dallas','trivago','anything'],
      childDirected: false,
    );

  InterstitialAd interAd;
  InterstitialAd buildinterAd(){
    return InterstitialAd(
      adUnitId: "ca-app-pub-6067078449221772/7056691070",

      targetingInfo: targetingInfo,
       listener: (MobileAdEvent event) {
          print("InterstitialAd event is $event");
        },
      );
  }
  AnimationController controller;
  String get timerString{
    Duration duration = controller.duration*controller.value;
    return '${duration.inHours}:${(duration.inMinutes%60).toString().padLeft(2,'0')}:${(duration.inSeconds%60).toString().padLeft(2,'0')}';
  }


  int _intialSeconds;
  String intialTime = 'Tap here';

  static AudioCache player = new AudioCache();
  static const  alarmAudioPath = "sound_alarm_1.mp3";
  static AudioPlayer audioPlayer = new AudioPlayer();



  
   

  IconData volum ;

@override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    print("controller disposed");
    interAd?.dispose();
    myController.dispose();
    
    super.dispose();
    
  }


@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
   
    super.didChangeAppLifecycleState(state);
    setState(() {
     _appLifecycleState = state; 
    });
    switch(state){
      case AppLifecycleState.inactive:
      print("*************************************************************inactive state");
      break;
      case AppLifecycleState.paused:
      print("********************************************************* paused state");
      Duration d = controller.duration*controller.value;
      interAd..load()..show();
      _playAlarm((d.inSeconds).toString());
      print("controller value ${d.inSeconds}");
      break;
      case AppLifecycleState.resumed:
      interAd..load()..show();
      _playAlarm("r");
      print("*************************************************************** resumed state");
      break;
      case AppLifecycleState.suspending:
      print("******************************************************************* suspending state");
      break;
    }
  }
 
  Future<void> _playAlarm(String value) async{
    try{
      int result = await platform.invokeMethod('playAlarm',{"value":value});
      print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr$result');
    }on PlatformException catch (e){
      print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee$e');
    }
  }

  @override
  void initState()  {
    WidgetsBinding.instance.addObserver(this);
    Screen.keepOn(true);
    _intialSeconds = widget.seconds;
    
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(seconds: widget.seconds))
      ..addStatusListener((status){
       
          if(status == AnimationStatus.dismissed && _intialSeconds!=0 && controller.value == 0.0 ) {
            print("controller ${controller.value}");
          
            onTimeDismissed();
            setState(() {
              _Play_pause = false;
              _Play_pause_icon = Icon(Icons.play_arrow) ; 
            });
            setState(() {
              if(controller.value == 0.0){
                isDismessed = true;
              }
            });
           
            interAd..load()..show();
          }
     
      });

      volum = Icons.volume_up;
    
      FirebaseAdMob.instance.initialize(appId: "ca-app-pub-6067078449221772~3533081369");
      interAd =  buildinterAd()..load();
      currentStateTime = new FavoriteTime(time: -1,isFavorite: 0,title: "dump");
     
     _intialState();
  }
    
    _intialState()async{
     await _getCurrentTimerState(widget.seconds);
   
     if(currentStateTime.isFavorite==1){
       setState(() {
        _favoriteIcon = Icon(Icons.favorite);
       });
       
     }else{
       setState(() {
        _favoriteIcon =  Icon(Icons.favorite_border);
       });
     }
     
    }
    Future <List<FavoriteTime>> _loadAllTimers()async{
      _allTimers= await DBProvide.db.getAllFavoriteTime();
      return _allTimers;
    }
    Future <List<FavoriteTime>>_loadData()async{
     _favoritLst= await DBProvide.db.getOnlyFavoritesTrue();
      return _favoritLst;
    }
    _insertNewtimerAndMakeItFavorite()async{
       _nameFavoriteTimer(context);
    }
    _onSavedClicked()async{
     
      setState(() {
        currentStateTime.time = widget.seconds;
        currentStateTime.title =  myController.text.isNotEmpty?myController.text:_tmptimerString(widget.seconds);
        currentStateTime.isFavorite = 1; 
      });
      await DBProvide.db.newFavoriteTimer(currentStateTime);
      await _getCurrentTimerState(widget.seconds);
      setState(() {
       _favoriteIcon = Icon(Icons.favorite) ;
      });
      setState(() {
       myController.clear(); 
      });
    }
    _favoriteLogic()async{
      try{
        
         await _loadAllTimers();

         bool _found= false;

         if(_allTimers!=[]){
         
           for(int i=0;i<_allTimers.length;i++){
            
             if(_allTimers[i].time == widget.seconds){
               _found = true;
               break;
             }
           }

           if(_found){
           
             print("just set to favorite or unfavorite");
             await _getCurrentTimerState(widget.seconds);
             if(currentStateTime.isFavorite ==1){
               currentStateTime.isFavorite = 0;
             }else{
               currentStateTime.isFavorite =1;
             }
           
             await _favoriteOrUnFavorite(currentStateTime);
             await  _getCurrentTimerState(widget.seconds);
           
             setState(() {
              if(currentStateTime.isFavorite ==1){
                _favoriteIcon = Icon(Icons.favorite);
              }else{
                _favoriteIcon = Icon(Icons.favorite_border);
              }
             });
           }else{
           
             _insertNewtimerAndMakeItFavorite();
           }
         }else{
         
           _insertNewtimerAndMakeItFavorite();
         }
      }on Exception catch(error){
        print(error);
      }
    }
     _favoriteOrUnFavorite(FavoriteTime timer)async{
      await  DBProvide.db.favoriteOrUnfavorite(timer);
   
    }
     _getCurrentTimerState(int time)async{
       var res = await DBProvide.db.getFavoritTimeByTime(time);
       setState(() {
        currentStateTime = new FavoriteTime(time: res.time, title: res.title, isFavorite: res.isFavorite); 
       });
    }


    onTimeDismissed(){
      player.play(alarmAudioPath);
    }
    _about(){
       showDialog(
      context: context,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text('About'),
          content: new Text('This app allow you to set timers and make them favorites so you can easily return back to them and just play one. In addition, this timer is a user friendly app that can be set for hours, minutes and even seconds. Its a great choice to time an exam for your class, monitor your sport time and much more.', textAlign: TextAlign.justify,),
          actions: <Widget>[
            new FlatButton(onPressed: (){Navigator.of(context).pop();}, 
              child: new Text('ok'),)
          ],

        );
      }
    );


    }
String _tmptimerString(int seconds){
    Duration duration = new Duration(seconds: seconds);
    return '${duration.inHours}:${(duration.inMinutes%60).toString().padLeft(2,'0')}:${(duration.inSeconds%60).toString().padLeft(2,'0')}';
  }
Widget buildFavoriteTileItem(int index,FavoriteTime obj){
   String _time=  _tmptimerString(obj.time);
    return new Card(
          child: new InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CountDown(obj.time)));
            },
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[ 
                new Column(
                  children: <Widget>[
                   new Text(obj.title,style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300)),
                 
                   new Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: <Widget>[
                       new Text(_time,style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w200)),
                       new IconButton(icon: Icon(Icons.edit),onPressed: (){
                         _updateFavoriteTimer(context,obj);
                         setState(() {
                           
                         });
                       },),
                       new IconButton(icon:Icon(Icons.favorite),onPressed: ()async{
                          obj.isFavorite =0;
                          await _favoriteOrUnFavorite(obj); 
                          setState(() {
                            if(obj.time  == widget.seconds){
                              _favoriteIcon = Icon(Icons.favorite_border);
                            }
                          });
                          
                       },color: Colors.redAccent,)
                     ],
                   )
                  ],
                ),
                new Divider(height: 15.0,color: Colors.red,),
            ],
            ),
          )
        );
  }
  Widget buildDrawer(){
  
    List<Widget> _noFav = [new Text('No Favorite timers')];
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            title: new Container(
              height: 50.0, 
              color: Colors.redAccent,
              child: new Center(child: Text('Menu', style: new TextStyle(fontSize: 20.0,fontWeight: FontWeight.normal),),)
            ),
          ),
          new FutureBuilder<List<FavoriteTime>>(
                  future: _loadData(),
                  initialData: _favoritLst,
                  builder: (BuildContext context,AsyncSnapshot<List<FavoriteTime>> snapshot){
                    if(snapshot.hasData && snapshot != null){
                      return new ExpansionTile(
                        leading: new Icon(Icons.favorite),
                        title: Text('Favorites',style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300)),
                        children:snapshot.data.length>0? List.generate(snapshot.data.length, (index){
                           return buildFavoriteTileItem(index, _favoritLst[index]);
                        }): _noFav
                      );
                    
                    }else{
                       return new ExpansionTile(
                        title: Text('Favorites'),
                        children: <Widget>[
                          new Center(child: new Text('No Favorite timers',style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300)),)
                        ],
                      );
                    }
                  },
                ),
          new ListTile(leading: new Icon(Icons.info), title: new Text('About',style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300)), onTap: (){_about();},)
        ],
      ),
    );
  }

  _nameFavoriteTimer(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text('Name your Timer'),
          content: new TextFormField(
            controller: myController,
            decoration: InputDecoration(
              hintText: _tmptimerString(widget.seconds)
            ),
          ),
          actions: <Widget>[
            new FlatButton(onPressed: (){
              _onSavedClicked();
              setState(() {
               currenttimerName = myController.text; 
              });
              Navigator.of(context).pop();}, child: new Text('save'),)
          ],

        );
      }
    );
  }
  
  _updateFavoriteTimer(BuildContext context, FavoriteTime timer){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text('update your Timer'),
          content: new TextField(
            keyboardType: TextInputType.text,
            controller: updateController,
           
            decoration: InputDecoration(
              hintText: timer.title
            ),
          ),
          actions: <Widget>[
            new FlatButton(onPressed: ()async{
              if(updateController.text.isNotEmpty){
             
                timer.title=updateController.text;
              }
                await _favoriteOrUnFavorite(timer);
                
             
              Navigator.of(context).pop();
              setState(() {
                updateController.clear();
              });
              }, child: new Text('save'),),
            

          ],

        );
      }
    );
  }
  
  
  _onPlayPressed(){
   
        setState(() {
        _Play_pause = !_Play_pause; 
        });
        if(_Play_pause){
          setState(() {
          _Play_pause_icon = Icon(Icons.pause); 
          if(!controller.isAnimating){
            controller.reverse(from: controller.value==0.0?1.0:controller.value);
          }    
          });
        }else{
          setState(() {
          _Play_pause_icon =  Icon(Icons.play_arrow);
          if(controller.isAnimating){
            controller.stop();
          }
          });
        }
      
    
  }
  _onRestartPressed(){
    controller.dispose();
    controller = AnimationController(vsync: this, duration: Duration(seconds: widget.seconds))
      ..addStatusListener((status){
        if(status == AnimationStatus.dismissed && _intialSeconds!=0 ) {
        
          onTimeDismissed();
           setState(() {
            _Play_pause = false;
          _Play_pause_icon = Icon(Icons.play_arrow) ; 
       });
     
          interAd..load()..show();
        }
        
      });
   
    
    if(!controller.isAnimating){
        controller.reverse(from: controller.value==0.0?1.0:controller.value);
      }   
    
       setState(() {
        _Play_pause = true;
      _Play_pause_icon = Icon(Icons.pause) ; 
       });
    
 
  }
  @override
  Widget build(BuildContext context)  {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('Timer'),
          backgroundColor: Colors.redAccent,
          brightness: Brightness.light,
          actions: <Widget>[
          new IconButton(icon: new Icon(Icons.home), onPressed: (){
             Navigator.push(context,MaterialPageRoute(builder: (context)=>MyApp()));
              }),
          new IconButton(icon: _favoriteIcon,onPressed: (){  _favoriteLogic();},)
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              new  Expanded(
                child: new Align(
                  alignment: FractionalOffset.center,
                  child: AspectRatio(aspectRatio: 1.0 , child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: AnimatedBuilder(animation: controller,
                            builder: (BuildContext context, Widget child) {
                              return new CustomPaint(
                                painter: TimerPainter(animation: controller, backgroundColor: Colors.grey,color: Colors.redAccent),
                              );
                            }),
                      ),
                      new Align(
                        alignment: FractionalOffset.center,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new AnimatedBuilder(
                                animation: controller,
                                builder: (BuildContext context, Widget child)
                                {
                                  return new Container(
                                    child: new Text(timerString, style: new TextStyle(fontSize: 50.0, fontWeight: FontWeight.w100),),
                                        );

                                }
                            ),
                            new Container(height: 40.0,),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Container(
                                  child: new FloatingActionButton(
                                    child: _Play_pause_icon,
                                    onPressed: (){
                                      _onPlayPressed();
                                    },
                                    backgroundColor: Colors.redAccent,),
                                  ),
                                new Container(width: 20.0,),
                                new Container(
                                  child: new FloatingActionButton(
                                    child: Icon(Icons.restore), 
                                    onPressed: (){ _onRestartPressed();},
                                    backgroundColor: Colors.redAccent,),
                                ),
                             
                              ],
                            ),
                        
                          ],
                        ),
                      ),
                    ],
                  ),),
                ),
              ),
            ],
          ),
        ),
        drawer: buildDrawer(),
      ),
    );
  }
}

class TimerPainter extends CustomPainter{
  TimerPainter({this.animation,this.backgroundColor,this.color}):super(repaint:animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size){
    Paint paint = Paint()
      ..color=backgroundColor
      ..strokeWidth=5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width/2.0, paint);
    paint.color = color;
    double progress = (1.0-animation.value)*2*math.pi;
    canvas.drawArc(Offset.zero &size, math.pi*1.5, -progress , false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    
    return animation.value != old.animation.value ||
        color != old.color || backgroundColor != old.backgroundColor;
  }
}