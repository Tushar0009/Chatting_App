import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_hub/auth/loginScreen.dart';
import 'package:chat_hub/models/user_firebase_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_hub/main.dart';
import 'package:chat_hub/api/apis.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_hub/helper/dialogs.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final UserFireBase user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formey = GlobalKey<FormState>();
  String? _pickedImage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor : Theme.of(context).appBarTheme.backgroundColor,
          title: const Text(
            "Profile",
            style: TextStyle(
                fontWeight: FontWeight.bold,  fontSize: 26 , color: Colors.white),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              Dialogs.onProgress(context);
              await APIS.updateOnlineStatus(false);
              await APIS.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //to pop profile screen
                  Navigator.of(context).pop();
                  // to Pop home Screen
                  Navigator.of(context).pop();

                  APIS.auth = FirebaseAuth.instance;

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              });
            },
            icon: Icon(
              color : Colors.white,
              Icons.logout,
            ),
            label: const Text("Log Out" , style: TextStyle(color : Colors.white),),
          ),
        ),
        body: Form(
          key: _formey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.04,
                  ),
                  Stack(children: [
                    _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(
                              File(_pickedImage!),
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.fill,
                            ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: CachedNetworkImage(
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.fill,
                              imageUrl: widget.user.image,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(child: Icon(Icons.person)),
                            ),
                          ),
                    Positioned(
                        bottom: 0,
                        right: -10,
                        child: MaterialButton(
                          elevation: 2,
                          shape: CircleBorder(),
                          color: Colors.white,
                          onPressed: _showBottomSheet,
                          child: Icon(
                            CupertinoIcons.photo_camera_solid,
                            color: Color(0XFFa100f2),
                            size: 25,
                          ),
                        )),
                  ]),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  FittedBox(
                    child: Center(
                        child: Text(
                      widget.user.email,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    )),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.04,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) return null;
                      return 'Required Feild';
                    },
                    onSaved: (newValue) => APIS.currUser.name = newValue!,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0XFFa100f2),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      label: const Text("Username"),
                    ),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) return null;
                      return 'Required Feild';
                    },
                    onSaved: (newValue) => APIS.currUser.about = newValue!,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.info_outline,
                        color: Color(0XFFa100f2),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      hintText: widget.user.about,
                      label: const Text("About"),
                    ),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFFa100f2),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(mq.width * 0.04)),
                        minimumSize: Size(mq.width * 0.27, mq.height * 0.06)),
                    label: const Text(
                      "Save",
                      style: TextStyle(fontSize: 18 , color: Colors.white) ,
                    ),
                    icon: const Icon(Icons.edit , color: Colors.white,),
                    onPressed: () {
                      if (_formey.currentState!.validate()) {
                        _formey.currentState!.save();
                        APIS.updateUserInfo().then((value) {
                          Dialogs.showSnakBar(
                              context, "Information Updated Sucessfully");
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(
                top: mq.height * 0.04, bottom: mq.height * 0.04),
            shrinkWrap: true,
            children: [
              const Text(
                "Choose Image Source",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                          backgroundColor: Colors.white,
                          shape: const CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          print("new Image" + image.path);
                          setState(() {
                            _pickedImage = image.path;
                          });
                          APIS.updateProfilePhoto(File(_pickedImage!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("images/camera.png")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                          backgroundColor: Colors.white,
                          shape: const CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          print("new Image" + image.path);
                          setState(() {
                            _pickedImage = image.path;
                          });
                          APIS.updateProfilePhoto(File(_pickedImage!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("images/picture.png"))
                ],
              )
            ],
          );
        });
  }
}