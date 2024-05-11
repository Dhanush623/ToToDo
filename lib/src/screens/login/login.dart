import 'package:flutter/material.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/screens/login/terms_and_conditions.dart';
import 'package:totodo/src/widgets/spacer.dart';

class Login extends StatelessWidget {
  const Login({super.key, required this.handle});
  final Function handle;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            ElevatedButton(
              onPressed: () {
                handle();
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
    );
  }
}
