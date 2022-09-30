import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/chatroom.dart';
import 'package:flutter_chat/screens/methods.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus("Online");
    } else {
      //offline
      setStatus("Offline");
    }
  }

  final TextEditingController _search = TextEditingController();
  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Map<String, dynamic> userMap = <String, dynamic>{};

  void onsearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Home Screen"),
          actions: [
            IconButton(
                onPressed: () => logout(context), icon: Icon(Icons.logout))
          ],
        ),
        body: isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Container(
                    height: size.height / 14,
                    width: size.width,
                    alignment: Alignment.center,
                    child: Container(
                      height: size.height / 14,
                      width: size.width / 1.2,
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            prefixIcon: Icon(Icons.search),
                            hintText: "Search",
                            hintStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 30,
                  ),
                  ElevatedButton(onPressed: onsearch, child: Text("Search")),
                  SizedBox(
                    height: size.height / 30,
                  ),
                  userMap['username'] != null && userMap['email'] != null
                      ? ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                                _auth.currentUser!.displayName! != null
                                    ? _auth.currentUser!.displayName!
                                    : "",
                                userMap['username'] != null
                                    ? userMap['username']
                                    : "");

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatRoom(
                                          chatRoomId: roomId,
                                          userMap: userMap,
                                        )));
                          },
                          leading: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          title: Text(
                            userMap['username'],
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          subtitle: Text(userMap['email'],
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12)),
                          trailing: Icon(Icons.chat),
                        )
                      : Container(),
                ],
              ));
  }
}
