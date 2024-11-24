import 'dart:async'; // Untuk StreamController
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  String brokerAddress = '';
  int brokerPort = 0;
  late MqttServerClient _client;
  String _connectionStatus = 'Disconnected';
  final StreamController<String> _messageController = StreamController.broadcast();
  final StreamController<String> _statusController = StreamController.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  Stream<String> get statusStream => _statusController.stream;

  String get connectionStatus => _connectionStatus;

  Future<String> connect() async {
    if (brokerAddress.isEmpty || brokerPort == 0) {
      return 'Broker Address or Port is not set';
    }

    _client = MqttServerClient.withPort(brokerAddress, 'flutter_client', brokerPort);
    _client.logging(on: true);
    _client.keepAlivePeriod = 20;

    _client.onDisconnected = () {
      _connectionStatus = 'Disconnected';
      _statusController.add(_connectionStatus); // Emit perubahan status
    };

    try {
      await _client.connect();
      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _connectionStatus = 'Connected to $brokerAddress';
        _statusController.add(_connectionStatus); // Emit status koneksi berhasil
      } else {
        _connectionStatus = 'Connection Failed';
        _statusController.add(_connectionStatus); // Emit status koneksi gagal
        _client.disconnect();
      }
    } catch (e) {
      _connectionStatus = 'Connection Failed: $e';
      _statusController.add(_connectionStatus); // Emit error
      _client.disconnect();
    }

    return _connectionStatus;
  }

  void disconnect() {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _client.disconnect();
      _connectionStatus = 'Disconnected';
      _statusController.add(_connectionStatus); // Emit status disconnect
    }
  }

  void publishMessage(String topic, String command) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      final message = MqttClientPayloadBuilder();
      message.addString(command);
      _client.publishMessage(topic, MqttQos.exactlyOnce, message.payload!);
    }
  }

  void subscribe(String topic) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
        final message = messages?.first.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _messageController.add(payload); // Emit pesan yang diterima
      });
    }
  }

  void updateBrokerConfig(String address, int port) {
    brokerAddress = address;
    brokerPort = port;
  }

  void dispose() {
    _messageController.close();
    _statusController.close();
  }
}
