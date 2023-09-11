import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

final box = GetStorage();

class SendNotif {
  //send notification
  // static Future sendPushMessageToWeb(
  //     {required String groupId,
  //     required String message,
  //     required String groupName}) async {
  //   await FirebaseFirestore.instance
  //       .collection('groups')
  //       .doc(groupId)
  //       .collection('groupMembers')
  //       .get()
  //       .then(
  //     (value) async {
  //       for (var item in value.docs) {
  //         if (item.id != box.read('id')) {
  //           await FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(item.id)
  //               .get()
  //               .then((userData) async {
  //             if (userData.data()!.containsKey('notificationToken')) {
  //               if (userData['notificationToken'] == null) {
  //                 print('Unable to send FCM message, no token exists.');
  //                 return;
  //               }
  //               try {
  //                 await http
  //                     .post(
  //                       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //                       headers: <String, String>{
  //                         'Content-Type': 'application/json',
  //                         'Authorization':
  //                             'key=AAAAicQOfr8:APA91bFLbLyJuEJQVxTGwQJ0DIoxgDZ-yKNmQu5TpIfG1G0ClHul1ZPi9e9ZMvHb9p6_qKot0wfTBu5bxEZsEhJXaLxBWo1aIEnV9gReNOmXby5tJAHRIZiQCVB7A5d5zvDHccstbSLX'
  //                       },
  //                       body: json.encode({
  //                         "to": userData['notificationToken'],
  //                         "message": {
  //                           "token": userData['notificationToken'],
  //                         },
  //                         "notification": {
  //                           "title": "New message from $groupName",
  //                           "body": message,
  //                         }
  //                       }),
  //                     )
  //                     .then((value) => print(value.body));
  //                 print('FCM request for web sent!');
  //               } catch (e) {
  //                 print(e);
  //               }
  //             }
  //           });
  //         }
  //       }
  //     },
  //   );
  // }
}
