import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/models/todo.dart';
import 'package:totodo/src/screens/settings/settings.dart' as todo_settings;
import 'package:totodo/src/services/firestore_services.dart';
import 'package:totodo/src/widgets/custom_elevated_button.dart';
import 'package:totodo/src/widgets/custom_icon_button.dart';
import 'package:totodo/src/widgets/custom_text_field.dart';
import 'package:totodo/src/widgets/custom_todo_item.dart';
import 'package:totodo/src/widgets/show_toast.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User? user;
  bool isLoading = true;
  List<Todo> toTodoList = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
    _requestAndPrintFCMToken();
    _configureFirebaseMessaging();
    initializeApp();
  }

  Future<void> _requestAndPrintFCMToken() async {
    final String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
  }

  Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(message.toString());
      _showNotification(message);
    });
  }

  Future<void> initializeApp() async {
    debugPrint(
        "FirebaseAuth.instance.currentUser ${FirebaseAuth.instance.currentUser}");
    FirebaseAuth.instance.authStateChanges().listen((User? loggedUser) async {
      if (mounted) {
        setState(() {
          user = loggedUser;
          isLoading = false;
        });
        getTodoList(loggedUser);
      }
    });
  }

  Future getTodoList(User? loggedUser) async {
    List<Todo> todoList = await getToTodoList(loggedUser?.email ?? '');
    if (mounted) {
      setState(() {
        toTodoList = todoList;
      });
    }
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
                customTextInput(
                  textEditingController,
                  null,
                  null,
                  (value) {},
                  null,
                  Constants.todoDetails,
                  true,
                ),
                const SizedBox(height: 10.0),
                customElevatedButton(
                  Constants.addToTodo,
                  () {
                    Navigator.pop(
                      context,
                      textEditingController.text,
                    );
                  },
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
                  Constants.updateTodoDetails,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                customTextInput(
                  textEditingController,
                  null,
                  null,
                  (value) {},
                  null,
                  Constants.todoDetails,
                  true,
                ),
                const SizedBox(height: 10.0),
                customElevatedButton(
                  Constants.updateToTodo,
                  () {
                    Navigator.pop(
                      context,
                      textEditingController.text,
                    );
                  },
                )
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
                  horizontal: 8.0,
                ),
                child: Row(
                  children: [
                    user?.photoURL == null
                        ? CircleAvatar(
                            child: Text(
                              "${user?.displayName!.substring(0, 1)}",
                            ),
                          )
                        : CircleAvatar(
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
                    customIconButton(
                      Icons.settings,
                      Constants.settings,
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => todo_settings.Settings(
                              user: user!,
                            ),
                          ),
                        )
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: user != null
          ? FloatingActionButton(
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
            )
          : null,
      body: toTodoList.isEmpty
          ? const Center(
              child: Text(
                Constants.nothingToTodo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: toTodoList.length,
              itemBuilder: (BuildContext context, int index) {
                final todo = toTodoList[index];
                return CustomToDoItem(
                  todo: todo,
                  bottomSheetFunction: _showUpdateBottomSheet,
                  updateFunction: updateStatus,
                  deleteFunction: deleteTodoItem,
                );
              },
            ),
    );
  }
}
