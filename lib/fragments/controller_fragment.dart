import 'package:controller_rc/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ControllerFragment extends StatefulWidget {
  @override
  _ControllerFragmentState createState() => _ControllerFragmentState();
}

class _ControllerFragmentState extends State<ControllerFragment>
    with TickerProviderStateMixin {
  final MqttService _mqttService = MqttService();
  Timer? _messageTimer;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late StreamSubscription _statusSubscription;
  late StreamSubscription _messageSubscription;

  String _connectionStatus = 'Disconnected';
  int _hpValue = 100;
  bool _isGameActive = false;

  void _startContinuousMessage(String message, String topic) {
    _mqttService.publishMessage(topic, message);

    _messageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isGameActive &&
          _hpValue > 0 &&
          _connectionStatus.contains('Connected')) {
        _mqttService.publishMessage(topic, message);
      } else {
        _stopContinuousMessage();
      }
    });
  }

  void _stopContinuousMessage() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.2).animate(_pulseAnimationController);

    _statusSubscription = _mqttService.statusStream.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
    });

    _messageSubscription = _mqttService.messageStream.listen((message) {
      if (_isGameActive && _hpValue > 0) {
        setState(() {
          _hpValue = (_hpValue - 1).clamp(0, 100);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _statusSubscription.cancel();
    _messageSubscription.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _connectToMqttBroker() async {
    setState(() {
      _connectionStatus = 'Connecting...';
    });

    final result = await _mqttService.connect();
    if (result.contains('Connected')) {
      _mqttService.subscribe('controller/hited');
    }
    setState(() {
      _connectionStatus = result;
    });
  }

  void _startGame() {
    setState(() {
      _hpValue = 100;
      _isGameActive = true;
    });
  }

  Widget _buildHPBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // 80% dari lebar layar
      height: 30, // Ditingkatkan tingginya
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan, width: 3), // Border lebih tebal
        borderRadius: BorderRadius.circular(15), // Border radius lebih besar
        boxShadow: [
          // Menambahkan shadow untuk efek menonjol
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: _hpValue / 100,
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(_hpValue > 70
                  ? Colors.green
                  : _hpValue > 30
                      ? Colors.yellow
                      : Colors.red),
              minHeight: 30, // Menyesuaikan dengan height container
            ),
          ),
          // Menambahkan text HP value
          Center(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required String message,
    required Color color,
    required String topic,
  }) {
    final bool isEnabled = _isGameActive &&
        _hpValue > 0 &&
        _connectionStatus.contains('Connected');

    return GestureDetector(
      onTapDown:
          isEnabled ? (_) => _startContinuousMessage(message, topic) : null,
      onTapUp: isEnabled ? (_) => _stopContinuousMessage() : null,
      onTapCancel: isEnabled ? _stopContinuousMessage : null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon,
              size: 50,
              color: isEnabled ? Colors.cyan : Colors.cyan.withOpacity(0.3)),
          onPressed: null,
          tooltip: tooltip,
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _connectionStatus.contains('Connected')
                    ? Colors.green
                    : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (_connectionStatus.contains('Connected')
                            ? Colors.green
                            : Colors.red)
                        .withOpacity(0.5 * _pulseAnimation.value),
                    blurRadius: 8 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.cyan),
                onPressed: _connectionStatus != 'Connecting...'
                    ? _connectToMqttBroker
                    : null,
                tooltip: 'Reconnect',
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.cyan),
                onPressed:
                    _connectionStatus.contains('Connected') ? _startGame : null,
                tooltip: 'Start Game',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: Center(child: _buildHPBar()),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.arrow_upward,
                            tooltip: 'Forward',
                            message: '1',
                            color: Colors.black,
                            topic: 'controller/move/forward',
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildControlButton(
                                icon: Icons.arrow_back,
                                tooltip: 'Left',
                                message: '1',
                                color: Colors.black,
                                topic: 'controller/move/left',
                              ),
                              const SizedBox(width: 50),
                              _buildControlButton(
                                icon: Icons.arrow_forward,
                                tooltip: 'Right',
                                message: '1',
                                color: Colors.black,
                                topic: 'controller/move/right',
                              ),
                            ],
                          ),
                          _buildControlButton(
                            icon: Icons.arrow_downward,
                            tooltip: 'Backward',
                            message: '1',
                            color: Colors.black,
                            topic: 'controller/move/backward',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildConnectionStatus(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.flash_on,
                            tooltip: 'Fire',
                            message: '1',
                            color: Colors.black,
                            topic: 'controller/fire',
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildControlButton(
                                icon: Icons.rotate_left,
                                tooltip: 'Turn Left',
                                message: '1',
                                color: Colors.black,
                                topic: 'controller/move/turn_left',
                              ),
                              const SizedBox(width: 50),
                              _buildControlButton(
                                icon: Icons.rotate_right,
                                tooltip: 'Turn Right',
                                message: '1',
                                color: Colors.black,
                                topic: 'controller/move/turn_right',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
