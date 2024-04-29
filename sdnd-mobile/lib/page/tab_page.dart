import 'package:airsafe/page/compte/login_page.dart';
import 'package:airsafe/page/synchronisation.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

import 'file_list.dart';

import 'about.dart';


// Add your imports here

// Add your imports here

class TabPage extends StatefulWidget {

  const TabPage({Key? key}) : super(key: key);

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CustomTab> myTabs = <CustomTab>[];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);

    // Initialize myTabs here after accessing widget.token
    myTabs.addAll([
      CustomTab(
        text: 'Accueil',
        icon: 'images/icon-home.png',
        selectedIcon: 'images/icon-home-selected.png',
        page: HomePage(token: '',),
      ),
      CustomTab(
        text: 'Historique',
        icon: 'images/icon-history.png',
        selectedIcon: 'images/icon-history-selected.png',
        page: ListPDFsScreen(),
      ),
      CustomTab(
        text: 'Paramètres',
        icon: 'images/icon-settings.png',
        selectedIcon: 'images/icon-settings-selected.png',
        page: SynchronizationPage(),
      ),
      CustomTab(
        text: 'À propos',
        icon: 'images/icon-about.png',
        selectedIcon: 'images/icon-about-selected.png',
        page: AboutPage(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: SizedBox(
        height: 83,
        child: TabBar(
          labelColor: Colors.blue,
          controller: _tabController,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          tabs: myTabs.map((CustomTab tab) {
            return Tab(
              child: MyTab(
                tab: tab,
                isSelected: myTabs.indexOf(tab) == selectedIndex,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MyTab extends StatelessWidget {
  final CustomTab tab;
  final bool isSelected;

  const MyTab({Key? key, required this.tab, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          isSelected ? tab.selectedIcon : tab.icon,
          width: 48,
          height: 32,
        ),
        Text(
          tab.text,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }
}

class CustomTab {
  final String text;
  final String icon;
  final String selectedIcon;
  final Widget page;

  CustomTab({
    required this.text,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}
