import 'package:controller_rc/mqtt_service.dart';
import 'package:flutter/material.dart';

class SettingsFragment extends StatefulWidget {
  const SettingsFragment({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsFragmentState createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  final MqttService _mqttService = MqttService();

  late TextEditingController _addressController;
  late TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: _mqttService.brokerAddress.isNotEmpty ? _mqttService.brokerAddress : '',
    );
    _portController = TextEditingController(
      text: _mqttService.brokerPort != 0 ? _mqttService.brokerPort.toString() : '',
    );
  }

  void _saveSettings() {
    try {
      final address = _addressController.text;
      final port = int.parse(_portController.text);

      _mqttService.updateBrokerConfig(address, port);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings Saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Port Number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background color
      appBar: AppBar(
        title: const Text(
          'MQTT Settings',
          style: TextStyle(color: Colors.white), // AppBar text color
        ),
        backgroundColor: const Color(0xFF000000), // Match background color
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to allow scrolling
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _addressController,
              style: const TextStyle(color: Colors.white), // Text color
              decoration: const InputDecoration(
                labelText: 'Broker Address',
                hintText: 'Enter MQTT Broker IP',
                labelStyle: TextStyle(color: Colors.white), // Label color
                hintStyle: TextStyle(color: Colors.white70), // Hint color
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan), // Cyan underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan), // Focused cyan underline
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white), // Text color
              decoration: const InputDecoration(
                labelText: 'Broker Port',
                hintText: 'Enter MQTT Broker Port',
                labelStyle: TextStyle(color: Colors.white), // Label color
                hintStyle: TextStyle(color: Colors.white70), // Hint color
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan), // Cyan underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan), // Focused cyan underline
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(color: Colors.cyan), // Button text color (cyan)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
