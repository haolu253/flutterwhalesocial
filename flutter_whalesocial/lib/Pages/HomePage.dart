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
import 'package:flutter_whalesocial/Pages/SearchPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  HomeScreenState({Key key, @required this.currentUserId});

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  final String currentUserId;


  /////lam cai nut floating
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animationIcon;
  Animation<double> _translateButton;

  /////chua nhan thi nua hien icon message nhan vo thi chuyen san icon X
  @override
  void initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animationIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor =
        ColorTween(begin: Colors.lightBlueAccent, end: Colors.redAccent)
            .animate(_animationController);
    _translateButton =
        Tween<double>(begin: 56.0, end: -14.0).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ///widgets cua may cai icon con cua floating
  Widget buttonAccount() {
    return Container(
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Settings()));
          },
          backgroundColor: Colors.lightBlueAccent,
          icon: Icon(Icons.account_circle, color: Colors.white,),
          label: Text("Account"),
        )
    );
  }

  Widget buttonSearch() {
    return Container(
        child: FloatingActionButton.extended(
          onPressed: () {
            ///current user id tranh tu search ra minh lai
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                SearchScreen(currentUserId: currentUserId,)));
          },
          backgroundColor: Colors.lightBlueAccent,
          icon: Icon(Icons.search, color: Colors.white,),
          label: Text("Search"),
        )
    );
  }

  Widget buttonGroupchat() {
    return Container(
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.lightBlueAccent,
          icon: Icon(Icons.group_add, color: Colors.white,),
          label: Text("Group"),
        )
    );
  }

  Widget buttonMore() {
    return Container(
        child: FloatingActionButton.extended(
          backgroundColor: _buttonColor.value,
          onPressed: animate,
          icon: Icon(Icons.add, color: Colors.white,),
          label: Text("More"),
        )
    );
  }

  //////xu ly cai nut bam popup len hay thu xuong lai
  animate() {
    if (!isOpened)
      _animationController.forward();
    else
      _animationController.reverse();
    isOpened = !isOpened;
  }

  homePageHeader() {
    return AppBar(
      title: Text("Whale Social", style: TextStyle(
          fontSize: 40.0, color: Colors.white, fontFamily: "Signatra"),),
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homePageHeader(),
      body: displayUserFoundScreen(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues
              (0.0, _translateButton.value * 6.0, 0.0),
            child: buttonAccount(),
          ),
          Transform(
            transform: Matrix4.translationValues
              (0.0, _translateButton.value * 4.0, 0.0),
            child: buttonSearch(),
          ),
          Transform(
            transform: Matrix4.translationValues
              (1.0, _translateButton.value * 2.0, 0.0),
            child: buttonGroupchat(),
          ),
          buttonMore(),
        ],
      ),
    );
  }

  displayUserFoundScreen() {
    return StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) return const Text("Loading...");
          List<UserResult> searchUserResult = [];
          dataSnapshot.data.documents.forEach((document) {
            User eachUser = User.fromDocument(document);
            UserResult userResult = UserResult(eachUser);
            if (currentUserId != document["id"] && document["chattingWith"] == currentUserId) {
              searchUserResult.add(userResult);
            }
          });
          if (searchUserResult.length == 0)
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/icon2.png', width: 250, height: 250,),
                  Text("Not chat with anyone yet !!", style: TextStyle(
                      fontSize: 25.0, color: Colors.blueGrey),),
                ],
              ),
            );
          else
            return ListView(children: searchUserResult,);
        }
    );
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