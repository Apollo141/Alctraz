import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:Alctraaz/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Alctraaz/Widgets/FullImageWidget.dart';

class Chat extends StatelessWidget {
  final String takerId;
  final String takerAvatar;
  final String takerName;
  Chat(
      {Key key,
      @required this.takerId,
      @required this.takerAvatar,
      @required this.takerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(takerAvatar),
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          takerName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(takerId: takerId, takerAvatar: takerAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String takerId;
  final String takerAvatar;
  ChatScreen({Key key, @required this.takerAvatar, @required this.takerId})
      : super(key: key);
  @override
  State createState() =>
      ChatScreenState(takerId: takerId, takerAvatar: takerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  final String takerId;
  final String takerAvatar;
  ChatScreenState(
      {Key key, @required this.takerAvatar, @required this.takerId});
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController listContorllerScroll = ScrollController();
  bool isStickerDisplay;
  bool isLoading;
  File photoFile;
  String picUrl;
  String chatsId;
  SharedPreferences preferences;
  var listMessages;
  String id;
  @override
  void initState() {
    // TODO: implement initState
    focusNode.addListener(onFocus);
    isStickerDisplay = false;
    isLoading = false;
    chatsId = "";

    readFromLocal();
  }

  readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";
    if (id.hashCode <= takerId.hashCode) {
      chatsId = '$id-$takerId';
    } else {
      chatsId = '$takerId-$id';
    }
    Firestore.instance
        .collection("users")
        .document(id)
        .updateData({'chattingWith': takerId});
    setState(() {});
  }

  onFocus() {
    if (focusNode.hasFocus) {
      //hide stickers when the keyboard is in use
      setState(() {
        isStickerDisplay = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          //list of messages
          Column(
            children: <Widget>[
              mesaagesListCreate(),
              //display stickers
              (isStickerDisplay ? makeStickers() : Container()),
              inputsCreation(),
            ],
          ),
          loadinCreate()
        ],
      ),
      onWillPop: backOnPress,
    );
  }

  loadinCreate() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }

  Future<bool> backOnPress() {
    if (isStickerDisplay) {
      setState(() {
        isStickerDisplay = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  makeStickers() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onMessageSending("mimi1", 2),
                child: Image.asset("images/mimi1.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              ),
              FlatButton(
                onPressed: () => onMessageSending("mimi2", 2),
                child: Image.asset("images/mimi2.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              ),
              FlatButton(
                onPressed: () => onMessageSending("mimi3", 2),
                child: Image.asset("images/mimi3.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onMessageSending("mimi4", 2),
                child: Image.asset("images/mimi4.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              ),
              FlatButton(
                onPressed: () => onMessageSending("mimi5", 2),
                child: Image.asset("images/mimi5.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              ),
              FlatButton(
                onPressed: () => onMessageSending("mimi6", 2),
                child: Image.asset("images/mimi6.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onMessageSending("mimi7", 2),
                child: Image.asset("images/mimi7.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              ),
              FlatButton(
                onPressed: () => onMessageSending("mimi8", 2),
                child: Image.asset("images/mimi8.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              ),
              FlatButton(
                onPressed: () => onMessageSending("mimi9", 2),
                child: Image.asset("images/mimi9.gif",
                    width: 50, height: 50.0, fit: BoxFit.cover),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  void grabStickers() {
    focusNode.unfocus();
    setState(() {
      isStickerDisplay = !isStickerDisplay;
    });
  }

  mesaagesListCreate() {
    return Flexible(
        child: chatsId == ""
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                ),
              )
            : StreamBuilder(
                stream: Firestore.instance
                    .collection("messages")
                    .document(chatsId)
                    .collection(chatsId)
                    .orderBy("timeStamp", descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      ),
                    );
                  } else {
                    listMessages = snapshot.data.documents;
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          createItems(index, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                      reverse: true,
                      controller: listContorllerScroll,
                    );
                  }
                },
              ));
  }

  bool isitLastRight(int index) {
    if (index < 0 &&
            listMessages != null &&
            listMessages[index - 1]["idFrom"] != id ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isitLastLeft(int index) {
    if (index < 0 &&
            listMessages != null &&
            listMessages[index - 1]["idFrom"] == id ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createItems(int index, DocumentSnapshot document) {
    //my side of messages
    if (document["idFrom"] == id) {
      return Row(
        children: <Widget>[
          //text
          document["type"] == 0
              ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isitLastRight(index) ? 20.0 : 10.0, right: 10.0),
                )
              //image
              : document["type"] == 1
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlue),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document["content"],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document["content"])));
                        },
                      ),
                      margin: EdgeInsets.only(
                          bottom: isitLastRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  //gif,sticker
                  : Container(
                      child: Image.asset(
                        "images/${document['content']}.gif",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isitLastRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    //left side
    else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isitLastLeft(index)
                    ? Material(
                        // disply receiver picture
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.lightBlue),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: takerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35.0,
                      ),
//display messages
                document["type"] == 0
                    ? Container(
                        child: Text(
                          document["content"],
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                          
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document["type"] == 1
                        //image
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.lightBlue),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      "images/img_not_available.jpeg",
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document["content"],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document["content"])));
                              },
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
//sticker
                        : Container(
                            child: Image.asset(
                              "images/${document['content']}.gif",
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isitLastRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),
            isitLastRight(index)
                ? Container(
                    child: Text(
                      DateFormat("dd MMM - hh:mm:aa").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            (int.parse(document["timeStamp"]))),
                      ),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 50.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  inputsCreation() {
    return Container(
      child: Row(
        children: <Widget>[
          //button for images
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: LineIcon(LineIcons.image),
                color: Colors.blueAccent,
                onPressed: getPics,
              ),
            ),
            color: Colors.white,
          ),
          //button for emoji
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: LineIcon(LineIcons.winkingFace),
                color: Colors.blueAccent,
                onPressed: grabStickers,
              ),
            ),
            color: Colors.white,
          ),
          //field for texting
          Flexible(
              child: Container(
            child: TextField(
              style: TextStyle(color: Colors.black, fontSize: 15.0),
              controller: textEditingController,
              decoration: InputDecoration.collapsed(
                  hintText: "Start Texting Here...",
                  hintStyle: TextStyle(color: Colors.grey)),
              focusNode: focusNode,
            ),
          )),
          //message sending button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send_outlined),
                color: Colors.lightBlue,
                onPressed: () =>
                    onMessageSending(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  void onMessageSending(String messageContent, int type) {
// type 0 is text messsaging
// type 1 is text pictures
// type 2 is text stickers
    if (messageContent != "") {
      textEditingController.clear();
      var refDoc = Firestore.instance
          .collection("messages")
          .document(chatsId)
          .collection(chatsId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(refDoc, {
          "idFrom": id,
          "idTo": takerId,
          "timeStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": messageContent,
          "type": type
        });
      });
      listContorllerScroll.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: "Error , Message Was Not Sent , Please Try Again");
    }
  }

  Future getPics() async {
    photoFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (photoFile != null) {
      isLoading = true;
    }
    uploadPictureFile();
  }

  uploadPictureFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Chat Pictures").child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(photoFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downLoadingUrl) {
      picUrl = downLoadingUrl;
      setState(() {
        isLoading = false;
        onMessageSending(picUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: error);
    });
  }
}
