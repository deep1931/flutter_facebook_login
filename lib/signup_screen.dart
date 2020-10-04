import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoggedIn = false;
  bool gone = false;
  String name, email, imageUrl;

  bool isLoading = true;
  var facebookLogin = FacebookLogin();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !isLoggedIn
                ? Container(
                    margin: EdgeInsets.only(left: 40, right: 40),
                    height: 100,
                    child: facebookButton(onTap: () {
                      _initiateFacebookLogin();
                    }),
                  )
                : Container(),
            isLoggedIn
                ? ListTile(
                    leading: CircleAvatar(
                      backgroundImage: Image.network(imageUrl).image,
                    ),
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: InkWell(
                      onTap: () {
                        _logout();
                      },
                      child: Text('Logout'),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget facebookButton({Function onTap}) {
    return InkWell(
      onTap: () {

        onTap();
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff1959a9),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      topLeft: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('f',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff2872ba),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('Log in with Facebook',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _initiateFacebookLogin() async {
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        _onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        _onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);

        _callLoginAction(profile['name'], profile['email'],
            profile['picture']['data']['url'], 'empty', 1);
        _onLoginStatusChanged(true);

        break;
    }
  }

  _onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  _callLoginAction(String name, String email, String photo, String fcmToken,
      int registerVia) async {
    setState(() {
      isLoading = true;
      this.email = email;
      this.name = name;
      this.imageUrl = photo;
    });
  }

  _logout() {
    facebookLogin.logOut();
    setState(() {
      isLoggedIn = false;
    });
  }
}
