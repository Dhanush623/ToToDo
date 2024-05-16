import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/storage_helper.dart';
import 'package:totodo/src/helper/theme_manager.dart';
import 'package:totodo/src/screens/login/login.dart';
import 'package:totodo/src/widgets/show_toast.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.user});
  final User user;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with WidgetsBindingObserver {
  bool isDarkTheme = false;
  bool isNotification = false;

  @override
  void initState() {
    super.initState();
    getThemeDetails();
    getNotificationDetails();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      getNotificationDetails();
    }
  }

  getNotificationDetails() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      setState(() {
        isNotification = true;
      });
    } else {
      setState(() {
        isNotification = false;
      });
    }
  }

  changeNotificationPermission() async {
    openAppSettings();
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  getThemeDetails() async {
    String? selectedTheme = await getData(Constants.selectedTheme);
    if (selectedTheme == ThemeMode.dark.name) {
      setState(() {
        isDarkTheme = true;
      });
    } else {
      setState(() {
        isDarkTheme = false;
      });
    }
  }

  Future<void> signOutWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut().then(
            (value) async => {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
                (Route<dynamic> route) => false,
              ),
            },
          );
    } catch (error) {
      showToast(
        Constants.unableToAddTodo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.settings),
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 100.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              Constants.todo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${Constants.copyrightLabel}${DateTime.now().year} ",
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  radius: 60,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(
                        widget.user.photoURL ?? Constants.userAvatar),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.user.displayName ?? "",
                  style: const TextStyle(fontSize: 22.0),
                ),
                Text(
                  widget.user.email ?? "",
                )
              ],
            ),
          ),
          ListTile(
            title: const Text(
              Constants.darkTheme,
              style: TextStyle(fontSize: 18),
            ),
            trailing: Switch(
              value: isDarkTheme,
              onChanged: (bool value) {
                Provider.of<ThemeManager>(context, listen: false).toggleTheme();
                saveData(
                  Constants.selectedTheme,
                  isDarkTheme ? ThemeMode.light.name : ThemeMode.dark.name,
                );
                setState(() {
                  isDarkTheme = !isDarkTheme;
                });
              },
            ),
          ),
          ListTile(
            title: const Text(
              Constants.notifications,
              style: TextStyle(fontSize: 18),
            ),
            trailing: Switch(
              value: isNotification,
              onChanged: (bool value) {
                changeNotificationPermission();
              },
            ),
          ),
          ListTile(
            title: const Text(
              Constants.logout,
              style: TextStyle(fontSize: 18),
            ),
            trailing: const Icon(
              Icons.logout,
            ),
            onTap: signOutWithGoogle,
          ),
        ],
      ),
    );
  }
}
