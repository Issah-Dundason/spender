import 'package:flutter/material.dart';

import 'avatar_profile.dart';

class AvatarChanger extends StatelessWidget {
  const AvatarChanger({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AvatarProfile(
          avatarWidth: 70,
          avatarHeight: 70,
          backColor: Colors.blueAccent,
        ),
        const SizedBox(width: 15),
        Column(
          children: [
            const Divider(),
            SizedBox(
              height: 50,
              width: 270,
              child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) =>
                      const AvatarProfile(
                          avatarHeight: 50,
                          avatarWidth: 50,
                          backColor: Colors.deepOrangeAccent),
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 10),
                  itemCount: 20),
            ),
            const Divider(),
          ],
        ),
      ],
    );
  }
}
