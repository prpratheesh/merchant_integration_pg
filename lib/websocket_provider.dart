import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'aes.dart';
import 'logger.dart';
import 'dart:io' as io;

class WebSocketProvider with ChangeNotifier {
  late WebSocketChannel _channel;
  String _message = '';
  String _lastMessageId = '';
  bool _isConnected = false;
  String platformInfo = '';
  Map<String, dynamic> envMap = {};
  late final Function(BuildContext, String)
      showDialogCallback; // Callback to show dialog
  final GlobalKey<NavigatorState> navigatorKey; // Access to navigator key

  WebSocketProvider(
      {required this.showDialogCallback, required this.navigatorKey}) {
    _connect();
  }

  String get message => _message;
  bool get isConnected => _isConnected;

  /// ✅ Establish WebSocket Connection
  void _connect() {
    updatePlatformInfo((info) {
      platformInfo = info;
    });
    loadEnvData();
    if (_isConnected) {
      Logger.log('WEBSOCKET IS CONNECTED ALREADY. SKIPPING CONNECTION.',
          level: LogLevel.warning);
      return;
    }

    Logger.log('WEBSOCKET CONNECTING.', level: LogLevel.warning);
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8082'),
      );

      _isConnected = true;

      _channel.stream.listen(
        (data) => _handleMessage(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDone(),
        cancelOnError: true,
      );
    } catch (e) {
      Logger.log('WEBSOCKET EXCEPTION. $e. $e', level: LogLevel.critical);
      _isConnected = false;
      _reconnect();
    }
  }

  /// ✅ Handle Incoming Messages
  void _handleMessage(dynamic data) {
    Logger.log('WEBSOCKET MESSAGE RECEIVED.', level: LogLevel.debug);
    final parsedMessage = _parseJsonMessage(data);
    Logger.log('${parsedMessage['trandata']}', level: LogLevel.debug);

    if (parsedMessage['trackId'] == _lastMessageId) {
      Logger.log('WEBSOCKET DUPLICATE DATA RECEIVED. IGNORING.',
          level: LogLevel.warning);
      return;
    }

    final trandata = parsedMessage['trandata'];
    if (trandata != null && trandata is String) {
      final decryptedTrandata =
          AES.decryptAES(envMap['RESOURCE_KEY'], trandata);
      Logger.log('Decrypted DATA: $decryptedTrandata', level: LogLevel.warning);
      // html.window.close();
      // Show the decrypted data in a dialog
      showDialogCallback(navigatorKey.currentContext!, decryptedTrandata);
      html.window.postMessage('paymentWindowClosed', '*');
    } else {
      Logger.log('Invalid or null trandata received', level: LogLevel.warning);
    }

    _lastMessageId = parsedMessage['trackId'] ?? '';
    _message = data;
    notifyListeners();

    if (data.contains('redirect_to_page')) {
      _redirectToPage(data);
    }
  }

  /// ✅ Parse JSON Message
  Map<String, dynamic> _parseJsonMessage(String data) {
    try {
      return Map<String, dynamic>.from(jsonDecode(data));
    } catch (e) {
      Logger.log('WEBSOCKET ERROR PARSING MESSAGE.$e', level: LogLevel.debug);
      return {};
    }
  }

  /// ✅ Handle Errors
  void _handleError(dynamic error) {
    Logger.log('WEBSOCKET CONNECTION ERROR. $error', level: LogLevel.error);
    _isConnected = false;
    _reconnect();
  }

  /// ✅ Handle Connection Closure
  void _handleDone() {
    Logger.log('WEBSOCKET CONNECTION CLOSED.', level: LogLevel.warning);
    _isConnected = false;
    _reconnect();
  }

  /// ✅ Attempt Reconnection
  void _reconnect() {
    if (_isConnected) return;
    Future.delayed(const Duration(seconds: 5), () {
      Logger.log('WEBSOCKET ATTEMPTING TO RECONNECT.', level: LogLevel.warning);
      _connect();
    });
  }

  /// ✅ Redirect to URL
  void _redirectToPage(String data) {
    final url = _extractUrlFromMessage(data);
    if (url.isNotEmpty) {
      Logger.log('REDIRECTING TO URL. $url', level: LogLevel.warning);
      html.window.location.assign(url);
    }
  }

  String _extractUrlFromMessage(String message) {
    final regex = RegExp(r'(https?:\/\/[^\s]+)');
    final match = regex.firstMatch(message);
    return match?.group(0) ?? '';
  }

  Future<void> loadEnvData() async {
    Logger.log('$platformInfo', level: LogLevel.info);
    try {
      if (platformInfo == 'WIN') {
        await dotenv.load(fileName: 'assets/.env');
      } else if (platformInfo == 'WEB') {
        await dotenv.load();
      }
      envMap = dotenv.env; // Directly get the env variables as a Map
      Logger.log('Loaded ENV data: $envMap', level: LogLevel.info);
    } catch (e) {
      Logger.log(e.toString(), level: LogLevel.error);
      Logger.log('ERROR LOADING ENV FILE: ${e.toString()}',
          level: LogLevel.info);
      return;
    }
  }

  void updatePlatformInfo(Function(String) updateState) {
    String platformInfo;
    if (kIsWeb) {
      platformInfo = 'WEB';
    } else if (io.Platform.isWindows) {
      platformInfo = 'WIN';
    } else if (io.Platform.isMacOS) {
      platformInfo = 'MAC';
    } else if (io.Platform.isLinux) {
      platformInfo = 'LINUX';
    } else if (io.Platform.isAndroid) {
      platformInfo = 'ANDROID';
    } else if (io.Platform.isIOS) {
      platformInfo = 'IOS';
    } else {
      platformInfo = 'UNKNOWN';
    }
    updateState(platformInfo);
  }
}
