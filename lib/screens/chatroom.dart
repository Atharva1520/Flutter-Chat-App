import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  Map<String, dynamic> userMap = <String, dynamic>{};

  String chatRoomId;
  ChatRoom({required this.chatRoomId, required this.userMap});

  final TextEditingController _message = TextEditingController();

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> meassage = {
        "sendBy": _auth.currentUser?.displayName,
        "message": _message.text,
        "time": FieldValue.serverTimestamp()
      };
      _message.clear();
      await _firebaseFirestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(meassage);
    } else {
      print("Enter some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseFirestore
            .collection("users")
            .doc(userMap['uid'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Container(
              child: Column(
                children: [
                  Text(userMap['username'] != null ? userMap['username'] : ""),
                  Text(userMap['status'] != null ? userMap['status'] : ""),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseFirestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return message(size, map);
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: size.height / 12,
                      width: size.width / 1.5,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          hintText: "Send Messages",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    IconButton(onPressed: onSendMessage, icon: Icon(Icons.send))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget message(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue,
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Text(
          map['message'],
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
