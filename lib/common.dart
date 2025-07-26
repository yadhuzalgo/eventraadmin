import 'package:flutter/material.dart';
import 'package:projectflutteradmin/eventdetails.dart';
import 'package:projectflutteradmin/main.dart';
import 'package:projectflutteradmin/update.dart';
import 'package:projectflutteradmin/userdetails.dart';

class Com extends StatefulWidget {
  const Com({super.key});

  @override
  State<Com> createState() => _ComState();
}

class _ComState extends State<Com> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    Usds(),
    AdminPage(),
    Upd(),
    Evd(),
  ];

  final List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "User Info"),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: "Update"),
    BottomNavigationBarItem(icon: Icon(Icons.description), label: "Details"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: screens[selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            items: navItems,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
