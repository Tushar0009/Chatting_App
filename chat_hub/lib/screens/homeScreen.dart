import '/api/apis.dart';
import '/models/user_firebase_model.dart';
import '/screens/user_profile.dart';
import '/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_hub/main.dart';
import 'package:chat_hub/helper/dialogs.dart';

enum SampleItem { itemOne, itemTwo }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserFireBase> _list = [];
  // storing scearched items
  final List<UserFireBase> _searchList = [];
  //for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIS.currentUserInfo();

    //now it work according to user lifestyle
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIS.auth.currentUser != null) {
        if (message.toString().contains("resume"))
          APIS.updateOnlineStatus(true); // active / online
        if (message.toString().contains("pause"))
          APIS.updateOnlineStatus(false); //last online
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  onPressed: () => {_addCharUser()},
                  child: Icon(Icons.person_add_alt_1_sharp),
                )),
            appBar: AppBar(
              // backgroundColor : Theme.of(context).appBarTheme.backgroundColor,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFd689ff),
                ),
              ),
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        label: Text("Username , Email ....."),
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                      style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                      onChanged: (Value) {
                        _searchList.clear();

                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(Value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(Value.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Text(
                      'ChatHub',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22),
                    ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(
                      _isSearching ? Icons.cancel_outlined : Icons.search,
                      color: Colors.white,
                    )),
                PopupMenuButton<SampleItem>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (SampleItem value) {
                    setState(() {
                      if (value == SampleItem.itemOne)
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(user: APIS.currUser),
                        ));
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('Profile'),
                    ),
                  ],
                ),
              ],
            ),
            body: StreamBuilder(
              stream: APIS.getAllFriend(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: APIS.getAllUSers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??
                                []),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
  
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) =>
                                          UserFireBase.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _list.length,
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.01),
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUsersCart(
                                        userdata: _isSearching
                                            ? _searchList[index]
                                            : _list[index]);
                                  },
                                );
                              } 
                              else {
                                return const Center(child: Text("No User Found"),);
                              }
                          }
                        });
                }
              },
            )),
      ),
    );
  }

  void _addCharUser() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.person, color: Colors.purple),
                  SizedBox(
                    width: mq.width * 0.03,
                  ),
                  Text("Add User"),
                ],
              ),
              content: TextFormField(
                keyboardType: TextInputType.streetAddress,
                maxLines: null,
                onChanged: (val) => email = val,
                decoration: InputDecoration(
                    hintText: "User Email Address",
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.purple,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    print("Email send $email");
                    if (email.isNotEmpty) {
                      await APIS.addUser(email).then((value) {
                        if (value == false) {
                          Dialogs.showSnakBar(context, "User does not exist");
                        }
                      });
                    }
                  },
                  child: Text('Add'),
                )
              ],
            ));
  }
}
