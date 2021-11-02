import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whalesocial/Widgets/FullImageWidget.dart';
import 'package:flutter_whalesocial/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  Chat({
   Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;

  ChatScreen({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  }) : super (key: key);

  @override
  State createState() => ChatScreenState(receiverId: receiverId, receiverAvatar: receiverAvatar);
}




class ChatScreenState extends State<ChatScreen> {

  final String receiverId;
  final String receiverAvatar;

  ChatScreenState({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  });

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  String imageUrl;
  
  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading = false;
    
    chatId = "";
    readLocal();
  }
  
  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if(id.hashCode <= receiverId.hashCode){
      chatId = '$id-$receiverId';
    }
    else{
      chatId = '$receiverId-$id';
    }

    Firestore.instance.collection("users").document(id).updateData({'chattingWith': receiverId});
    setState(() {
    });
  }

  onFocusChange(){
    if(focusNode.hasFocus){
      setState(() {
        //an sticker khi ban phim popup len
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //hien list tin
              createListMessages(),

              //hien sticker
              (isDisplaySticker ? createStickers() : Container()),

              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createLoading(){
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  Future<bool> onBackPress(){
    if(isDisplaySticker)
    {
      setState(() {
        isDisplaySticker = false;
      });
    }
    else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createStickers(){
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage("gif1", 2),
                child: Image.asset(
                  "assets/images/gif1.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("gif2", 2),
                child: Image.asset(
                  "assets/images/gif2.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("gif3", 2),
                child: Image.asset(
                  "assets/images/gif3.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage("gif4", 2),
                child: Image.asset(
                  "assets/images/gif4.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("gif5", 2),
                child: Image.asset(
                  "assets/images/gif5.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("gif6", 2),
                child: Image.asset(
                  "assets/images/gif6.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage("gif7", 2),
                child: Image.asset(
                  "assets/images/gif7.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("gif8", 2),
                child: Image.asset(
                  "assets/images/gif8.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("gif9", 2),
                child: Image.asset(
                  "assets/images/gif9.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5),
      height: 180,
    );
  }

  void getSticker(){
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  createListMessages(){
    return Flexible(
        child: chatId == ""
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                ),
              )
            : StreamBuilder(
                stream: Firestore.instance.collection("messages")
                    .document(chatId)
                    .collection(chatId)
                    .orderBy("timestamp", descending: true)
                    .limit(40).snapshots(),
            builder : (context, snapshot){
                  if(!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                    );
                  }
                  else{
                    listMessage = snapshot.data.documents;
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) => createItem(index, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  }
            }
          ),
    );
  }

  bool isLastMsgLeft(int index){
    if((index>0 && listMessage!= null && listMessage[index-1]["idFrom"]==id) || index == 0){
      return true;
    }
    else{
      return false;
    }
  }

  bool isLastMsgRight(int index){
    if((index>0 && listMessage!= null && listMessage[index-1]["idFrom"]==id) || index == 0){
      return true;
    }
    else{
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document){
    ///Nguoi nhan' tin ben phai
    if(document["idFrom"] == id){
      return Row(
        children: <Widget>[
          ///tin nhan type = 0 la text
          document["type"] == 0
          ? Container(
            child: Text(
              document["content"],
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: 200,
            decoration: BoxDecoration(color: Colors.lightBlueAccent, borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 10 : 10, right: 15),
          )
          ///tin nhan type = 1 la hinh anh
          : document["type"] == 1
          ? Container(
            child: FlatButton(
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                    width: 200,
                    height: 200,
                    padding: EdgeInsets.all(70),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Image.asset("asset/images/img_not_available.jpeg", width: 200, height: 200, fit: BoxFit.cover ,),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: document["content"],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
                clipBehavior: Clip.hardEdge,
              ),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => FullPhoto(url: document["content"])
                ));
              },
            ),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 10 : 10, right: 1),
          )
          ///sticker
          : Container(
            child: Image.asset(
              "assets/images/${document['content']}.gif",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 10 : 10, right: 15),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    ///Nguoi nhan. tin ben trai
    else{
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMsgLeft(index)
                ? Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                      width: 35,
                      height: 35,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    imageUrl: receiverAvatar,
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
                : Container(width: 35,),
                ////hien tin nhan ra ben trai
                ///tin nhan type = 0 la chu
                document["type"] == 0
                    ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  width: 200,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.only(left: 15),
                )

                ///tin nhan type = 1 la hinh anh
                    : document["type"] == 1
                    ? Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          width: 200,
                          height: 200,
                          padding: EdgeInsets.all(70),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset("asset/images/img_not_available.jpeg", width: 200, height: 200, fit: BoxFit.cover ,),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: document["content"],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FullPhoto(url: document["content"])
                      ));
                    },
                  ),
                  margin: EdgeInsets.only(left: 1),
                )

                ///sticker
                    : Container(
                  child: Image.asset(
                    "assets/images/${document['content']}.gif",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(left: 15),
                ),

              ],
            ),
            isLastMsgLeft(index)
            ? Container(
              child: Text(
                DateFormat("dd MMMM, yyyy - hh:mm:aa")
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"]))),
                style: TextStyle(color: Colors.grey, fontSize: 12,),
              ),
              margin: EdgeInsets.only(left: 53, top: 15, bottom: 5),
            ) : Container(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10),
      );
    }
  }

  createInput(){
    return Container(
      child: Row(
        children: <Widget>[
          ///gui hinh anh
          Material(
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.lightBlueAccent,
                onPressed: getImage,
              ),
            ),
          ),
          ///gui emoji
          Material(
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: Icon(Icons.tag_faces),
                color: Colors.lightBlueAccent,
                onPressed: getSticker,
              ),
            ),
          ),
          Flexible(
              child: Container(
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,fontSize: 15,
                  ),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: "Aa",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: focusNode,
                ),
              ),
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          )
        ),
        color: Colors.white,
      ),
    );
  }

  void onSendMessage(String contentMsg, int type){
    if(contentMsg != ""){
      textEditingController.clear();
      var docRef = Firestore.instance.collection("messages")
          .document(chatId)
          .collection(chatId).document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef,
          {
            "idFrom": id,
            "idTo": receiverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
          }
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
    }
    else{
      Fluttertoast.showToast(msg: "Empty Message! Can't be send.");
    }
  }

  Future getImage() async{
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(imageFile != null){
      isLoading = true;
    }
    uploadImageFile();
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage.instance.ref().child("Chat Images").child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error: " + error);
    });
  }
}
