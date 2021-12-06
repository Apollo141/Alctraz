import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Alctraaz/Models/user.dart';
import 'package:Alctraaz/Pages/LoginPage.dart';
import 'package:Alctraaz/Widgets/ProgressWidget.dart';
import 'package:Alctraaz/main.dart';
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Setting",
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
  TextEditingController nicknametextedittingcontroller;
  TextEditingController aboutMetextedittingcontroller;
  SharedPreferences prefernces;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imagefileavatar;
  bool isloading = false;

  final FocusNode nicknamefocusnode = FocusNode();
  final FocusNode aboutmefocusnode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDatafrmLocal();
  }

  void readDatafrmtxt() async {
    prefernces = await SharedPreferences.getInstance();
    id = prefernces.getString("id");
    nickname = prefernces.getString("nickname");
    aboutMe = prefernces.getString("aboutMe");
    photoUrl = prefernces.getString("photoUrl");
    setState(() {});
  }

  void readDatafrmLocal() async {
    prefernces = await SharedPreferences.getInstance();
    id = prefernces.getString("id");
    nickname = prefernces.getString("nickname");
    aboutMe = prefernces.getString("aboutMe");
    photoUrl = prefernces.getString("photoUrl");
    nicknametextedittingcontroller = TextEditingController(text: nickname);
    aboutMetextedittingcontroller = TextEditingController(text: aboutMe);
    setState(() {});
  }

  void tik() {
    User usr = User();
  }

  Future imageGet() async {
    File newimagefile =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newimagefile != null) {
      setState(() {
        this.imagefileavatar = newimagefile;
        isloading = true;
      });
    }
    uploadimagetofirestoreAge();
  }

  Future uploadimagetofirestoreAge() async {
    StorageTaskSnapshot storageTaskSnapshot;
    String filenm = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(filenm);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imagefileavatar);
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newimageurl) {
          photoUrl = newimageurl;
          Firestore.instance.collection("users").document(id).updateData({
            "photoUrl": photoUrl,
            "nickname": nickname,
            "aboutMe": aboutMe
          }).then((data) async {
            await prefernces.setString("photoUrl", photoUrl);
            setState(() {
              isloading = false;
            });
            Fluttertoast.showToast(msg: "Information Updated Successfully");
          });
        }, onError: (errormssg) {
          setState(() {
            isloading = false;
          });
          Fluttertoast.showToast(msg: "Error in Getting URL");
        });
      }
    }, onError: (errormesg) {
      setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(msg: errormesg.toString());
    });
  }

  void updatedataz() {
    nicknamefocusnode.unfocus();
    aboutmefocusnode.unfocus();
    setState(() {
      isloading = false;
    });
    Firestore.instance.collection("users").document(id).updateData({
      "photoUrl": photoUrl,
      "nickname": nickname,
      "aboutMe": aboutMe
    }).then((data) async {
      await prefernces.setString("photoUrl", photoUrl);
      await prefernces.setString("nickname", nickname);
      await prefernces.setString("aboutMe", aboutMe);
      setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(msg: "Information Updated Successfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (imagefileavatar == null)
                          ? (photoUrl != "")
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.lightBlueAccent),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_box,
                                  size: 90.0,
                                  color: Colors.lightBlue,
                                )
                          : Material(),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 100.0,
                          color: Colors.white38.withOpacity(0.3),
                        ),
                        onPressed: imageGet,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isloading ? circularProgress() : Container(),
                  ),
                  Container(
                    child: Text(
                      "Profile Name :",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "e.g kamel ahmad",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: nicknametextedittingcontroller,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: nicknamefocusnode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                  Container(
                    child: Text(
                      "About Me :",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: " Bio ..... ",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMetextedittingcontroller,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: aboutmefocusnode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              //upadte
              Container(
                child: FlatButton(
                  onPressed: updatedataz,
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Colors.lightBlueAccent,
                  highlightColor: Colors.grey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0),
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: logoutuser,
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              )
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        )
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutuser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    //could add the loading or progress
    this.setState(() {
      isloading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
