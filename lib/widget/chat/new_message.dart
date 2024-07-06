import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  late final FirebaseMessaging messaging;
  final _controller = TextEditingController();
  var _enteredMessage = '';
  var currentUserToken;

  Future<List<String>> getAllToken() async {            
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<String> dataList = await querySnapshot.docs
        .map((doc) => doc.get('token').toString())
        .toList();

    final prefs = await SharedPreferences.getInstance();
    var currentUserToken = prefs.getString('userToken');

    print('---------------------Total List-----------------');
    print(dataList);
    dataList.removeWhere((element) => element == currentUserToken);
    print('...............Remove List ........................');
    print(dataList);
    return dataList;
  }

  Future<http.Response?> sendNotification(
      String username, String message) async {
    final data = {
      "registration_ids": await getAllToken(),
      "notification": {
        "body": message,
        "title": username,
        // "android_channel_id": "pushnotificationapp",
        "image":
            "https://cdn2.vectorstock.com/i/1000x1000/23/91/small-size-emoticon-vector-9852391.jpg",
        "sound": true
      }
    };

    final sendData = jsonEncode(data);

    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAIGLSWxg:APA91bEKSYsFnG6-mQbuTxKdabis20uNzCPSa_GInVE9Fg61wb9K6Xh1zXaX2CAeCGl5FhlGWfWsFeD16gUZGTLRJfjJF-Kqd6KTuD1ViwclQPe9znZ_a1BpXGlV0MDBEi8wSWQSadaQ'
        },
        body: sendData,
      );

      if (response.statusCode == 200) {
        print('message sent');
        print(response.body);
      } else {
        print('error occured');
      }
    } catch (error) {
      print(error);
    }
    return null;
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userDatass = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    var userData = userDatass.data();
    print('...................userDatass...........................');
    print(userData);
    print('...................userDatass........................');

    await FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData?['username'] ?? "",
      'userImage': userData?['image_url'],
    });

    sendNotification(userData?['username'], _enteredMessage);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: const Icon(
              Icons.send,
            ),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}
