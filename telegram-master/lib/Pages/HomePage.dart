import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Alctraaz/Pages/ChattingPage.dart';
import 'package:Alctraaz/main.dart';
import 'package:Alctraaz/models/user.dart';
import 'package:Alctraaz/Pages/AccountSettingsPage.dart';
import 'package:Alctraaz/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);
  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key key, @required this.currentUserId});
  TextEditingController searchtxteditController = TextEditingController();
  Future<QuerySnapshot> fsearchResults;
  final String currentUserId;
  homepageheader() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            LineIcons.wrench,
            size: 37.0,
            color: Colors.lightBlueAccent,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Settings()));
          },
        )
      ],
      backgroundColor: Colors.purpleAccent,
      title: Container(
        margin: new EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 20.0, color: Colors.white),
          controller: searchtxteditController,
          decoration: InputDecoration(
              hintText: "Search Up Here ...",
              hintStyle: TextStyle(color: Colors.white, fontSize: 20),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.greenAccent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.person_outlined,
                color: Colors.white,
                size: 35.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: emptytextField,
              )),
          onFieldSubmitted: searchcontrol,
        ),
      ),
    );
  }

  searchcontrol(String userNames) {
    Future<QuerySnapshot> foundSearchedUsers = Firestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userNames)
        .getDocuments();
    setState(() {
      fsearchResults = foundSearchedUsers;
    });
  }

  emptytextField() {
    searchtxteditController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homepageheader(),
      body: fsearchResults == null
          ? displayNoSearchReslts()
          : showSearchResults(),
    );
  }

//problem here
  showSearchResults() {
    return FutureBuilder(
      future: fsearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUserReslz = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResults = UserResult(eachUser);
          if (currentUserId != document["id"]) {
            searchUserReslz.add(userResults);
          }
        });
        return ListView(children: searchUserReslz);
      },
    );
  }

  displayNoSearchReslts() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              LineIcons.search,
              color: Colors.purpleAccent,
              size: 200.0,
            ),
            Text(
              'Search Other Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 50.0,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(4.0),
        child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => userTochat(context),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      backgroundImage:
                          CachedNetworkImageProvider(eachUser.photoUrl),
                    ),
                    title: Text(
                      eachUser.nickname,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Joined:" +
                          // DateFormat("dd MMMM, yyyy - hh:mm:aa")
                          DateFormat("dd MMMM, yyyy ").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  (int.parse(eachUser.createdAt)))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              ],
            )));
  }

  userTochat(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                takerId: eachUser.id,
                takerAvatar: eachUser.photoUrl,
                takerName: eachUser.nickname)));
  }
}
