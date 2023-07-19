import 'package:chat_hub/models/user_firebase_model.dart';
import 'package:chat_hub/screens/chat_screen.dart';
import 'package:chat_hub/screens/viewUserProfile.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final UserFireBase user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      elevation: 0,
      content: SizedBox(
        height: mq.height * 0.38,
        width: mq.width * 0.7,
        child: Column(children: [
          Stack(
            children: [
              Image.network(
                user.image,
                filterQuality: FilterQuality.high,
                height: mq.height * 0.32,
                width: mq.width * 0.7,
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black45,
                padding: EdgeInsets.only(top: 2, left: 7),
                height: mq.height * 0.035,
                width: mq.width * 0.7,
                child: Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(bottom: 4),
            height: mq.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                       Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CharScreen(chatUser: user,)
                      ));
                    },
                    icon: Icon(
                      Icons.message,
                      size: mq.height * 0.04,
                      color: Color(0xFFc55df6),
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.call,
                      size: mq.height * 0.04,
                      color: Color(0xFFc55df6),
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                       Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ViewUserProfile(user: user),
                      ));
                    },
                    icon: Icon(Icons.info_outline,
                        size: mq.height * 0.04, color: Color(0xFFc55df6)))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
