import 'package:app_pe_diabetico/pages_inside/explore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:app_pe_diabetico/pages_inside/galery.dart';
import 'package:app_pe_diabetico/pages_inside/initial_page.dart';
import 'package:app_pe_diabetico/pages_inside/profile.dart';


// Trata de fazer a navbar no fundo e mudar as paginas
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    //Home(),
    //ExplorePage(),
    InitialPage(),
    Explore(),
    Galery(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
        
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF2A3A3A).withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: GNav(
              backgroundColor: Colors.transparent,
              color: Colors.white,
              activeColor: Colors.white,
              gap: 8,
              haptic: true,
              padding: EdgeInsets.all(15),
              selectedIndex: _selectedIndex, // Mantém a seleção correta
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: [
                GButton(icon: _selectedIndex == 0 ? Icons.home : Icons.home_outlined, iconSize: 25),
                GButton(icon: _selectedIndex == 1 ? Icons.explore : Icons.explore_outlined, iconSize: 25),
                GButton(icon: _selectedIndex == 2 ? Icons.photo_library : Icons.photo_library_outlined, iconSize: 25),
                GButton(icon: _selectedIndex == 3 ? Icons.person_2 : Icons.person_2_outlined, iconSize: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
