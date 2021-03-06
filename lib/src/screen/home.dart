import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unknperson/models/Fakeperson.dart';
import 'package:unknperson/src/screen/fakeperson-form.dart';
import 'package:unknperson/src/screen/login.dart';
import 'package:unknperson/services/api.dart';
import 'package:unknperson/utils/formatters.dart';
import 'package:unknperson/utils/unicorndial.dart';
import 'package:unknperson/src/widget/sidebar/sidebar.dart';

import '../../models/Fakeperson.dart';
import '../../models/FakepersonFields.dart';
import '../../services/api.dart';

// https://medium.com/@gadepalliaditya1998/item-selection-in-list-view-on-tap-in-flutter-using-listview-builder-612f6608505a
class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name;
  String email;
  String url_api;
  bool _loadState = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FakepersonFields fakepersonFields = FakepersonFields();
  List<Fakeperson> fakepersonList;
  ScrollController _scrollController;
  List dadaTodelete = [];
  int countlist = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _updatepersonListview();
    _getuserinformation();
  }

  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Mulher",
        currentButton: new FloatingActionButton(
          heroTag: "addgirl",
          backgroundColor: Theme.of(context).primaryColor,
          mini: true,
          child: Icon(Icons.local_library),
          onPressed: () {
            navigateToAddperson('F');
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Homen",
        currentButton: new FloatingActionButton(
          heroTag: "Searchmedidor",
          backgroundColor: Theme.of(context).primaryColor,
          mini: true,
          child: Icon(Icons.person),
          onPressed: () {
            navigateToAddperson('M');
          },
        )));

    return WillPopScope(
        onWillPop: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (prefs.getBool('statuslogin')) {
            Future.value(false);
          }
        },
        child: ModalProgressHUD(
            child: Scaffold(
                key: _scaffoldKey,
                floatingActionButton: Visibility(
                    // visible: true,
                    child: UnicornDialer(
                        orientation: UnicornOrientation.VERTICAL,
                        parentButtonBackground: Theme.of(context).primaryColor,
                        parentButton: Icon(Icons.add, color: Color(0xFFfc5185)),
                        childButtons: childButtons)),
                appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    actions: dadaTodelete.length > 0
                        ? <Widget>[
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () async {
                                setState(() {
                                  _loadState = true;
                                });
                                await Services.getbulkdeleteperson(
                                    dadaTodelete);
                                dadaTodelete = [];
                                _updatepersonListview();
                              },
                            )
                          ]
                        : null),
                drawer: Sidebar(username: this.name, email: this.email),
                body: Scrollbar(child: getHomeListView())),
            inAsyncCall: _loadState)
          );
  }

  void showNotImplementedMessage() {
    Navigator.pop(context); // Dismiss the drawer.
    _scaffoldKey.currentState.showSnackBar(const SnackBar(
      content: Text("The drawer's items don't do anything"),
    ));
  }

  void _getuserinformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.name = prefs.getString('fullname');
      this.email = prefs.getString('email');
    });
  }

  Future<void> _updatepersonListview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      this.url_api = prefs.getString('url_api');
      _loadState = true;
    });

    if (prefs.getBool('statuslogin')) {
      Future<List<Fakeperson>> fakepersonList = Services.getPersonFromapi();
      fakepersonList.then((result) {
        setState(() {
          this.fakepersonList = result;
          this.countlist = result.length;
          _loadState = false;
        });
      });
    } else {
      setState(() {
        _loadState = false;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  Future<String> _showDialogDeletedMSG(int pk) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deseja excluir este registro ?"),
            actions: <Widget>[
              FlatButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Não",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context); // volta para a tela
                },
              ),
              FlatButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Sim",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  setState(() {
                    _loadState = true;
                  });
                  Navigator.pop(context);
                  await Services.getdeleteperson(pk);
                  _updatepersonListview();
                },
              )
            ],
          );
        });
  }

  Widget getHomeListView() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ListView.builder(
          itemCount: countlist,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int position) {
            return InkWell(
                onTap: () async {
                  if (dadaTodelete.length == 0) {
                    bool result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FakepersonformScreen(
                                  fakeperson: fakepersonList[position],
                                )));
                    _updatepersonListview();
                    if (result == true) {/*Faca alima coisa*/}
                  } else {
                    if (fakepersonList[position].isSelected == null) {
                      setState(() {
                        fakepersonList[position].isSelected = true;
                        dadaTodelete.add(fakepersonList[position].pk);
                        dadaTodelete = dadaTodelete.toSet().toList();
                      });
                    } else {
                      setState(() {
                        fakepersonList[position].isSelected =
                            !fakepersonList[position].isSelected;
                        if (fakepersonList[position].isSelected) {
                          dadaTodelete.add(fakepersonList[position].pk);
                          dadaTodelete = dadaTodelete.toSet().toList();
                        } else {
                          dadaTodelete.remove(fakepersonList[position].pk);
                          dadaTodelete = dadaTodelete.toSet().toList();
                        }
                      });
                    }
                  }
                },
                onLongPress: () {
                  setState(() {
                    fakepersonList[position].isSelected = true;
                    dadaTodelete.add(fakepersonList[position].pk);
                    dadaTodelete = dadaTodelete.toSet().toList();
                  });
                },
                child: Container(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: _cardListpendentes(context, position),
                )));
          },
        ));
  }

  void navigateToAddperson(String type) async {
    setState(() {
      _loadState = true;
    });
    bool result;
    var fakepersonfield = await Services.getnewFakeperson(type);
    setState(() {
      _loadState = true;
    });
    if (fakepersonfield != null) {
      result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FakepersonformScreen(
          fakeperson: Fakeperson(
              model: 'fakeperson.fakeperson',
              fakepersonfields: fakepersonfield),
        );
      }));
    } else {
      result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FakepersonformScreen(
          fakeperson: Fakeperson(
              model: 'fakeperson.fakeperson',
              fakepersonfields: fakepersonFields),
        );
      }));
    }

    _updatepersonListview();
    if (result == true) {}
  }

  Widget _cardListpendentes(BuildContext context, int position) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 15.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black38,
            // color: Colors.red[100],
            width: 0.4,
          ),
        ),
      ),
      child: Container(
          // color: Colors.red[100],
          
          decoration: BoxDecoration(
            color: fakepersonList[position].isSelected != null &&
                  fakepersonList[position].isSelected
              ? Colors.red[100]
              : Colors.white,
            borderRadius: new BorderRadius.circular(7),
          ),
          padding: const EdgeInsets.all(0.0),
          child: SizedBox(
            height: (MediaQuery.of(context).size.height / (8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl:
                      "https://render.imoalert.com.br/600x320/jpg/https://fakeperson.cloudf.com.br${fakepersonList[position].fakepersonfields.fpImage}",
                  imageBuilder: (context, imageProvider) => Container(
                    width: (MediaQuery.of(context).size.width / (4.3)),
                    height: (MediaQuery.of(context).size.width / (4.2)),
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(7),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: (MediaQuery.of(context).size.width / (4.3)),
                    height: (MediaQuery.of(context).size.width / (4.2)),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: (MediaQuery.of(context).size.width / (4.3)),
                    height: (MediaQuery.of(context).size.width / (4.2)),
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(7),
                        image: DecorationImage(
                            image: AssetImage('lib/assets/images/noImage.jpg'),
                            fit: BoxFit.cover)),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AutoSizeText(
                                  fakepersonList[position]
                                      .fakepersonfields
                                      .fpFullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 2.0)),
                                AutoSizeText(
                                  fakepersonList[position]
                                      .fakepersonfields
                                      .fpEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 2.0)),
                                AutoSizeText(
                                  Formatters.formatCPF(fakepersonList[position]
                                      .fakepersonfields
                                      .fpCpf),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Icon(
                                          Icons.date_range,
                                          size: 12.0,
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      AutoSizeText(
                                        Formatters.formatDateString(
                                            fakepersonList[position]
                                                .fakepersonfields
                                                .fpBirthDate),
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                        onTap: () async {
                          _showDialogDeletedMSG(fakepersonList[position].pk);
                        },
                        child: Center(
                          child: Icon(Icons.close,
                              size: 28.0, color: Color(0xFFfc5185)),
                        ))),
              ],
            ),
          )),
    );
  }

//   Future<bool> _exitApp(BuildContext context) {
//   return showDialog(
//         context: context,
//         child: new AlertDialog(
//           title: new Text('Do you want to exit this application?'),
//           // content: new Text('We hate to see you leave...'),
//           actions: <Widget>[
//             new FlatButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: new Text('No'),
//             ),
//             new FlatButton(
//               onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen())),
//               child: new Text('Yes'),
//             ),
//           ],
//         ),
//       ) ??
//       false;
// }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // _updatepersonListview();
      print("reach the bottom");
    }
    if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        // _buttonVisible = true;
      });
    }
  }
}
