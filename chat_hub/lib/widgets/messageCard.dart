import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_hub/api/apis.dart';
import 'package:chat_hub/helper/dateTimeFornat.dart';
import 'package:chat_hub/models/messagesModel.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.currMessage});

  final MessageModel currMessage;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIS.getUser.uid == widget.currMessage.fromId
        ? currentUser()
        : sendingUser();
  }

  // our message
  Widget currentUser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          SizedBox(width: mq.width * 0.02),
          Icon(
            Icons.done_all_rounded,
            color: widget.currMessage.read.isEmpty ? Colors.grey : Colors.blue,
          ),
          SizedBox(width: mq.width * 0.015),
          Text(
            MyDateTime.formatDateTime(
                context: context, time: widget.currMessage.sent),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ]),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.currMessage.type == Type.image
                ? mq.width * .03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFeccaff),
                    Color(0xFFbccbfd),
                  ],
                ),
                border:
                    Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(mq.width * 0.06),
                  topLeft: Radius.circular(mq.width * 0.06),
                  bottomRight: Radius.circular(mq.width * 0.06),
                )),
            child: widget.currMessage.type == Type.text
                ? Text(
                    widget.currMessage.msg,
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: widget.currMessage.msg,
                        placeholder: (context, url) =>
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),),
                  ),
          ),
        ),
      ],
    );
  }

// outhers message
  Widget sendingUser() {
    if (widget.currMessage.read.isEmpty) {
      APIS.updateReadMessage(widget.currMessage);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.currMessage.type == Type.image
                ? mq.width * .03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7F7FD5),
                    Color(0xFFc46df7),
                  ],
                  transform: GradientRotation(180)
                ),
                border:
                    Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(mq.width * 0.06),
                  topRight: Radius.circular(mq.width * 0.06),
                  bottomLeft: Radius.circular(mq.width * 0.06),
                )),
            child: widget.currMessage.type == Type.text
                ? Text(
                    widget.currMessage.msg,
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: widget.currMessage.msg,
                        placeholder: (context, url) =>
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateTime.formatDateTime(
                context: context, time: widget.currMessage.sent),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        )
      ],
    );
  }
}
