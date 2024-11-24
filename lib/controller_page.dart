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
  bool isLocked = false; // Menyimpan status mode lock
  int _previousIndex = 0; // Menyimpan indeks tab sebelumnya

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Tambahkan listener untuk mendeteksi perubahan tab
    _tabController.addListener(() {
      if (isLocked && _tabController.index != _previousIndex) {
        // Cegah perubahan tab jika terkunci
        _tabController.index = _previousIndex;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fragment is locked!")),
        );
      } else {
        _previousIndex = _tabController.index; // Perbarui indeks sebelumnya
      }
    });
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
        backgroundColor: Colors.cyan,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kosongkan bagian kiri agar tombol berada di sebelah kanan
            const SizedBox(),
            IconButton(
              onPressed: () {
                setState(() {
                  isLocked = !isLocked; // Toggle mode lock
                });
              },
              icon: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                color: isLocked ? Colors.white : Colors.black, // Ubah warna berdasarkan status
              ),
            ),
          ],
        ),
        flexibleSpace: SafeArea(
          child: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              labelColor: isLocked ? Colors.white : Colors.white, // Warna abu-abu jika terkunci
              unselectedLabelColor: isLocked ? Colors.black : Colors.black, // Warna abu-abu jika terkunci
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
              onTap: (index) {
                if (isLocked) {
                  // Mencegah perpindahan tab jika terkunci
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fragment is locked!")),
                  );
                } else {
                  _tabController.index = index; // Perpindahan tab diperbolehkan
                }
              },
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: isLocked
            ? const NeverScrollableScrollPhysics() // Mencegah geser jika terkunci
            : const BouncingScrollPhysics(), // Geser diizinkan jika tidak terkunci
        children: const [
          ControllerFragment(),
          SettingsFragment(),
        ],
      ),
    );
  }
}
