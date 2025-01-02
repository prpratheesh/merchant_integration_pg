import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logger.dart';
import 'websocket_provider.dart';
import 'login_page.dart';
import 'response.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WebSocketProvider>(
          create: (context) => WebSocketProvider(
              showDialogCallback: showDecryptedDataDialog,
              navigatorKey: navigatorKey),
          lazy: false, // Ensure the provider initializes immediately
        ),
      ],
      child: const MainApp(),
    ),
  );
}

// Global navigator key for accessing context outside of the widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Callback function to show decrypted data in a dialog
void showDecryptedDataDialog(BuildContext context, String decryptedTrandata) {
  var stausMsg = '';
  var paymentStatus = accessParameter(decryptedTrandata, 'result');
  Logger.log('PAYMENT STATUS IN MAIN : $paymentStatus', level: LogLevel.error);
  if (paymentStatus == 'CAPTURED') {
    stausMsg = 'SUCCESS';
  } else {
    stausMsg = 'FAILED';
  }
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'PAYMENT $stausMsg',
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Key')),
              DataColumn(label: Text('Value')),
            ],
            rows: _parseKeyValuePairs(decryptedTrandata).entries.map((entry) {
              return DataRow(
                cells: [
                  DataCell(Text(entry.key)),
                  DataCell(Text(entry.value)),
                ],
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Center(child: Text('Close')),
          ),
        ],
      );
    },
  );
}

// Helper function to parse decrypted data
Map<String, String> _parseKeyValuePairs(String data) {
  final Map<String, String> result = {};
  final pairs = data.split('&');

  for (var pair in pairs) {
    final keyValue = pair.split('=');
    if (keyValue.length == 2) {
      result[Uri.decodeComponent(keyValue[0])] =
          Uri.decodeComponent(keyValue[1]);
    }
  }
  return result;
}

String accessParameter(String decryptedTrandata, String parameter) {
  // First, split the decryptedTrandata into key-value pairs
  Map<String, String> params = {};
  // Split the string by '&' to get individual key-value pairs
  var pairs = decryptedTrandata.split('&');
  for (var pair in pairs) {
    var keyValue = pair.split('=');
    if (keyValue.length == 2) {
      params[keyValue[0]] =
          Uri.decodeComponent(keyValue[1]); // Decoding URL-encoded values
    }
  }
  Logger.log('PAYMENT STATUS--------------->$parameter',
      level: LogLevel.critical);
  Logger.log('PAYMENT STATUS--------------->$params', level: LogLevel.critical);
  // Now access the 'result' parameter
  String? result = params[parameter];
  Logger.log('PAYMENT STATUS--------------->$result', level: LogLevel.critical);
  if (result != null) {
    Logger.log('Result parameter: $result', level: LogLevel.info);
    return result;
  } else {
    Logger.log('Result parameter not found.', level: LogLevel.warning);
    return 'Failure';
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign global navigator key
      title: "NextGen Robotics",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Color(0xFF003323),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/response': (context) => const PaymentRedirectPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
