import 'dart:convert';
UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  String? name;
  String? email;
  String? profilePicture;
  String? isOnline;
  String? lastSeen;

  UserModel({
    this.id,
    this.name,
    this.email,
      this.profilePicture,
      this.isOnline,
      this.lastSeen});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
        profilePicture: json["profilePicture"],
        isOnline: json["isOnline"],
        lastSeen: json["lastSeen"],
      );

  Map<String, dynamic> toJson() => {
  "id": id,
  "name": name,
  "email":email,
        "profilePicture": profilePicture,
        "isOnline": isOnline,
        "lastSeen": lastSeen,
      };
}
// void saveUserListLocally(List<UserModel> users) async {
//   var box = Hive.box<UserModel>('userBox');
//   await box.clear();
//   for (var user in users) {
//     box.put(user.id, user);
//   }
// }
// List<UserModel> getUserListFromLocal() {
//   var box = Hive.box<UserModel>('userBox');
//   return box.values.toList();
// }