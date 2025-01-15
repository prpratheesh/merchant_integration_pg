import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

class AES {
  static const String AES_IV = "PGKEYENCDECIVSPC";
  static const String HEX_DIGITS = "0123456789abcdef";

  static Uint8List createUint8ListFromHexString(String hex) {
    final buffer = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return buffer;
  }

  static String byteArrayToHexString(Uint8List data) {
    return hex.encode(data);
  }

  static String encryptAES(String key, String encryptString) {
    try {
      final ivSpec = Uint8List.fromList(utf8.encode(AES_IV));
      final keySpec = Uint8List.fromList(utf8.encode(key));
      final cipher = PaddedBlockCipher("AES/CBC/PKCS7");
      final params = PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(keySpec), ivSpec), null);
      cipher.init(true, params); // true=encrypt
      final encrypted =
          cipher.process(Uint8List.fromList(utf8.encode(encryptString)));
      return byteArrayToHexString(encrypted).toUpperCase();
    } catch (e) {
      print("Error during encryption: $e");
      return '';
    }
  }

  static String decryptAES(String key, String encryptedString) {
    try {
      final ivSpec = Uint8List.fromList(utf8.encode(AES_IV));
      final keySpec = Uint8List.fromList(utf8.encode(key));

      final cipher = PaddedBlockCipher("AES/CBC/PKCS7");
      final params = PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(keySpec), ivSpec), null);

      cipher.init(false, params); // false=decrypt

      final encryptedBytes = createUint8ListFromHexString(encryptedString);
      final decrypted = cipher.process(encryptedBytes);
      return utf8.decode(decrypted);
    } catch (e) {
      print("Error during decryption: $e");
      return '';
    }
  }

  static String convertToJsonString(String trandata, String id) {
    // Create a map with the required structure
    // trandata = '0CE90F34CBE341598BC0BD7D6269167E62D490E2C9669AE1CE64ACEF1D0856512B36A01523130DAAD080DF8C128DA34B2DBED6A3B6B25233C359CC0890CB523C96EA730DC65C1A47E5015B9D52673673530024D05EDA7B98DFDADAAE928E9CEA1DC48507FF2BBEA81ABA677F8082726E3A7E2DEC4B0281AAC536EEA30595E0613BC45D0EEEE16FABD5596B24114AB7CDCEA78869714674DE061FE77B3622C14964D9C4C6BEF03AAA15498B5890DC7E7666AD079408538DC5CB0729CAD427AD30';
    Map<String, dynamic> data = {
      'trandata': trandata,
      'id': id,
    };
    return jsonEncode([data]);
    // Convert the map to a JSON string
    // String jsonString = jsonEncode([data]);
    // Pretty-print the JSON
    // var jsonPrettyPrint = JsonEncoder.withIndent('  '); // Indent with 2 spaces
    // print(jsonPrettyPrint);
    // return jsonPrettyPrint.convert(jsonDecode(jsonString));
  }
}
