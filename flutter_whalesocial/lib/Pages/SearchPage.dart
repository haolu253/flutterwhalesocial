import 'dart:async';
import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whalesocial/Models/user.dart';
import 'package:flutter_whalesocial/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter_whalesocial/Pages/ChattingPage.dart';
import 'package:flutter_whalesocial/Pages/AccountSettingsPage.dart';
import 'package:flutter_whalesocial/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SearchScreen extends StatefulWidget {
  final String currentUserId;
  SearchScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => SearchScreenState(currentUserId: currentUserId);
}

class SearchScreenState extends State<SearchScreen> {
  SearchScreenState({Key key, @required this.currentUserId});

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Container(
          margin: new EdgeInsets.only(bottom: 4),
          child: TextFormField(
            style: TextStyle(fontSize: 18, color: Colors.white),
            controller: searchTextEditingController,
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              filled: false,
              prefixIcon: Icon(
                Icons.person_search, color: Colors.white, size: 30,),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  emptyTextFormField();
                },
              ),
            ),
            onFieldSubmitted: controlSearching,
          ),
        ),
      ),
      body:
      futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen(),
    );
  }

  /////////////////
  displayUserFoundScreen() {
    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchUserResult = [];
          dataSnapshot.data.documents.forEach((document) {
            User eachUser = User.fromDocument(document);
            UserResult userResult = UserResult(eachUser);
            if (currentUserId != document["id"]) {
              searchUserResult.add(userResult);
            }
          });
          if(searchUserResult.length == 0)
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/icon4.png', width: 250, height: 250,),
                  Text("Can't find that user !!", style: TextStyle(
                      fontSize: 25.0, color: Colors.blueGrey),),
                ],
              ),
            );
          else
            return ListView(children: searchUserResult,);
        }
    );
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/icon3.png', width: 250, height: 250,),
            Text("Find your friend now !!", style: TextStyle(
                fontSize: 25.0, color: Colors.blueGrey),),
          ],
        ),
    );
  }

  controlSearching(String userName) {
    Future<QuerySnapshot> allFoundUsers = Firestore.instance.collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userName).getDocuments();
    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }

  emptyTextFormField() {
    searchTextEditingController.clear();
    setState(() {
      futureSearchResults = null;
    });
  }
}

class UserResult extends StatelessWidget
{
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black, backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Joined: " + DateFormat("dd MMMM, yyyy - hh:mm:aa")
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(eachUser.createdAt))),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendUserToChatPage(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Chat(
      receiverId: eachUser.id,
      receiverAvatar: eachUser.photoUrl,
      receiverName: eachUser.nickname,
    )));
  }
}

