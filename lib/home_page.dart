import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final List<Widget> pages;

  const HomePage(this.pages, {super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Buckets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Months',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
