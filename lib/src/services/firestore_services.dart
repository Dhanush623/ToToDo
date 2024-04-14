import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:totodo/src/constants/collection_constants.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/models/Todo.dart';
import 'package:totodo/src/widgets/show_toast.dart';

Future<List<Todo>> getToTodoList(String uid) async {
  List<Todo> todoList = [];

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(CollectionConstants.todoList)
      .where('uid', isEqualTo: uid)
      .orderBy('isFinished', descending: false)
      .orderBy('createdOn', descending: true)
      .get();

  for (var doc in querySnapshot.docs) {
    todoList.add(Todo.fromSnapshot(doc));
  }
  return todoList;
}

Future addTodo(String todo, User? user) async {
  CollectionReference todoReference =
      FirebaseFirestore.instance.collection(CollectionConstants.todoList);
  DateTime now = DateTime.now();
  Timestamp timestamp = Timestamp.fromDate(now);
  todoReference
      .add({
        'createdOn': timestamp,
        'name': todo,
        'isFinished': false,
        'uid': user?.email,
      })
      .then((value) => {
            showToast(
              Constants.todoAdded,
            ),
          })
      .catchError(
        (error) => {
          showToast(
            Constants.unableToAddTodo,
          )
        },
      );
}

Future updateTodoStatus(bool? status, User? user, String? docId) async {
  CollectionReference todoReference =
      FirebaseFirestore.instance.collection(CollectionConstants.todoList);
  DateTime now = DateTime.now();
  Timestamp timestamp = Timestamp.fromDate(now);
  todoReference
      .doc(docId)
      .set({
        'updatedOn': timestamp,
        'isFinished': status,
      }, SetOptions(merge: true))
      .then((value) => {
            showToast(
              Constants.todoUpdated,
            ),
          })
      .catchError(
        (error) => {
          showToast(
            Constants.unableToUpdateTodo,
          )
        },
      );
}

Future updateTodoName(String? name, User? user, String? docId) async {
  CollectionReference todoReference =
      FirebaseFirestore.instance.collection(CollectionConstants.todoList);
  DateTime now = DateTime.now();
  Timestamp timestamp = Timestamp.fromDate(now);
  todoReference
      .doc(docId)
      .set({
        'updatedOn': timestamp,
        'name': name,
      }, SetOptions(merge: true))
      .then((value) => {
            showToast(
              Constants.todoUpdated,
            ),
          })
      .catchError(
        (error) => {
          showToast(
            Constants.unableToUpdateTodo,
          )
        },
      );
}

Future<void> deleteTodo(String? docId) async {
  CollectionReference todoReference =
      FirebaseFirestore.instance.collection(CollectionConstants.todoList);
  try {
    await todoReference.doc(docId).delete();
    showToast(Constants.todoDeleted);
  } catch (error) {
    showToast(Constants.unableToDeleteTodo);
  }
}
