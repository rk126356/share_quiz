import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_quiz/widgets/update_dialog_widget.dart';

updateAppLaunched(context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var user = FirebaseAuth.instance.currentUser!;

  String currentVersion = packageInfo.version;

  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get()
      .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      // Check if the document exists
      Map<String, dynamic>? data = snapshot.data();
      if (data != null && data.containsKey('noOfTimeAppLaunched')) {
        int noOfTimeAppLaunched = data['noOfTimeAppLaunched'];

        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'noOfTimeAppLaunched': noOfTimeAppLaunched + 1,
          'appVersion': currentVersion,
        });
      } else {
        if (kDebugMode) {
          print('Field noOfTimeAppLaunched not found or is null.');
        }
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'noOfTimeAppLaunched': 1,
          'appVersion': currentVersion,
        });
      }
    } else {
      if (kDebugMode) {
        print('Document does not exist.');
      }
    }
  });

  FirebaseFirestore.instance
      .collection('appInfo')
      .doc('t24RkgPVXADO1i9wu3YJ')
      .get()
      .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      // Check if the document exists
      Map<String, dynamic>? data = snapshot.data();
      if (data != null) {
        String version = data['version'];
        bool isUpdateAvailable = data['isUpdateAvailable'];
        String updateMessage = data['updateMessage'];
        String appLink = data['appLink'];
        bool isForceUpdate = data['isForceUpdate'];
        if (isUpdateAvailable && currentVersion != version) {
          void showUpdateDialog(BuildContext context) {
            showDialog(
              context: context,
              barrierDismissible: isForceUpdate,
              builder: (context) {
                return UpdateDialog(
                  version: version,
                  description: updateMessage,
                  appLink: appLink,
                  allowDismissal: !isForceUpdate,
                );
              },
            );
          }

          showUpdateDialog(context);
        }
      } else {
        if (kDebugMode) {
          print('Field version not found or is null.');
        }
      }
    } else {
      if (kDebugMode) {
        print('Document does not exist.');
      }
    }
  });
}
