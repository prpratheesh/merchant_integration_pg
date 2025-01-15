import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'aes.dart';
import 'api_provider_http.dart';
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
      child: MainApp(),
    ),
  );
}

// Global navigator key for accessing context outside of the widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Map<String, dynamic> envMap = dotenv.env;
final httpService = HttpService();

// Callback function to show decrypted data in a dialog
Future<void> showDecryptedDataDialog(
    BuildContext context, String decryptedTrandata) async {
  //CALLING STAUS CHECK API AND VERIFY THE STATUS//
  Logger.log('STATUS CHECK API STARTED.', level: LogLevel.info);
  Logger.log(decryptedTrandata, level: LogLevel.critical);
  // Parse the decryptedTrandata string into key-value pairs
  final dataMap = Map.fromEntries(
    Uri.decodeFull(decryptedTrandata)
        .split('&')
        .where((entry) => entry.contains('='))
        .map((entry) {
      final parts = entry.split('=');
      return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
    }),
  );
  // Create a new Map with the required fields and order
  final updatedData = {
    'amt': dataMap['amt'] ?? '',
    'action': '8', // Static value
    'trackId': dataMap['trackid'] ?? '',
    'udf1': dataMap['udf1'] ?? '',
    'udf2': dataMap['udf2'] ?? '',
    'udf3': dataMap['udf3'] ?? '',
    'udf4': dataMap['udf4'] ?? '',
    'udf5': 'PaymentID', // Updated value
    'currencycode': '786', // Static value
    'transId': dataMap['paymentid'] ?? '',
    'id': 'ipaydxb002', // Static value
    'password': 'Admin123...', // Static value
  };
  // Reconstruct the string
  final result =
      updatedData.entries.map((e) => '${e.key}=${e.value}').join('&');
  final updateInqData = result.endsWith('&') ? result : '$result&';
  Logger.log(updateInqData, level: LogLevel.critical);
  String payload = AES.encryptAES(envMap['RESOURCE_KEY'], updateInqData);
  Logger.log(payload, level: LogLevel.error);
  var jsonOutput = AES.convertToJsonString(payload, envMap['TRAN_PORTAL_ID']);
  Logger.log('InquiryUploadData: $jsonOutput', level: LogLevel.info);
  var url = 'http://localhost:9090/proxy/iPay/TranportalTcpip.htm';
  try {
    final response = await httpService.sendPostRequest(url, jsonOutput);
    Logger.log('INQUIRY RESPONSE : $response', level: LogLevel.debug);
  } catch (e) {
    Logger.log('EXCEPTION CALLING STATUS API.$e', level: LogLevel.error);
  }
  Logger.log('STATUS CHECK API COMPLETED.', level: LogLevel.info);
  //CALLING STAUS CHECK API AND VERIFY THE STATUS//
  var stausMsg = '';
  var paymentStatus = await accessParameter(decryptedTrandata, 'result');
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

Future<String> accessParameter(
    String decryptedTrandata, String parameter) async {
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
//////////////////////////////////////////////////
  Logger.log('INSERTING PAYMENT DATA TO DB: $params', level: LogLevel.debug);
  const url = 'http://localhost:9090/insertPaymentData';
  final httpService = HttpService();
  try {
    final response = await httpService.sendPostRequest(
      url,
      jsonEncode(params), // Serialize params into JSON
    );
    Logger.log('DB INSERT STATUS = ${response.statusCode}',
        level: LogLevel.critical);
  } catch (e) {
    Logger.log('ERROR IN DB INSERT: $e', level: LogLevel.error);
  }
  ///////////////////////////////////////////////////
  String? result = params[parameter];
  if (result != null) {
    Logger.log('PAYMENT STATUS: $result', level: LogLevel.info);
    return result;
  } else {
    Logger.log('PAYMENT STATUS NOT AVAILABLE.', level: LogLevel.warning);
    return 'Failure';
  }
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

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
