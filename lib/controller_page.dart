import 'package:flutter/material.dart';
import 'fragments/controller_fragment.dart';
import 'fragments/settings_fragment.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan, // Mengubah warna navigator menjadi biru cyan
        elevation: 0,
        flexibleSpace: SafeArea(
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: Colors.white, // Mengubah warna teks yang aktif menjadi hitam
            unselectedLabelColor: Colors.black, // Mengubah warna teks yang tidak aktif menjadi putih
            tabs: const [
              Tab(
                icon: Icon(Icons.gamepad),
                text: 'Controller',
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: 'Settings',
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ControllerFragment(),  // Removed `const`
          SettingsFragment(),    // Removed `const`
        ],
      ),
    );
  }
}
