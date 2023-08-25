// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '/api/apis.dart';
import '/helper/dateTimeFornat.dart';
import '/models/user_firebase_model.dart';
import '/screens/viewUserProfile.dart';
import '/widgets/messageCard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/messagesModel.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class CharScreen extends StatefulWidget {
  const CharScreen({super.key, required this.chatUser});

  final UserFireBase chatUser;

  @override
  State<CharScreen> createState() => _CharScreenState();
}

class _CharScreenState extends State<CharScreen> {
  List<MessageModel> _list = [];
  bool _emojiFunction = false, _imageUploding = false;
  // handeling messages
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final _isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child:
          //  SafeArea(
          WillPopScope(
        onWillPop: () {
          // to hide emoji tab on using back button
          if (_emojiFunction) {
            setState(() {
              _emojiFunction = !_emojiFunction;
            });
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: _customAppBar(),
            // toolbarHeight: mq.height * 0.1,
          ),
          backgroundColor: Color(0xFFebd9fc),
          body: Column(children: [
            Expanded(
              child: StreamBuilder(
                stream: APIS.getAllMessages(widget.chatUser),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => MessageModel.fromJson(e.data()))
                              .toList() ??
                          [];

                      return _list.isNotEmpty
                          ? ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height *
                                      0.01),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  currMessage: _list[index],
                                );
                              },
                            )
                          : Center(
                              child: SizedBox(),
                            );
                  }
                },
              ),
            ),

            // loading multiple images
            if (_imageUploding)
              const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))),

            //***************//
            _chatInput(_isKeyboard),

            // emoji picker
            if (_emojiFunction == true)
              SizedBox(
                height: mq.height * .35,
                child: EmojiPicker(
                  textEditingController: _textController,
                  config: Config(
                    columns: 8,
                    bgColor: Color(0xFFd8f3dc),
                    emojiSizeMax: 28 * (Platform.isAndroid ? 1.28 : 1.0),
                  ),
                ),
              )
          ]),
        ),
      ),

      // ),
    );
  }

  Widget _customAppBar() {
    return Container(
      height: mq.height * 7,
      padding: EdgeInsets.only(top: mq.height * 0.04),
      decoration: const BoxDecoration(
        color: Color(0xFFd689ff),
      ),
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ViewUserProfile(user: widget.chatUser),
            ));
          },
          child: StreamBuilder(
            stream: APIS.getUserInfo(widget.chatUser),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => UserFireBase.fromJson(e.data())).toList() ??
                      [];
              return Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),

                  // adding image in appbar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.03),
                    child: CachedNetworkImage(
                      width: mq.height * 0.05,
                      height: mq.height * 0.05,
                      imageUrl: list.isNotEmpty
                          ? list[0].image
                          : widget.chatUser.image,
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(child: Icon(Icons.person)),
                    ),
                  ),
                  SizedBox(
                    width: mq.width * 0.03,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.chatUser.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateTime.getLastActiveTime(
                                    context: context,
                                    lastActiveTime: list[0].lastActive)
                            : MyDateTime.getLastActiveTime(
                                context: context,
                                lastActiveTime: widget.chatUser.lastActive,
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          )),
    );
  }

  Widget _chatInput(bool check) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: check || _emojiFunction ? mq.height * 0.01 : mq.height * 0.05,
          left: mq.width * 0.02,
          right: mq.width * 0.02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _emojiFunction = !_emojiFunction);
                      },
                      icon: const Icon(
                        Icons.emoji_emotions_sharp,
                        color: Color(0xFFb66ee8),
                        size: 26,
                      )),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      onTap: () {
                        if (_emojiFunction)
                          setState(() => _emojiFunction = !_emojiFunction);
                      },
                      decoration: const InputDecoration(
                          hintText: "Type Something....",
                          hintStyle: TextStyle(color: Color(0xFFb66ee8)),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        for (var it in images) {
                          setState(() => _imageUploding = true);
                          await APIS.sendImageChat(
                              widget.chatUser, File(it.path));
                          setState(() => _imageUploding = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Color(0xFFb66ee8),
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);

                        if (image != null) {
                          await APIS.sendImageChat(
                              widget.chatUser, File(image.path));
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFb66ee8),
                        size: 26,
                      )),
                  SizedBox(
                    width: mq.width * 0.02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty)
                  APIS.sendFirstMessage(
                      widget.chatUser, _textController.text, Type.text);
                else {
                  APIS.sendMessage(
                      widget.chatUser, _textController.text, Type.text);
                  _textController.clear();
                }
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(left: 10, right: 5, bottom: 8, top: 8),
            color: Color(0xFF8b2fc9),
            shape: const CircleBorder(),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
