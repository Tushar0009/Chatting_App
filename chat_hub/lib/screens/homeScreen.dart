import '/api/apis.dart';
import '/models/user_firebase_model.dart';
import '/screens/user_profile.dart';
import '/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SampleItem { itemOne, itemTwo }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserFireBase> list = [];
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
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                   color: Color(0xFFc55df6),
              ),
              ),
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color : Colors.white),
                        label: Text("Username , Email ....."),
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                      style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                      onChanged: (Value) {
                        _searchList.clear();

                        for (var i in list) {
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
                          fontWeight: FontWeight.bold, color: Colors.white , fontSize: 22),
                    ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(
                        _isSearching ? Icons.cancel_outlined : Icons.search , color: Colors.white,)),
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
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('Setting'),
                    ),
                  ],
                ),
              ],
            ),
            body: StreamBuilder(
              stream: APIS.getAllUSers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    list = data
                            ?.map((e) => UserFireBase.fromJson(e.data()))
                            .toList() ??
                        [];
                    if (list.isNotEmpty) {
                      return ListView.builder(
                        itemCount:
                            _isSearching ? _searchList.length : list.length,
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUsersCart(
                              userdata: _isSearching
                                  ? _searchList[index]
                                  : list[index]);
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No Chat Found!",
                            style: TextStyle(fontSize: 20)),
                      );
                    }
                }
              },
            )),
      ),
    );
  }
}
