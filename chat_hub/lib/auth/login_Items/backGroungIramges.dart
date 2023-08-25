import 'package:flutter/material.dart';

class BackGroundImage extends StatelessWidget {
  const BackGroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/background2.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken))),
      
    );
  }
}
