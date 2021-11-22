import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/diary_by_date.dart';
import '../utils/shared.dart';

class FilterBottomSheet extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final String userId;

  const FilterBottomSheet({Key key, this.diaryProvider, this.userProvider, this.userId}) : super(key: key);
  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String date = 'Today';
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
         color: background,
          alignment: Alignment.center,
          height: 300,
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Diary Filter',style: TextStyle(
                    fontSize: 20,
                    color: textColor
                ),),
              ),
              SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,color: textColor,size: 25,),
                      SizedBox(width: 10,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Go To',style: TextStyle(
                            fontSize: 18,
                            color: textColor
                        ),),
                      ),
                    ],
                  ),
                  RaisedButton(
                      color: buttons,
                      elevation: 0,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text('$date',style: TextStyle(
                                fontSize: 15,
                                color: textColor
                              ),),
                              Icon(Icons.arrow_drop_down)
                            ],
                          )
                      ),
                      onPressed: ()async{
                         await showDatePicker(
                             context: context,
                             initialDate: DateTime.now(),
                             firstDate: DateTime(2020),
                             lastDate: DateTime.now(),
                             builder: (BuildContext context, Widget child) {
                             return Theme(
                               data: ThemeData.light().copyWith(
                                 primaryColor: bar,
                                 accentColor: background,
                                 colorScheme: ColorScheme.light(primary: icons),
                                 buttonTheme: ButtonThemeData(
                                     textTheme: ButtonTextTheme.primary
                                 ),
                               ),
                               child: child,
                             );
                           },
                         ).then((value) {
                           setState(() {
                             if(value != null) {
                               date = value.toString().split(' ')[0];
                             }
                           });
                         });
                      }
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                      color: buttons,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Clear',style: TextStyle(
                            fontSize: 18,
                            color: textColor
                        ),),
                      ),
                      onPressed: (){
                       setState(() {
                         date = 'Today';
                       });
                      }
                  ),
                  RaisedButton(
                      color: buttons,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Done',style: TextStyle(
                            fontSize: 18,
                            color: textColor
                        ),),
                      ),
                      onPressed: (){
                          if(date != 'Today' && date != null){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                DiaryByDateScreen(date: date,userId: widget.userId,
                                  diaryProvider: widget.diaryProvider,userProvider: widget.userProvider,)));
                          }else{
                            Navigator.pop(context);
                          }
                      }
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}
