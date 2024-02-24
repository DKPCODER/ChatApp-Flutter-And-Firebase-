import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_talk/models/chat_user.dart';
import 'package:we_talk/models/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  static late ChatUser me;

  static get users => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore.collection('user').doc(auth.currentUser!.uid).get()).exists;
  }
  
    static Future<void> getSelfInfo() async {
    await firestore.collection('user').doc(auth.currentUser!.uid).get().then((users) async {
      if(users.exists){
        me = ChatUser.fromJson(users.data()!);
      }
      else{
      await createUser().then((value)=>getSelfInfo());
      }
    });
  }

 static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      image: users.photoURL.toString(),
      about: 'Hey there! I am using We Talk',
      name: users.displayName,
      created_at: time,
      last_active: time,
      id: users.uid,
      is_online: false,
      email: users.email.toString(),
      push_token: '',
    );

    await firestore.collection('user').doc(auth.currentUser!.uid).set(chatUser.toJson());
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>>getAllUsers()  {
    return  firestore.collection('user').where('id',isNotEqualTo:users.uid).snapshots();
  }
  static Future<void> updateUserInfo() async {
    await firestore.collection('user').doc(auth.currentUser!.uid).update({'name':me.name,'about':me.about});
  }
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${users.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(users.uid)
        .update({'image': me.image});
  }
    static String getConversationID(String id) => users.uid.hashCode <= id.hashCode
      ? '${users.uid}_$id'
      : '${id}_${users.uid}';
    static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser users) {
    return firestore
        .collection('chats/${getConversationID(users.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }
   static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: users.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }
   static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
    static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
    static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(users.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }
   static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
      final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
   }
    static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }
   static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(users.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.push_token,
    });
  }

}



