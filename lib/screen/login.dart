import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unknperson/screen/home.dart';
import 'package:unknperson/services/api.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _loadState = false;

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    _verifyLogado();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    username.text = "dornel.fabio2@gmail.com";
    password.text = "mastermaster";

    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
          child: SingleChildScrollView(
              child: new Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Color(0xff3E6FC1),
                  ),
                  child: Container(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Log in',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 42.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "WorkSansBold"),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Container(),
                        ),
                        Container(
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.circular(23),
                            ),
                            width: MediaQuery.of(context).size.width / 1.3,
                            height: MediaQuery.of(context).size.height / 2.0,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.fromLTRB(
                                        25.0, 30.0, 0.0, 10.0),
                                    // decoration: BoxDecoration(color: Colors.red),
                                    child: Text(
                                      'User name',
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff3E6FC1),
                                          fontFamily: "arial"),
                                    ),
                                  ),
                                  Container(
                                    width: 250.0,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return;
                                        }
                                        return null;
                                      },
                                      controller: username,
                                      style: textStyle,
                                      decoration: InputDecoration(
                                          // labelText: 'Chave',
                                          labelStyle: textStyle,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.fromLTRB(
                                        25.0, 30.0, 0.0, 10.0),
                                    // decoration: BoxDecoration(color: Colors.red),
                                    child: Text(
                                      'Password',
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff3E6FC1),
                                          fontFamily: "arial"),
                                    ),
                                  ),
                                  Container(
                                    width: 250.0,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          // return;
                                        }
                                        return null;
                                      },
                                      controller: password,
                                      obscureText: true,
                                      style: textStyle,
                                      decoration: InputDecoration(
                                          labelStyle: textStyle,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 30.0, 0.0, 0.0)),
                                  Container(
                                      width: 250,
                                      height: 80,
                                      child: Center(
                                        child: FlatButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0)),
                                          onPressed: () async {
                                            print(_formKey.currentState
                                                .validate());
                                            if (_formKey.currentState
                                                .validate()) {
                                              _doLogin();
                                            }
                                          },
                                          color: Theme.of(context).primaryColor,
                                          padding: EdgeInsets.all(15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Entrar",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            )),
                      ],
                    )),
                  ))),
          inAsyncCall: _loadState),
    );
  }

  _doLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var conected = await Connectivity().checkConnectivity();

    setState(() {
      _loadState = true;
    });
    
    if (conected != ConnectivityResult.none) {
      Map data = {"email": username.text, "password": password.text};

      var usuario = await Services.getlogin(data);

      print('Usuario logado ${prefs.getBool('statuslogin')}'  );

      if (prefs.getBool('statuslogin')) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        showInSnackBar(context, prefs.getString('msg_login'));
      }
      setState(() {
        _loadState = false;
      });
    }
  }

  void showInSnackBar(BuildContext context, String value) {
    final snackBar = SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      duration: Duration(seconds: 2),
    );
    _scaffoldKey.currentState
        .showSnackBar(snackBar);
  }

  Future<void> _verifyLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('statuslogin')) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }
}