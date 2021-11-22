class NotificationModel{
  static const String TITLE = "title";
  static const String BODY = "body";
  static const String ICON = "icon";
  static const String ROUTE = "route";
  static const String USER_ID = "userId";
  static const String TIME = "time";
  static const String DIARY_ID = "diaryId";

  String title;
  String body;
  String icon;
  String route;
  String userId;
  String time;
  String diaryId;

  NotificationModel({this.title, this.body,this.route,this.icon,this.time,this.userId,this.diaryId});

  NotificationModel.fromMap(Map<String,dynamic> notMap){
    title = notMap[TITLE] ?? '';
    body = notMap[BODY] ?? '';
    userId = notMap[USER_ID] ?? '';
    icon = notMap[ICON] ?? '';
    route = notMap[ROUTE] ?? '';
    time = notMap[TIME] ?? '';
    diaryId = notMap[DIARY_ID] ?? '';
  }

  Map<String,dynamic> toMap()=>{
    TITLE : title ?? '',
    BODY : body ?? '',
    USER_ID : userId ?? '',
    ICON : icon ?? '',
    ROUTE : route ?? '',
    TIME : time ?? '',
    DIARY_ID : diaryId ?? '',
  };
}