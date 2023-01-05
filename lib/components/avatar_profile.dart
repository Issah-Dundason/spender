import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AvatarProfile extends StatelessWidget {
  final String assetName;

  const AvatarProfile(
      {Key? key,
      required this.avatarHeight,
      required this.avatarWidth,
      required this.backColor,
        required this.assetName})
      : super(key: key);
  final double avatarHeight;
  final double avatarWidth;
  final Color backColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: avatarWidth,
      height: avatarHeight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: SvgPicture.asset('assets/images/avatar/$assetName'),
    );
  }
}
