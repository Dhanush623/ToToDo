import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/analytics_helper.dart';
import 'package:totodo/src/services/email_validator.dart';
import 'package:totodo/src/widgets/my_banner_ad.dart';
import 'package:totodo/src/widgets/show_toast.dart';
import 'package:totodo/src/widgets/spacer.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController usernameEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController displayNameEditingController = TextEditingController();
  TextEditingController confirmPasswordEditingController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    addScreenViewTracking(
      widget.runtimeType.toString(),
      "SignIn",
    );
  }

  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        showToast(Constants.unableToCreateUser);
      }
      User user = userCredential.user!;
      user.updateDisplayName(displayName);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("**************");
      debugPrint(e.code);
      if (e.code == 'weak-password') {
        debugPrint(Constants.weakPassword);
        showToast(Constants.weakPassword);
      } else if (e.code == 'email-already-in-use') {
        debugPrint(Constants.emailAlreadyUsed);
        showToast(Constants.emailAlreadyUsed);
      }
      showToast(Constants.unableToCreateUser);
    } catch (e) {
      debugPrint("--------------------");
      debugPrint(e.toString());
      showToast(Constants.unableToCreateUser);
    }
    return null;
  }

  createUser() async {
    if (displayNameEditingController.text.isEmpty) {
      showToast(Constants.displayNameLengthMessage);
      return true;
    }
    if (!_isEmailValid || usernameEditingController.text.isEmpty) {
      showToast(Constants.enterValidEmail);
      return true;
    }
    if (passwordEditingController.text.length < 8) {
      showToast(Constants.passwordLengthMessage);
      return true;
    }
    if (confirmPasswordEditingController.text.length < 8) {
      showToast(Constants.confirmPasswordLengthMessage);
      return true;
    }
    if (passwordEditingController.text !=
        confirmPasswordEditingController.text) {
      showToast(Constants.passwordConfirmPasswordMismatch);
      return true;
    }
    UserCredential? userCredential = await registerWithEmailAndPassword(
        usernameEditingController.text,
        passwordEditingController.text,
        displayNameEditingController.text);
    if (userCredential != null) {
      showToast(Constants.userCreated);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Constants.signUp,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: displayNameEditingController,
              onChanged: (value) {},
              decoration: InputDecoration(
                label: const Text(
                  Constants.displayName,
                ),
                hintText: Constants.enterDisplayName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
            spacer(10, 0),
            TextField(
              controller: usernameEditingController,
              onChanged: (value) {
                setState(() {
                  _isEmailValid = EmailValidator.isValid(value);
                });
              },
              decoration: InputDecoration(
                label: const Text(
                  Constants.email,
                ),
                errorText: _isEmailValid ? null : Constants.enterValidEmail,
                hintText: Constants.enterEmailId,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
            spacer(10, 0),
            TextField(
              controller: passwordEditingController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                label: const Text(
                  Constants.password,
                ),
                hintText: Constants.enterPassword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              onChanged: (value) {},
            ),
            spacer(10, 0),
            TextField(
              controller: confirmPasswordEditingController,
              obscureText: !_confirmPasswordVisible,
              decoration: InputDecoration(
                label: const Text(
                  Constants.confirmPassword,
                ),
                hintText: Constants.enterConfirmPassword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: (value) {},
            ),
            spacer(30, 0),
            ElevatedButton(
              onPressed: () {
                createUser();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16.0,
                  ),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Constants.signUp,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: AdSize.banner.width.toDouble(),
              height: AdSize.banner.height.toDouble(),
              child: const MyBannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
