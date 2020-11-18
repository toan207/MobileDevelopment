import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return _MyAppState();
  }
}



class _MyAppState extends State<MyApp>{
  TextEditingController username, password;
  bool isLoggedIn = false;
  Map userProfile;
  final facebookLogin = FacebookLogin();

  bool _obscureText = true;

  String _password;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _loginWithFB() async{
    final result = await facebookLogin.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          isLoggedIn = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => isLoggedIn = false );
        break;
      case FacebookLoginStatus.error:
        setState(() => isLoggedIn = false );
        break;
    }
  }

  _logout(){
    facebookLogin.logOut();
    setState(() {
      isLoggedIn = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: isLoggedIn ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(userProfile["picture"]["data"]["url"],
              height: 50.0, 
              width:50.0
              ),
              Text("Hello " + userProfile["name"]),
              OutlineButton(
                child: Text("Logout"),
                onPressed: () {
                  _logout();
                },
              )
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Welcome to my app!"),
              TextFormField(
                controller: username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  icon: const Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: const Icon(Icons.account_circle_rounded)
                        )
                      ),
                ),
              new TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    icon: const Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: const Icon(Icons.lock)
                      )
                    ),
                  onSaved: (val) => _password = val,
                  obscureText: _obscureText,
                ),
              new FlatButton(
                  onPressed: _toggle,
                  child: new Text(_obscureText ? "Show" : "Hide")
                ),
              OutlineButton(
                child: Text("Login With Account"),
                onPressed: (){}
              ),
              OutlineButton(
                child: Text("Login With Facebook"),
                onPressed: (){
                  _loginWithFB();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}