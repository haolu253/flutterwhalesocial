import 'dart:async';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whalesocial/Pages/HomePage.dart';
import 'package:flutter_whalesocial/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = FacebookLogin();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;

  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    isSignedIn();
  }
  
  isSignedIn() async {
    this.setState(() {
      isLoggedIn = true;
    });
    
    preferences = await SharedPreferences.getInstance();
    
    isLoggedIn = await googleSignIn.isSignedIn();
    if(isLoggedIn){
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: preferences.getString("id"))));
    }
    //neu log dc thi k load nua
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xff14e4ff),Colors.blueAccent]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Whale Social",
              style:TextStyle(fontSize: 50.0, color: Colors.white, fontFamily: "Signatra"),
            ),
            Image.asset('assets/images/icon.png',width: 250, height: 250,),
            GestureDetector(
              onTap: loginFacebook,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 270.0,
                      height: 65.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/fbicon.png"),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: controlSignIn,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 270.0,
                      height: 65.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/ggicon.png"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1),
                      child: isLoading ? circularProgress() : Container(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  //////////facebook login
  Future loginFacebook() async {
    preferences = await SharedPreferences.getInstance();

    ///cho phep xem email
    final result = await facebookLogin.logIn(['email']);
    if (result.status == FacebookLoginStatus.loggedIn) {
      final credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      ///laythongtinuser
      final firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
      //Login dc
      if(firebaseUser != null){
        //Kiem tra neu da dang ky r
        final QuerySnapshot resultQuery = await Firestore.instance
            .collection("users").where("id",isEqualTo: firebaseUser.uid).getDocuments();
        final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;

        //Tao user moi neu chua dang ky
        if(documentSnapshots.length == 0){
          Firestore.instance.collection("users").document(firebaseUser.uid).setData({
            "nickname" : firebaseUser.displayName,
            "photoUrl" : firebaseUser.photoUrl,
            "id": firebaseUser.uid,
            "aboutMe" : "Hello! Nice to meet you.",
            "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            "chattingWith": null,
          });

          //luu thong tin lai
          currentUser = firebaseUser;
          await preferences.setString("id", currentUser.uid);
          await preferences.setString("nickname", currentUser.displayName);
          await preferences.setString("photoUrl", currentUser.photoUrl);
        }
        else{
          //lay thong tin
          currentUser = firebaseUser;
          await preferences.setString("id", documentSnapshots[0]["id"]);
          await preferences.setString("nickname", documentSnapshots[0]["nickname"]);
          await preferences.setString("photoUrl", documentSnapshots[0]["photoUrl"]);
          await preferences.setString("aboutMe", documentSnapshots[0]["aboutMe"]);
        }
        Fluttertoast.showToast(msg: "Logged in as ${firebaseUser.displayName}");
        this.setState(() {
          isLoading = false;
        });
        ///xai pushreplacement de nut back k quay lai trang login dc
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      }
      //Login fail
      else{
        Fluttertoast.showToast(msg: "Login failed. Please try again !");
        this.setState(() {
          isLoading = false;
        });
      }
    }
  }


  ///google login
  Future<Null> controlSignIn() async{
    preferences = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider
        .getCredential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);

    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
    
    //Login dc
    if(firebaseUser != null){
      //Kiem tra neu da dang ky r
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection("users").where("id",isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;

      //Tao user moi neu chua dang ky
      if(documentSnapshots.length == 0){
        Firestore.instance.collection("users").document(firebaseUser.uid).setData({
          "nickname" : firebaseUser.displayName,
          "photoUrl" : firebaseUser.photoUrl,
          "id": firebaseUser.uid,
          "aboutMe" : "Hello! Nice to meet you.",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });

        //luu thong tin lai
        currentUser = firebaseUser;
        await preferences.setString("id", currentUser.uid);
        await preferences.setString("nickname", currentUser.displayName);
        await preferences.setString("photoUrl", currentUser.photoUrl);
      }
      else{
        //lay thong tin
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString("nickname", documentSnapshots[0]["nickname"]);
        await preferences.setString("photoUrl", documentSnapshots[0]["photoUrl"]);
        await preferences.setString("aboutMe", documentSnapshots[0]["aboutMe"]);
      }
      Fluttertoast.showToast(msg: "Logged in as ${firebaseUser.displayName}");
      this.setState(() {
        isLoading = false;
      });
      ///xai pushreplacement de nut back k quay lai trang login dc
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
    }
    //Login fail
    else{
      Fluttertoast.showToast(msg: "Login failed. Please try again !");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}
