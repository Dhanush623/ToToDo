import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final bool isFinished;
  final String name;
  final String uid;
  final String? id;
  final Timestamp? createdOn;
  final Timestamp? updatedOn;

  Todo({
    required this.isFinished,
    required this.name,
    required this.uid,
    this.id,
    this.createdOn,
    this.updatedOn,
  });

  factory Todo.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return Todo(
      isFinished: data?['isFinished'] ?? false,
      name: data?['name'] ?? '',
      uid: data?['uid'] ?? '',
      createdOn: data?['createdOn'],
      updatedOn: data?['updatedOn'],
      id: snapshot.id,
    );
  }
}
