import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/analytics_helper.dart';
import 'package:totodo/src/helper/storage_helper.dart';
import 'package:totodo/src/helper/theme_manager.dart';
import 'package:totodo/src/screens/bottom_sheet/image_bottom_sheet.dart';
import 'package:totodo/src/screens/login/login.dart';
import 'package:totodo/src/screens/login/terms_and_conditions.dart';
import 'package:totodo/src/widgets/custom_elevated_button.dart';
import 'package:totodo/src/widgets/custom_text_field.dart';
import 'package:totodo/src/widgets/show_toast.dart';

// ignore: must_be_immutable
class Settings extends StatefulWidget {
  Settings({super.key, required this.user});
  User user;

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
    requestPermissions();
    WidgetsBinding.instance.addObserver(this);
    addScreenViewTracking(
      widget.runtimeType.toString(),
      "Settings",
    );
  }

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.storage]!.isGranted) {
      return true;
    } else {
      return false;
    }
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
        Constants.unableToSignOut,
      );
    }
  }

  Future<void> navigateToTermsAndConditions() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsAndConditions(),
      ),
    );
  }

  Future<String?> uploadFile(File file, String fileName) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<void> updateUserPhoto(String photoURL) async {
    try {
      User user = widget.user;
      await user.updatePhotoURL(photoURL);
    } catch (e) {
      debugPrint('Error updating user photo: $e');
    }
  }

  Future<void> uploadAndSetUserPhoto(File file, String fileName) async {
    String? photoURL = await uploadFile(file, fileName);
    if (photoURL != null) {
      await updateUserPhoto(photoURL);
    }
  }

  updateDisplayName(String displayName) async {
    try {
      await widget.user.updateDisplayName(displayName);
      debugPrint('Display name updated successfully');

      // Fetch updated user data to confirm changes
      User updatedUser = FirebaseAuth.instance.currentUser!;
      setState(() {
        widget.user = updatedUser;
      });
      debugPrint('New display name: ${widget.user.displayName}');
    } catch (e) {
      debugPrint('Error updating display name: $e');
    }
  }

  updatePassword(String password) async {
    try {
      await widget.user.updatePassword(password);
      debugPrint('Password updated successfully');

      User updatedUser = FirebaseAuth.instance.currentUser!;
      setState(() {
        widget.user = updatedUser;
      });
      showToast(Constants.passwordUpdatesSuccessfully);
    } catch (e) {
      debugPrint('Error updating password: $e');
      showToast(Constants.unableToUpdatePassword);
    }
  }

  List<XFile>? _mediaFileList = [];

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      debugPrint("result $source");
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        File file = File(pickedFile.path);

        uploadAndSetUserPhoto(file, widget.user.email ?? widget.user.uid);

        // Fetch updated user data to confirm changes
        User updatedUser = FirebaseAuth.instance.currentUser!;
        setState(() {
          widget.user = updatedUser;
        });
        setState(() {
          _setImageFileListFromFile(pickedFile);
        });
      }
      debugPrint(pickedFile?.path);
      debugPrint(_pickImageError);
      debugPrint(_mediaFileList?.length.toString());
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  void _openImagePickerBottomSheet() async {
    final result = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return const SingleChildScrollView(
          child: ImagePickerBottomSheet(),
        );
      },
    );
    if (result != null) {
      bool hasPermission = await requestPermissions();
      debugPrint("hasPermission $hasPermission");
      if (!hasPermission) {
        // ignore: use_build_context_synchronously
        _onImageButtonPressed(result, context: context);
      } else {
        openAppSettings();
      }
    }
  }

  void _showUpdateDisplayNameBottomSheet(BuildContext context) async {
    TextEditingController textEditingController =
        TextEditingController(text: widget.user.displayName);

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
                  Constants.displayName,
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
                    Constants.displayName,
                    Constants.enterDisplayName,
                    true,
                    null),
                const SizedBox(height: 10.0),
                customElevatedButton(
                  Constants.updateDisplayName,
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
      updateDisplayName(addItem.toString());
    } else {
      showToast(Constants.nothingTodo);
    }
  }

  void _showUpdatePasswordBottomSheet(BuildContext context) async {
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
                  Constants.updatePassword,
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
                    Constants.updatePassword,
                    Constants.enterUpdatePassword,
                    true,
                    null),
                const SizedBox(height: 10.0),
                customElevatedButton(
                  Constants.updatePassword,
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
    if (addItem == null) {
      // showToast(Constants.passwordLengthMessage);
    } else if (addItem != null && addItem.toString().length > 8) {
      updatePassword(addItem.toString());
    } else {
      showToast(Constants.passwordLengthMessage);
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
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: _mediaFileList!.isEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.user.photoURL ?? Constants.userAvatar),
                      radius: 50.0,
                      backgroundColor: Colors.transparent,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white70,
                              child: IconButton(
                                onPressed: _openImagePickerBottomSheet,
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : CircleAvatar(
                      backgroundImage: FileImage(
                        File(_mediaFileList!.first.path),
                      ),
                      radius: 50.0,
                      backgroundColor: Colors.transparent,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white70,
                              child: IconButton(
                                onPressed: _openImagePickerBottomSheet,
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          widget.user.displayName == null
              ? GestureDetector(
                  onTap: () {
                    if (widget.user.providerData.first.providerId ==
                        "password") {
                      _showUpdateDisplayNameBottomSheet(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        Constants.displayNameUnavailable,
                        style: TextStyle(color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: () {
                          if (widget.user.providerData.first.providerId ==
                              "password") {
                            _showUpdateDisplayNameBottomSheet(context);
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    if (widget.user.providerData.first.providerId ==
                        "password") {
                      _showUpdateDisplayNameBottomSheet(context);
                    }
                  },
                  child: Text(
                    widget.user.displayName ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22.0),
                  ),
                ),
          Text(
            widget.user.email ?? "",
            textAlign: TextAlign.center,
          ),
          widget.user.providerData.first.providerId == "password"
              ? ListTile(
                  title: const Text(
                    Constants.updatePassword,
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                  onTap: () {
                    _showUpdatePasswordBottomSheet(context);
                  },
                )
              : Container(),
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
              Constants.termsConditions,
              style: TextStyle(fontSize: 18),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
            ),
            onTap: navigateToTermsAndConditions,
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
