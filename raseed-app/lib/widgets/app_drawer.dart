import 'package:flutter/material.dart';
import 'package:myapp/pages/receipts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.home),
          //   title: const Text('Home'),
          //   onTap: () {
          //     // TODO: Implement navigation to home
          //     Navigator.pop(context); // Close the drawer
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Receipts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Receipts()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () {
          //     // TODO: Implement navigation to settings
          //     Navigator.pop(context); // Close the drawer
          //   },
          // ),
        ],
      ),
    );
  }
}


