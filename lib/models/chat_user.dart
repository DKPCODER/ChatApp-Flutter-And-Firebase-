class ChatUser {
  ChatUser({
   required this.image,
   required this.about,
   required this.name,
   required this.created_at,
   required this.last_active,
   required this.id,
   required this.is_online,
   required this.email,
   required this.push_token,
  });
  late String image;
  late String about;
  late String name;
  late String created_at;
  late String last_active;
  late String id;
  late bool is_online;
  late String email;
  late String push_token;


  

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    created_at = json['created_at'] ?? '';
    last_active = json['last_active'] ?? '';
    id = json['id'] ?? '';
    is_online = json['is_online'] ?? false;
    email = json['email'] ?? '';
    push_token = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'about': about,
      'name': name,
      'created_at': created_at,
      'last_active': last_active,
      'id': id,
      'is_online': is_online,
      'email': email,
      'push_token': push_token,
    };
  }
}
