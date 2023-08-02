import 'dart:convert';
import 'dart:io';
import 'package:chat_hub/models/messagesModel.dart';
import 'package:chat_hub/models/user_firebase_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIS {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get getUser => auth.currentUser!;

  static late UserFireBase currUser;

  // messenging notification
  static FirebaseMessaging fireMessenging = FirebaseMessaging.instance;

  static Future<void> getMessagingToken() async {
    await fireMessenging.requestPermission();

    await fireMessenging.getToken().then((value) {
      if (value != null) {
        currUser.pushToken = value;
        print("Token Key : " + value);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

// to send message in notification
  static Future<void> sendNotification(
      UserFireBase charUser, String message) async {
    try {
      final body = {
        "to": charUser.pushToken,
        "notification": {
          "title": charUser.name, //our name should be send
          "body": message,
          "android_channel_id": "Chats",
        },
        "data": {
          "user_data": "User: ${currUser.id} ",
        },
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAACg9YVFs:APA91bE3bhi6HvhzIEdXitcPVXnhfBVJwfyq8SJKQxCWGO2oXxvvZZsjENVCqV3EQuVu3ArptH4uTnBQ-2EQy58ypjwPEJJjdQGLfE9A5gDB1dTAW3B2oopIpbIMDpwyYG2azuJMZevy'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print("\n push notification  $e");
    }
  }

  //getting current user info
  static Future<void> currentUserInfo() async {
    await firestore
        .collection('users')
        .doc(getUser.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        currUser = UserFireBase.fromJson(user.data()!);
        await getMessagingToken();
        // setting user active status to online
        APIS.updateOnlineStatus(true);
      } else {
        await newUser().then((value) => currentUserInfo());
      }
    });
  }

  // if user exists
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // if user id new
  static Future<void> newUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = UserFireBase(
        image: getUser.photoURL.toString(),
        about: "Revenge is the purest emotion",
        name: getUser.displayName.toString(),
        createdAt: time,
        isOnline: false,
        id: getUser.uid,
        lastActive: time,
        email: getUser.email.toString(),
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set(chatUser.toJson());
  }

  // getting users accept current user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUSers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: getUser.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(getUser.uid).update({
      'name': currUser.name,
      'about': currUser.about,
    });
  }

// user profile update
  static Future<void> updateProfilePhoto(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${getUser.uid}.$ext');

    //updating file
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => print('Data Transfer : ${p0.bytesTransferred / 1000} kb'));

    currUser.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(getUser.uid)
        .update({'image': currUser.image});
  }

  // creating every user unique conversation id
  static String getConversationId(String id) {
    return getUser.uid.hashCode <= id.hashCode
        ? '${getUser.uid}_$id'
        : '${id}_${getUser.uid}';
  }

  // get all user message with another user if exixts
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserFireBase user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      UserFireBase chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    firestore.collection('users').doc(getUser.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': currUser.pushToken
    });
  }

  // sending Message Function
  static Future<void> sendMessage(
      UserFireBase user, String message, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final MessageModel createMessage = MessageModel(
        toId: user.id,
        msg: message,
        read: '',
        type: type,
        fromId: getUser.uid,
        sent: time);
    final ref =
        firestore.collection('chats/${getConversationId(user.id)}/messages/');
    await ref.doc(time).set(createMessage.toJson()).then((value) =>
        sendNotification(user, type == Type.image ? 'Image' : message));
  }

  // message is read or not
  static Future<void> updateReadMessage(MessageModel message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get last message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      UserFireBase user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy(
          'sent',
          descending: true,
        )
        .limit(1)
        .snapshots();
  }

  static Future<void> sendImageChat(UserFireBase chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //updating file
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => print('Data Transfer : ${p0.bytesTransferred / 1000} kb'));

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // function to delete message from chat
  static Future<void> delteMessage(MessageModel message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
}
