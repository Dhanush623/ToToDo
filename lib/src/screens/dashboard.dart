import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/models/Todo.dart';
import 'package:totodo/src/screens/settings/settings.dart' as TodoSettings;
import 'package:totodo/src/services/firestore_services.dart';
import 'package:totodo/src/widgets/show_toast.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User? user;
  bool isCurrentUser = false;
  bool isLoading = true;
  List<Todo> toTodoList = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    FirebaseAuth.instance.authStateChanges().listen((User? loggedUser) {
      if (loggedUser == null) {
        setState(() {
          isLoading = false;
        });
        signInWithGoogle();
      } else {
        setState(() {
          user = loggedUser;
          isLoading = false;
          isCurrentUser = true;
        });
        getTodoList(loggedUser);
      }
    });
  }

  Future getTodoList(User loggedUser) async {
    List<Todo> todoList = await getToTodoList(loggedUser.email ?? '');
    setState(() {
      toTodoList = todoList;
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> initializeMessaging() async {
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) {
      debugPrint('FCM Token: $token');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(message.toString());
      _showNotification(message);
    });
  }

  void _showNotification(RemoteMessage message) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      message.notification?.android?.channelId ?? Constants.channelId,
      Constants.channelName,
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      message.notification?.android?.count ?? DateTime.now().millisecond,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  void _showAddBottomSheet(BuildContext context) async {
    TextEditingController textEditingController = TextEditingController();

    final addItem = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  Constants.addTodoDetails,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: Constants.todoDetails,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          25,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      textEditingController.text,
                    );
                  },
                  child: const Text(
                    Constants.addToTodo,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (addItem != null && addItem.toString().isNotEmpty) {
      addTodo(addItem, user);
      getTodoList(user!);
    } else {
      showToast(Constants.nothingTodo);
    }
  }

  void _showUpdateBottomSheet(BuildContext context, Todo todo) async {
    TextEditingController textEditingController =
        TextEditingController(text: todo.name);

    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  Constants.addTodoDetails,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: Constants.todoDetails,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          25,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      textEditingController.text,
                    );
                  },
                  child: const Text(
                    Constants.updateToTodo,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null && result.toString().isNotEmpty) {
      updateTodoName(result, user, todo.id);
      getTodoList(user!);
    } else {
      showToast(Constants.nothingTodo);
    }
  }

  Future updateStatus(bool? status, String? id) async {
    await updateTodoStatus(status, user, id);
    getTodoList(user!);
  }

  Future deleteTodoItem(String? id) async {
    await deleteTodo(id);
    getTodoList(user!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: user != null
          ? AppBar(
              title: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      foregroundImage: NetworkImage(
                        user?.photoURL ?? '',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${Constants.hiLabel}${user?.displayName}",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoSettings.Settings(
                              user: user!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings,
                      ),
                      tooltip: Constants.settings,
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBottomSheet(context);
        },
        child: IconButton(
          onPressed: () {
            _showAddBottomSheet(context);
          },
          icon: const Icon(
            Icons.add,
          ),
        ),
      ),
      body: user == null
          ? Container()
          : ListView.builder(
              itemCount: toTodoList.length,
              itemBuilder: (BuildContext context, int index) {
                return buildTodoItem(
                  context,
                  index,
                );
              },
            ),
    );
  }

  Widget buildTodoItem(BuildContext context, int index) {
    return CheckboxListTile(
      value: toTodoList[index].isFinished,
      onChanged: (bool? value) {
        updateStatus(
          value,
          toTodoList[index].id,
        );
      },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        toTodoList[index].name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        DateFormat(Constants.dateFormat).format(
          toTodoList[index].createdOn!.toDate(),
        ),
      ),
      secondary: Wrap(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showUpdateBottomSheet(
                context,
                toTodoList[index],
              );
            },
            tooltip: Constants.edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteTodoItem(
                toTodoList[index].id,
              );
            },
            tooltip: Constants.delete,
          ),
        ],
      ),
    );
  }
}
