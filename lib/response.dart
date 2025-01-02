import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'websocket_provider.dart';

class PaymentRedirectPage extends StatelessWidget {
  const PaymentRedirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Response')),
      body: Center(
        child: webSocketProvider.message.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'This is the Message from Socket: ${webSocketProvider.message}'),
                  ElevatedButton(
                    onPressed: () {
                      print('Proceed with ${webSocketProvider.message}');
                    },
                    child: const Text('Proceed'),
                  ),
                ],
              ),
      ),
    );
  }
}
