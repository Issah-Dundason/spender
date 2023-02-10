import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spender/pages/profile_page.dart';

class TopBar {
  static AppBar getAppBar(
          BuildContext context, String text, String assetName, Function() func) =>
      AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // <-- SEE HERE
        ),
        leading: GestureDetector(
          onTap: func,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15)),
              child: SvgPicture.asset('assets/images/avatar/$assetName'),
            ),
          ),
        ),
        title: Text(
          text,
        ),
        foregroundColor: Colors.black,
      );

  static Route createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, anim, anim2) => const AppProfile(),
    transitionsBuilder: (context, anim, anim2, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = anim.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
          child: child);
    });
  }
}
