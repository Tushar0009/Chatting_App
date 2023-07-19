import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_hub/models/user_firebase_model.dart';
import 'package:chat_hub/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_hub/main.dart';
class ViewUserProfile extends StatefulWidget {
  const ViewUserProfile({super.key, required this.user});

  final UserFireBase user;

  @override
  State<ViewUserProfile> createState() => _ViewUserProfileState();
}

class _ViewUserProfileState extends State<ViewUserProfile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: mq.height * 0.08,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .11),
                child: CachedNetworkImage(
                  width: mq.height * 0.22,
                  height: mq.height * 0.22,
                  fit: BoxFit.fill,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.025,
              ),
              FittedBox(
                child: Center(
                    child: Text(
                  widget.user.name,
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                )),
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.01,
              ),
              FittedBox(
                child: Center(
                    child: Text(
                  widget.user.email,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500),
                )),
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'About: ',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  Text(widget.user.about,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 18)),
                ],
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CharScreen(chatUser: widget.user),)),
                     icon: Icon(Icons.message_rounded,size: mq.height *0.055,),
                      label: Text("Message",style: TextStyle(fontSize: mq.height *0.025),),
                      
                      )
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
