import 'dart:convert';

 FavoriteTime clientFromJson(String str){
  final jsonData = json.decode(str);
  return FavoriteTime.fromJson(jsonData);
}
String clientToJson(FavoriteTime data){
  final dyn = data.toJson();
  return json.encode(dyn);

}
class FavoriteTime{
  int time;
  int isFavorite;
 String title; 

FavoriteTime({this.title,this.time,this.isFavorite});

factory FavoriteTime.fromJson(Map <String,dynamic> json) => new FavoriteTime(
  time: json["time"],
  isFavorite: json["isFavorite"],
  title: json["title"]

);

Map<String, dynamic> toJson() =>{
  "time":time,
  "title":title,
  "isFavorite":isFavorite
};
}