import 'package:firebase_crashlytics/firebase_crashlytics.dart';

addCrashlyticsLogger(String event, Map<String, Object?> parameters) async {
  await FirebaseCrashlytics.instance.log("$event: $parameters");
}
