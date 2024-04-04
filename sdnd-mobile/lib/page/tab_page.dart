import 'package:airsafe/page/compte/login_page.dart';
import 'package:airsafe/page/synchronisation.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

import 'history_page.dart';

import 'about.dart';


class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CustomTab> myTabs = <CustomTab>[
    CustomTab(
        text: 'Home',
        icon: 'images/icon-home-gray.png',
        selectedIcon: 'images/icon-home-orange.png'),
    CustomTab(
        text: 'Scan History',
        icon: 'images/icon-history-gray.png',
        selectedIcon: 'images/icon-history-orange.png'),

    CustomTab(
        text: 'Compte', // Renommer l'onglet pour le bouton de compte
        icon: 'images/compte.png',
        selectedIcon: 'images/compte.png'),
    CustomTab(
        text: 'Paramètres', // Ajouter un nouvel onglet pour les paramètres
        icon: 'images/param.png',
        selectedIcon: 'images/param.png'),
    CustomTab(
        text: 'About',
        icon: 'images/icon-about-gray.png',
        selectedIcon: 'images/icon-about-orange.png'),
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length); // Mettre à jour la longueur du contrôleur de tabulation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          HomePage(),
          ListPdfPage(),
          LoginPage(),
          SynchronizationPage(),
          AboutPage(),
        ],
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
            return MyTab(
              tab: tab,
              isSelected: myTabs.indexOf(tab) == selectedIndex,
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

  const MyTab({super.key, required this.tab, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            isSelected ? tab.selectedIcon : tab.icon,
            width: 48,
            height: 32,
          ),

        ],
      ),
    );
  }
}

class CustomTab {
  final String text;
  final String icon;
  final String selectedIcon;

  CustomTab(
      {required this.text, required this.icon, required this.selectedIcon});
}