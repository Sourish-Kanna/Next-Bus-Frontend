import 'package:flutter/material.dart';

import 'package:nextbus/Pages/home_page.dart';
import 'package:nextbus/Pages/view_entries.dart';


class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: TabBarExample()
    );
  }
}

class TabBarExample extends StatelessWidget {
  const TabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar Sample'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.cloud_outlined)),
              Tab(icon: Icon(Icons.beach_access_sharp)),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            BusHomePage(),
            EntriesPage(),
          ],
        ),
      ),
    );
  }
}
