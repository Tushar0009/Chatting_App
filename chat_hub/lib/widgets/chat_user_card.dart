import 'package:chat_hub/api/apis.dart';
import 'package:chat_hub/helper/dateTimeFornat.dart';
import 'package:chat_hub/models/messagesModel.dart';
import 'package:chat_hub/models/user_firebase_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_hub/screens/chat_screen.dart';
import 'package:chat_hub/widgets/profileDialog.dart';
import 'package:flutter/material.dart';
import 'package:chat_hub/main.dart';

class ChatUsersCart extends StatefulWidget {
  const ChatUsersCart({super.key, required this.userdata});

  final UserFireBase userdata;
  @override
  State<ChatUsersCart> createState() => _ChatUsersCartState();
}

class _ChatUsersCartState extends State<ChatUsersCart> {
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.03, vertical: mq.width * 0.01),
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mq.width * 0.02)),
      child: InkWell(
          onTap: () {
            // navigating to user charscreen
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CharScreen(chatUser: widget.userdata)));
          },
          child: StreamBuilder(
            stream: APIS.getLastMessage(widget.userdata),
            builder: (context, snapshot) {
              // get last message
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                      [];
              if (list.isNotEmpty) _message = list[0];
              return ListTile(
                leading: InkWell(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) =>
                          ProfileDialog(user: widget.userdata)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.03),
                    child: CachedNetworkImage(
                      width: mq.height * 0.06,
                      height: mq.height * 0.06,
                      imageUrl: widget.userdata.image,
                      errorWidget: (context, url, error) =>
                          CircleAvatar(child: Icon(Icons.person)),
                    ),
                  ),
                ),
                title: Text(widget.userdata.name),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? "Image"
                          : _message!.msg
                      : widget.userdata.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIS.getUser.uid
                        ? Container(
                            color: Colors.green.shade400,
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(MyDateTime.getLastMessageDate(
                            context: context, time: _message!.sent)),
              );
            },
          )),
    );
  }
}
