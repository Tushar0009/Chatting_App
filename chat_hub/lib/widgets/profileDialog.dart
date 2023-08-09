import 'package:cached_network_image/cached_network_image.dart';

import '/models/user_firebase_model.dart';
import '/screens/chat_screen.dart';
import '/screens/viewUserProfile.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final UserFireBase user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      content: SizedBox(
        height: mq.height * 0.35,
        width: mq.width * 0.7,
        child: Stack(
          children: [
            Positioned(
              top: mq.height * .001,
              left: mq.width * .01,
              right: mq.width * 0.01,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  height: mq.height * .35,
                  width: mq.width * .7,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                ),
              ),
            ),
            Positioned(
              left: mq.width * 0.01,
              height: mq.height * 0.04,
              width: mq.width * 0.7,
              child: Container(
                decoration: BoxDecoration(
                    // borderRadius:
                        // BorderRadius.only(topLeft: )
                        ),
                color: Colors.black54,
                child: Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
        // Container(
        //   padding: EdgeInsets.only(bottom: 2),
        //   height: mq.height * 0.06,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       IconButton(
        //           onPressed: () {
        //             Navigator.pop(context);
        //              Navigator.of(context).push(MaterialPageRoute(
        //               builder: (context) => CharScreen(chatUser: user,)
        //             ));
        //           },
        //           icon: Icon(
        //             Icons.message,
        //             size: mq.height * 0.04,
        //             color: Color(0xFFc55df6),
        //           )),
        //       IconButton(
        //           onPressed: () {},
        //           icon: Icon(
        //             Icons.call,
        //             size: mq.height * 0.04,
        //             color: Color(0xFFc55df6),
        //           )),
        //       IconButton(
        //           onPressed: () {
        //             Navigator.pop(context);
        //              Navigator.of(context).push(MaterialPageRoute(
        //               builder: (context) => ViewUserProfile(user: user),
        //             ));
        //           },
        //           icon: Icon(Icons.info_outline,
        //               size: mq.height * 0.04, color: Color(0xFFc55df6)))
        //     ],
        //   ),
        // )
      ),
    );
  }
}
