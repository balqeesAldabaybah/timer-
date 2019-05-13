

import 'package:flutter/material.dart';
import 'countDown.dart';
import 'package:numberpicker/numberpicker.dart';


  

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
  
  NumberPicker hourNumberPicker;
  NumberPicker minNumberPicker;
  NumberPicker secNumberPicker;
  int _currentSecValue =0;
  int _currentMinValue =0;
  int _currentHrValue =0;
  dynamic sec;
  dynamic min;
  dynamic hr;
  @override
  void initState() {
    sec = 'sec';
    min = 'min';
    hr = 'h';
   
    super.initState();
  }

  _getZeroCaseAlertDialog(){
     showDialog(
          context: context,
          builder: (BuildContext context){
            return new AlertDialog(
              content: new Text('Timer can not be zero'),
              actions: <Widget>[
                new FlatButton(onPressed: (){ Navigator.of(context).pop();}, child: new Text('Set time'),),
               
              ],
            );
          }
        );
  }

  @override
  Widget build(BuildContext context) {
    hourNumberPicker = buildNumberPicker(0, 99);
    minNumberPicker = buildNumberPicker(0,59);
    secNumberPicker = buildNumberPicker(0,59);
    return  new Scaffold(
      body: Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: Center(
            child: new SingleChildScrollView(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.all(50.0) ,
                      child:new Column(
                        children: <Widget>[
                          Text('Timer', style: new TextStyle( color: Colors.redAccent,fontSize: 30.0),) ,
                          new Container(height: 20.0,),
                          Text('Set Your Timer') ,
                        ],)),

                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Align(
                        alignment: FractionalOffset.center,
                        child: new Container(
                            decoration: BoxDecoration(shape: BoxShape.circle , border: new Border.all(color: Colors.redAccent),),
                            width: 70.0,
                            height: 70.0,
                            child: new Align(
                              alignment: FractionalOffset.center,
                              child: new GestureDetector(
                                child: new Text(hr==''? '$_currentHrValue h':hr , style: new TextStyle(fontSize: 20.0),),
                                onTap: _showHrDialog,
                              ),
                            )
                        ),
                      ),
                      new Align(
                        alignment: FractionalOffset.center,
                        child: new Container(
                            decoration: BoxDecoration(shape: BoxShape.circle , border: new Border.all(color: Colors.redAccent),),
                            width: 70.0,
                            height: 70.0,
                            child: new Align(
                              alignment: FractionalOffset.center,
                              child: new GestureDetector(
                                child: new Text(min==''? '$_currentMinValue min':min , style: new TextStyle(fontSize: 20.0),),
                                onTap: _showMinDialog,
                              ),
                            )
                        ),
                      ),
                      new Align(
                        alignment: FractionalOffset.center,
                        child: new Container(
                            decoration: BoxDecoration(shape: BoxShape.circle , border: new Border.all(color: Colors.redAccent),),
                            width: 70.0,
                            height: 70.0,
                            child: new Align(
                              alignment: FractionalOffset.center,
                              child: new GestureDetector(
                                child: new Text(sec==''? '$_currentSecValue Sec':sec , style: new TextStyle(fontSize: 20.0),),
                                onTap: _showSecDialog,

                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                  new Container(height: 20.0,),
                  new FloatingActionButton(

                    onPressed: (){
                      int _totalSec = (hr==''?_currentHrValue:0)*3600+((min ==''?_currentMinValue:0)*60)+ (sec ==''?_currentSecValue:0);
                      if(_totalSec==0){
                        _getZeroCaseAlertDialog();
                      }
                      else{
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CountDown(_totalSec)));
                      }
                      
                    },
                    child: new Icon(Icons.play_arrow), backgroundColor: Colors.redAccent,)
                ],
              ),
            ),
          )
      ),
    );
  }



  Future _showSecDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 59,
          initialIntegerValue: _currentSecValue,
        );
      },
    ).then(_handleSecValueChangedExternally);
  }

  Future _showMinDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 59,
          initialIntegerValue: _currentMinValue,
        );
      },
    ).then(_handleMinValueChangedExternally);
  }

  Future _showHrDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 99,
          initialIntegerValue: _currentHrValue,
        );
      },
    ).then(_handleHrValueChangedExternally);
  }


  Widget buildNumberPicker(num min,num max) {
    return new NumberPicker.integer(
      initialValue:_currentSecValue,
      minValue: min,
      maxValue: max,
      onChanged: _handleValueChanged,
    );
  }

  _handleValueChanged(num value)
  {
    setState(() {
      print(value);
      _currentSecValue =value;
      sec = value;
    });
  }

  _handleSecValueChangedExternally(num value)
  {
    if(value!=null){
      if (value is int){
        setState(() {
          print(value);
          _currentSecValue =value;
          sec = '';
        });

      }
    }

  }

  _handleMinValueChangedExternally(num value)
  {
    if(value!=null){
      if (value is int){
        setState(() {
          print(value);
          _currentMinValue =value;
          min= '';
        });

      }
    }

  }

  _handleHrValueChangedExternally(num value)
  {
    if(value!=null){
      if (value is int){
        setState(() {
          print(value);
          _currentHrValue =value;
          hr= '';
        });
      }
    }

  }
}

