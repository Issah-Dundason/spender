import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spender/pages/profile_page.dart';

class TopBar {
  static AppBar getAppBar(BuildContext context, String text) => AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AppProfile()));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15)),
              child: SvgPicture.asset('assets/images/avatar/035-man.svg'),
            ),
          ),
        ),
        title: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      );
}
