import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_whalesocial/Widgets/ProgressWidget.dart';
import 'package:flutter_whalesocial/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "My Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}



class SettingsScreenState extends State<SettingsScreen> {

  TextEditingController nickNameTextEditingController;
  TextEditingController aboutMeTextEditingController;

  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nickNamefocusNode = FocusNode();
  final FocusNode aboutMefocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readDataFromLocal();
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photoUrl = preferences.getString("photoUrl");

    nickNameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);

    setState(() {

    });
  }

  //chon anh tu album may ao
  Future getImage() async {
    File newImageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    //set anh moi
    if(newImageFile != null){
      setState(() {
        this.imageFileAvatar = newImageFile;
        isLoading = true;
      });
    }

    uploadImageToFirestoreAndStorage();
  }

  ////day hinh len firebase
  Future uploadImageToFirestoreAndStorage() async {
    String mFileName = id;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value)
    {
      if(value.error == null){
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl){
          photoUrl = newImageDownloadUrl;
          ///up lai data len firebase
          Firestore.instance.collection("users").document(id).updateData({
            "photoUrl": photoUrl,
            "aboutMe": aboutMe,
            "nickname": nickname,
          }).then((data) async {
            await preferences.setString("photoUrl", photoUrl);
            setState(() {
              isLoading = false;
            });
            
            Fluttertoast.showToast(msg: "Update image successfully");
          });
        }, onError: (errorMsg){
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Error occured, can't upload image");
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  ////cap nhat thong tin
  void updateData() {
    nickNamefocusNode.unfocus();
    aboutMefocusNode.unfocus();
    setState(() {
      isLoading = false;
    });
    ////laythongtin tu firebase
    Firestore.instance.collection("users").document(id).updateData({
      "photoUrl": photoUrl,
      "aboutMe": aboutMe,
      "nickname": nickname,

    }).then((data) async {
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("nickname", nickname);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Update info successfully");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //avatar acc
              Container(
                child: Center(
                 child: Stack(
                   children: <Widget>[
                     (imageFileAvatar == null)
                     ? (photoUrl != "")
                     ? Material(
                       //hien avatar cu hoac dang set
                       child: CachedNetworkImage(
                         placeholder: (context, url) => Container(
                           child: CircularProgressIndicator(
                             strokeWidth: 2,
                             valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                           ),
                           width: 200,
                           height: 200,
                           padding: EdgeInsets.all(20),
                         ),
                         imageUrl: photoUrl,
                         width: 200,
                         height: 200,
                         fit: BoxFit.cover,
                       ),
                       borderRadius: BorderRadius.all(Radius.circular(125)),
                       clipBehavior: Clip.hardEdge,
                     )
                     : Icon(Icons.account_circle, size: 90,color: Colors.lightBlueAccent,)
                     : Material(
                       //hien avatar moi up len
                       child: Image.file(
                         imageFileAvatar,
                         width: 200,
                         height: 200,
                         fit: BoxFit.cover,
                       ),
                       borderRadius: BorderRadius.all(Radius.circular(125)),
                       clipBehavior: Clip.hardEdge,
                     ),
                     IconButton(
                       icon: Icon(
                         Icons.camera_alt, size: 50, color: Colors.white.withOpacity(0.3),
                       ),
                       onPressed: getImage,
                       padding: EdgeInsets.all(0),
                       splashColor: Colors.transparent,
                       highlightColor: Colors.grey,
                       iconSize: 200,
                     ),
                   ],
                 ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20),
              ),

              ///nhap du lieu
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(1), child: isLoading ? circularProgress() : Container(),),

                  //ten
                  Container(
                    child: Text(
                      "Profile Name: ",
                      style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent, fontSize: 22),
                    ),
                    margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  ),
                  Container(
                    child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          style: TextStyle(fontSize: 17),
                          decoration: InputDecoration(
                            hintText: "Please enter your name",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: nickNameTextEditingController,
                          onChanged: (value){
                            nickname = value;
                          },
                          focusNode: nickNamefocusNode,
                        ),
                    ),
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
                  ),

                  ///tieu su cua acc
                  Container(
                    child: Text(
                      "Bio: ",
                      style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent, fontSize: 22),
                    ),
                    margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        style: TextStyle(fontSize: 17),
                        decoration: InputDecoration(
                          hintText: "Please introduce yourself",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMeTextEditingController,
                        onChanged: (value){
                          aboutMe = value;
                        },
                        focusNode: aboutMefocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 10, right: 10,),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              ////Nut cap nhat
              Container(
                child: FlatButton(
                  onPressed: updateData,
                  child: Text(
                    "Update Account", style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.lightBlueAccent,
                  highlightColor: Colors.grey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.lightBlueAccent,
                      width: 1,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(50)),
                ),
                margin: EdgeInsets.only(top:40, bottom: 1),
              ),
              /////nut dang xuat
              Container(
                child: FlatButton(
                  onPressed: () {
                    logoutUser();
                    logoutUserFB();
                  },
                  child: Text(
                    "Logout Account", style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.red,
                  highlightColor: Colors.grey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.red,
                      width: 1,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(50)),
                ),
                margin: EdgeInsets.only(top:10, bottom: 1),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15,right: 15),
        ),
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = FacebookLogin();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  /// out tai khoan
  Future<Null> logoutUser() async{
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    await facebookLogin.logOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);
  }
  Future<Null> logoutUserFB() async{
    await FirebaseAuth.instance.signOut();
    await facebookLogin.logOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);
  }

}
