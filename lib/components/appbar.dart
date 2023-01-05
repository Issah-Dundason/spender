import 'package:flutter/material.dart';
import 'package:spender/pages/profile_page.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AppProfile()));
            },
            icon: const Icon(Icons.person),
          ),
          const Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(200);
}
