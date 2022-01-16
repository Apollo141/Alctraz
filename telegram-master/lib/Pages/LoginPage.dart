import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Alctraaz/Pages/HomePage.dart';
import 'package:Alctraaz/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googlesignin = GoogleSignIn();
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  SharedPreferences prefernese;
  bool isloading = false;
  bool islogin = false;
  FirebaseUser currentuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    issignedin();
  }

  void issignedin() async {
    this.setState(() {
      islogin = true;
    });
    prefernese = await SharedPreferences.getInstance();
    islogin = await googlesignin.isSignedIn();
    if (islogin) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: prefernese.getString("id"))));
    }
    this.setState(() {
      isloading = false;
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
                colors: [
              Colors.lightBlueAccent,
              Colors.redAccent,
              Colors.purpleAccent,
              Colors.amberAccent
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Design And Implement ",
              style: TextStyle(
                  fontSize: 50.0, color: Colors.white, fontFamily: "Signatra"),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),

            ),
            Text(
              "Chating System",
              style: TextStyle(
                  fontSize: 50.0, color: Colors.white, fontFamily: "Signatra"),
            ),

            Text(
              "By Using : (Alctraz)",
              style: TextStyle(
                  fontSize: 50.0, color: Colors.white, fontFamily: "Signatra"),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),

            ),
            Text(
              "Prepared By : Abd Alhameed Yousif ",
              style: TextStyle(
                  fontSize: 30.0, color: Colors.black, fontFamily: "Signatra"),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),

            ),
            Text(
              "Supervisor : Assist. Prof. Imad matti bakko",
              style: TextStyle(
                  fontSize: 30.0, color: Colors.black, fontFamily: "Signatra"),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),

            ),
            GestureDetector(
                onTap: controlsignin,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        width: 265.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/google_signin_button.png"),
                              fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: isloading ? circularProgress() : Container(),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Future<Null> controlsignin() async {
    prefernese = await SharedPreferences.getInstance();
    this.setState(() {
      isloading = true;
    });
    GoogleSignInAccount googleuser = await googlesignin.signIn();
    GoogleSignInAuthentication googleauthintiction =
        await googleuser.authentication;
    final AuthCredential credntial = GoogleAuthProvider.getCredential(
        idToken: googleauthintiction.idToken,
        accessToken: googleauthintiction.accessToken);
    FirebaseUser firebaseuser =
        (await firebaseauth.signInWithCredential(credntial)).user;

    if (firebaseuser != null) {
      final QuerySnapshot querysresult = await Firestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseuser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documentsnapchat = querysresult.documents;
      if (documentsnapchat.length == 0) {
        Firestore.instance
            .collection("users")
            .document(firebaseuser.uid)
            .setData({
          "nickname": firebaseuser.displayName,
          "photoUrl": firebaseuser.photoUrl,
          "id": firebaseuser.uid,
          "aboutMe": "im using Alctraz",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });
        currentuser = firebaseuser;
        await prefernese.setString("id", currentuser.uid);
        await prefernese.setString("nickname", currentuser.displayName);
        await prefernese.setString("photoUrl", currentuser.photoUrl);
      } else {
        currentuser = firebaseuser;
        await prefernese.setString("id", documentsnapchat[0]["id"]);
        await prefernese.setString("nickname", documentsnapchat[0]["nickname"]);
        await prefernese.setString("photoUrl", documentsnapchat[0]["photoUrl"]);
        await prefernese.setString("aboutMe", documentsnapchat[0]["aboutMe"]);
      }
      Fluttertoast.showToast(msg: "Good To Go! , SignIn Successful!");
      this.setState(() {
        isloading = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: firebaseuser.uid)));
    } else {
      Fluttertoast.showToast(msg: "Try Again , SignIn Faliled!");
      this.setState(() {
        isloading = false;
      });
    }
  }

}
