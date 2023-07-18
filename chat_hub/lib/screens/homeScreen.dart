import 'package:chat_hub/api/apis.dart';
import 'package:chat_hub/models/user_firebase_model.dart';
import 'package:chat_hub/screens/user_profile.dart';
import 'package:chat_hub/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';

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
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                 decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFF31B7C2),
        Color(0xFF7BC393),
        Color(0xFF91EAE4),
        Color(0xFF7F7FD5),
      ],
      transform: GradientRotation(180)
      )
      ),
              ),
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
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
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(
                        _isSearching ? Icons.cancel_outlined : Icons.search)),
                PopupMenuButton<SampleItem>(
                  color: Colors.white,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
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
