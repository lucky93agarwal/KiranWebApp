import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class ServicesFunctions {
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;

  Future removeDeletedMyGroups() async {
    await _firestore
        .collection('groupChats')
        .doc(box.read('id'))
        .collection('myGroups')
        .get()
        .then((value) async {
      for (var group in value.docs) {
        await _firestore
            .collection('groups')
            .doc(group.id)
            .get()
            .then((doc) async {
          if (doc.exists) {
          } else {
            await _firestore
                .collection('groupChats')
                .doc(box.read('id'))
                .collection('myGroups')
                .doc(group.id)
                .delete();
          }
        });
      }
    });
  }
}
