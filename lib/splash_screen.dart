import 'package:flutter/material.dart';
import 'controller_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _loadingProgress = 0.0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    while (_loadingProgress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 20));
      
      if (!_isNavigating) {
        setState(() {
          _loadingProgress += 0.01;
          
          if (_loadingProgress >= 1.0) {
            _isNavigating = true;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ControllerPage()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  Text(
                    'RC Tank Pilot',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 15,
                      value: _loadingProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(_loadingProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
