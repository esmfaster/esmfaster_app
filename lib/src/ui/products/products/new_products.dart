import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppBar with Tabs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('AppBar with Tabs'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Search'),
              Tab(text: 'Notifications'),
              Tab(text: 'Home'),
              Tab(text: 'Search'),
              Tab(text: 'Notifications'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Home')),
            Center(child: Text('Search')),
            Center(child: Text('Notifications')),
          ],
        ),
      ),
    );
  }
}
