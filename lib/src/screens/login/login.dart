import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/analytics_helper.dart';
import 'package:totodo/src/screens/dashboard.dart';
import 'package:totodo/src/screens/login/sign_in.dart';
import 'package:totodo/src/screens/login/terms_and_conditions.dart';
import 'package:totodo/src/services/email_validator.dart';
import 'package:totodo/src/services/google_sign_in_services.dart';
import 'package:totodo/src/widgets/show_toast.dart';
import 'package:totodo/src/widgets/spacer.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  bool _passwordVisible = false;
  bool _isEmailValid = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    addScreenViewTracking(
      widget.runtimeType.toString(),
      "Login",
    );
  }

  Future<void> signIn(BuildContext context) async {
    UserCredential? signedUser = await signInWithGoogle();
    debugPrint("signedUser $signedUser");
    if (signedUser != null) {
      debugPrint(
        "FirebaseAuth.instance.currentUser ${FirebaseAuth.instance.currentUser}",
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Dashboard(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      showToast(Constants.unableToSignIn);
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      showToast(Constants.invalidUsernamePassword);
      return null;
    }
  }

  signInUser() async {
    if (!_isEmailValid || usernameEditingController.text.isEmpty) {
      showToast(Constants.enterValidEmail);
      return true;
    }
    if (passwordEditingController.text.length < 8) {
      showToast(Constants.passwordLengthMessage);
      return true;
    }
    UserCredential? userCredential = await signInWithEmailAndPassword(
      usernameEditingController.text,
      passwordEditingController.text,
    );
    if (userCredential != null) {
      showToast(Constants.signInSuccessfully);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Dashboard(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  // await FirebaseAuth.instance
  //   .sendPasswordResetEmail(email: "user@example.com");

  forgotPassword() {
    if (!_isEmailValid || usernameEditingController.text.isEmpty) {
      showToast(Constants.enterValidEmail);
      return true;
    }
    _showAlertDialog(context);
  }

  // Function to show the alert dialog
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(Constants.forgetPassword),
          content: const Text(Constants.forgetPasswordMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                addAnalyticsLogger(
                  "Login",
                  {
                    "name": "Login",
                    "value": "Forgot Password - No",
                  },
                );
                Navigator.of(context).pop();
              },
              child: const Text(Constants.no),
            ),
            ElevatedButton(
              onPressed: () {
                addAnalyticsLogger(
                  "Login",
                  {
                    "name": "Login",
                    "value": "Forgot Password - Reset",
                  },
                );
                _sendPasswordResetEmail(
                  usernameEditingController.text,
                  context,
                );
                Navigator.of(context).pop();
              },
              child: const Text(Constants.reset),
            )
          ],
        );
      },
    );
  }

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast(Constants.linkSendToMail);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Constants.appIcon,
                height: 100,
                width: 100,
              ),
              spacer(10, null),
              const Text(
                Constants.explore,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              spacer(10, null),
              const Text(
                Constants.exploreMessage,
                textAlign: TextAlign.center,
              ),
              spacer(30, null),
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
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
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
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
              spacer(10, null),
              ElevatedButton(
                onPressed: () {
                  signInUser();
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
                      Constants.signIn,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              spacer(10, null),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignIn(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Constants.ifNoAccount,
                    ),
                    Text(
                      Constants.createAccount,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              spacer(10, null),
              GestureDetector(
                onTap: () {
                  forgotPassword();
                },
                child: const Text(
                  Constants.forgetPassword,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              spacer(10, null),
              const Divider(),
              spacer(10, null),
              ElevatedButton(
                onPressed: () {
                  signIn(context);
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Constants.googleIcon,
                      height: 24,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      Constants.signInGoogle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              spacer(10, null),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsAndConditions(),
                    ),
                  );
                },
                child: const Text(
                  Constants.termsConditions,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
