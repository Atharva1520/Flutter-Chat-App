import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/login_screen.dart';

Future<User?> createAccount(String name, String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user != null) {
      print("Created Account Successfully");

      user.updateProfile(displayName: name);

      await _firestore.collection('users').doc(_auth.currentUser?.uid).set({
        "username": name,
        "email": email,
        "status": "unavaliable",
        "uid": _auth.currentUser!.uid,
      });
    } else {
      print("Account creation Failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> loginIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user != null) {
      print("Login Successfully");
      return user;
    } else {
      print("Login Unsuccessful");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future logout(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await _auth.signOut().then((value) => Navigator.push(
        context, MaterialPageRoute(builder: (_) => LoginScreen())));
  } catch (e) {
    print(e);
  }
}
