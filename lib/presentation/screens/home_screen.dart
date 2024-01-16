import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:undefind_project/presentation/screens/phone_book_screen.dart';
import 'package:undefind_project/presentation/screens/trash_map_screen.dart';

import '../view_models/trash_map_view_model.dart';
import 'navi_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  final _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        allowImplicitScrolling: true,

        children: <Widget>[
          PhoneBookScreen(),
          TrashMapScreen(),
          NaviMapScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: '담당자 찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '경로 찾기'),
        ],
      ),
    );
  }
}
