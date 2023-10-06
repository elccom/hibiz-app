class User {
  int user_id = 0;
  String id = "";
  String passwd = "";
  String fcm_token = "";
  String name = "";
  String nickname = "";
  String ci = "";
  String handphone = "";
  String email = "";
  Map<String, dynamic> pictures = {};
  List<Map<String, dynamic>> faces = [];
  int loginTimes = 0;
  DateTime lastLogin = DateTime.now();
  DateTime regDate = DateTime.now();
  int isUse = 0;

  void fromJson(Map<String, dynamic> jsonData) {

  }

  Map<String, dynamic> toJson() => {
    'user_id': user_id,
    'id': id,
    'passwd': passwd,
    'fcm_token': fcm_token,
    'name': name,
    'nickname': nickname,
    'ci': ci,
    'handphone': handphone,
    'email': email,
    'pictures': pictures,
    'faces': faces,
    'loginTimes': loginTimes,
    'lastLogin': lastLogin,
    'regDate': regDate,
    'isUse': isUse
  };
}