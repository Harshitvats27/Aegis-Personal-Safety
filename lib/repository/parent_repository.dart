import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../db/share_pref.dart';

class ParentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getChildrenStream() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('users')
        .where('type', isEqualTo: 'child')
        .where('guardianEmail', isEqualTo: currentUser?.email)
        .snapshots();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await MySharedPrefference.clear();
  }
}