import 'package:flutter/material.dart';
import 'package:spender/components/profile_page.dart';
import 'package:spender/theme/theme.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AppProfile()));
            },
            icon: Icon(Icons.person),
          ),
          Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(200);
}
