import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/parent_repository.dart';

class ParentController {
  final ParentRepository _repository = ParentRepository();

  Stream<QuerySnapshot> getChildren() {
    return _repository.getChildrenStream();
  }

  Future<void> logout() async {
    await _repository.signOut();
  }
}