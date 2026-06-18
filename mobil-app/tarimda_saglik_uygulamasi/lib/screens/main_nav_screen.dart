import 'package:flutter/material.dart';
// Sayfalarımızı buraya import ediyoruz:
import 'home_screen.dart';
import 'task_add_screen.dart';
import 'task_list_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  // Import ettiğimiz sayfaları listeye ekliyoruz
  final List<Widget> _pages = const [
    HomeScreen(),
    TaskAddScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.linked_camera_outlined), label: 'Hastalık Tespit'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_sharp), label: 'İş Kayıt Ekleme'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'İş Kayıtları'),
        ],
      ),
    );
  }
}