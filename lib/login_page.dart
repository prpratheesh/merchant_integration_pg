import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'aes.dart';
import 'api_provider_http.dart';
import 'font_sizes.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io' as io;
import 'logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1.0, // Ensure no gaps between pages
  );
  int _currentPage = 0;
  // List of asset image paths
  final List<String> _imagePaths = List.generate(
    10,
    (index) => 'assets/images/${index + 1}.jpg',
  );
  int numberOfItems = 0;
  final List<String> categories = [
    "MULTIROTOR SPARE PARTS",
    "BATTERIES & CHARGERS",
    "MECHANICAL PARTS",
    "AUTOMATION",
    "MOTOR DRIVES & DRIVERS",
    "POWER SUPPLY",
    "ROBOT KITS",
    "ROBOT WHEELS",
    "ROBOT PARTS",
    "IOT - WIRELESS SOLUTIONS",
    "DEVELOPMENT BOARD",
    "RASPBERRY PI",
    "PROGRAMMERS",
    "SENSORS",
    "DISPLAYS",
  ];
  final List<String> featuredProducts = [
    "High-Speed Brushless Motor",
    "Carbon Fiber Propellers",
    "Flight Controller Board",
    "Drone Landing Gear Kit",
    "Multirotor ESC",
    "11.1V LiPo Battery",
    "XT60 Parallel Charging Board",
    "5-in-1 LiPo Charger",
    "12V Rechargeable Battery Pack",
    "NiMH Fast Charger",
    "Aluminium Servo Mount",
    "Universal Shaft Coupler",
    "Stainless Steel Ball Bearings",
    "High-Torque Gearbox",
    "Adjustable Servo Bracket",
    "Arduino-Compatible Relay Module",
    "Stepper Motor with Driver",
    "Industrial Grade Conveyor Belt",
    "Smart Home Automation Kit",
    "Linear Actuator",
    "Dual H-Bridge Motor Driver",
    "High-Power DC Motor Driver",
    "Brushless Motor Controller",
    "PWM Speed Controller Module",
    "Servo Motor Control Board",
    "5V/2A Power Adapter",
    "LM317 Voltage Regulator Module",
    "12V DC Power Supply Unit",
    "Solar Panel",
    "USB Power Bank Module",
    "4WD Smart Car Kit",
    "Humanoid Robot Kit",
    "Arduino Robot Arm Kit",
    "Tank Robot Chassis",
    "Line-Following Robot Kit",
    "Omni Directional Wheel",
    "Rubber Tire with Alloy Hub",
    "Mecanum Wheels",
    "All-Terrain Robot Wheel",
    "Plastic Wheels for RC Robots",
    "Metal Gear Servo",
    "Ultrasonic Range Finder",
    "Robot Gripper Arm",
    "Robot Chassis Frame",
    "Infrared Obstacle Avoidance Sensor",
    "WiFi Module ESP8266",
    "Zigbee Communication Module",
    "Bluetooth 5.0 Transceiver",
    "GSM/GPRS SIM800L Module",
    "LoRaWAN Development Kit",
  ];
  final List<String> cartItems = [
    "T-Motor Propeller 12x4.5", // MULTIROTOR SPARE PARTS
    "DJI E300 ESC", // MULTIROTOR SPARE PARTS
    "ISDT T8 Charger", // BATTERIES & CHARGERS
    "Turnigy 11.1V LiPo", // BATTERIES & CHARGERS
    "RoboHobby Drone Frame", // MECHANICAL PARTS
    "X-Wing Drone Frame", // MECHANICAL PARTS
    "ZigBee Hub", // AUTOMATION
    "Sonoff Smart Switch", // AUTOMATION
    "DRV8825 Stepper Driver", // MOTOR DRIVES & DRIVERS
    "A2212 Brushless Motor", // MOTOR DRIVES & DRIVERS
    "MeanWell 12V Power", // POWER SUPPLY
    "Pololu 12V Supply", // POWER SUPPLY
    "Elegoo UNO Kit", // ROBOT KITS
    "Raspberry Pi 4 Kit", // ROBOT KITS
    "Tamiya RC Chassis", // ROBOT WHEELS
    "VEX 2WD Kit", // ROBOT WHEELS
    "DFRobot Romeo V2", // ROBOT PARTS
    "SainSmart 4WD Kit", // ROBOT PARTS
    "ESP8266 Relay", // IOT - WIRELESS SOLUTIONS
    "Adafruit LoRa Wing", // IOT - WIRELESS SOLUTIONS
  ];
  final List<double> cartPricesAED = [
    120.50, // T-Motor Propeller 12x4.5
    250.75, // DJI E300 ESC
    350.00, // ISDT T8 Charger
    150.25, // Turnigy 11.1V LiPo
    450.00, // RoboHobby Drone Frame
    550.50, // X-Wing Drone Frame
    99.99,  // ZigBee Hub
    89.50,  // Sonoff Smart Switch
    180.00, // DRV8825 Stepper Driver
    220.25, // A2212 Brushless Motor
    100.00, // MeanWell 12V Power
    75.75,  // Pololu 12V Supply
    135.25, // Elegoo UNO Kit
    235.50, // Raspberry Pi 4 Kit
    250.00, // Tamiya RC Chassis
    450.25, // VEX 2WD Kit
    180.00, // DFRobot Romeo V2
    275.50, // SainSmart 4WD Kit
    120.00, // ESP8266 Relay
    220.75, // Adafruit LoRa Wing
  ];
// Generate a list of random ratings for the items
  List<int> ratings = List<int>.generate(20, (index) => Random().nextInt(4) + 2);
  int cartCount = 0; // Total items in the cart
  List<int> itemCounts = List.generate(20, (_) => 0); // Tracks items added for each product
  final Map<String, String> formData = {
    'amt': '65.00',
    'action': '1',
    'trackId': 'RnxkiOvuj4VWjDykkC',
    'udf1': 'test udf1',
    'udf2': 'test udf2',
    'udf3': 'test udf3',
    'udf4': 'test udf4',
    'udf5': 'test udf5',
    'currencycode': '784',
    'id': 'ipaydxb002',
    'password': 'Admin123...',
  };
  var envData = '';
  Map<String, dynamic> envMap = {};
  final httpService = HttpService();
  String platformInfo = '';

  @override
  void initState() {
    super.initState();
    updatePlatformInfo((info) {
      setState(() {
        platformInfo = info;
      });
    });
    loadEnvData();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadEnvData() async {
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
      Logger.log('ERROR LOADING ENV FILE: ${e.toString()}', level: LogLevel.info);
      return;
    }
    // // Pretty print JSON string with indentation
    // final prettyJsonString = const JsonEncoder.withIndent('  ').convert(envMap);
    // Logger.log(prettyJsonString, level: LogLevel.info);
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
      platformInfo = 'LIN';
    } else if (io.Platform.isAndroid) {
      platformInfo = 'AND';
    } else if (io.Platform.isIOS) {
      platformInfo = 'IOS';
    } else {
      platformInfo = 'UNK';
    }
    updateState(platformInfo);
  }

  void resetItemCounts() {
    setState(() {
      cartCount = 0;
      numberOfItems = 0;
      itemCounts = List.generate(20, (_) => 0);
      cartCount=0;
    });
  }

  void _showLoginDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login to My Account'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(FontSizes fontSize, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          // Handle navigation actions
          print('$title tapped');
        },
        child: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: fontSize.smallerFontSize5),
        ),
      ),
    );
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = (_currentPage + 1) % _imagePaths.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800), // Increase duration for smoother effect
          curve: Curves.easeInOutCubic, // Use a smoother curve
        );
      }
    });
  }

  // Method to show the cart details dialog
  void _showCartDetailsDialog(BuildContext context, FontSizes fontSize) {
    showDialog(
      context: context,
      barrierDismissible: false, // Disable dismissing by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            double totalAmount = 0;
            int totalQuantity = 0;
            // Only show the items that have been added to the cart
            final addedItems = List.generate(cartItems.length, (index) {
              if (itemCounts[index] > 0) {
                double itemTotal = itemCounts[index] * cartPricesAED[index];
                totalAmount += itemTotal;
                totalQuantity += itemCounts[index];

                return TableRow(
                  decoration: BoxDecoration(
                    color: (index % 2 == 0) ? Colors.grey[200] : Colors.white, // Alternate row colors
                  ),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(cartItems[index]),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'AED ${cartPricesAED[index].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (itemCounts[index] > 0) {
                                  itemCounts[index]--;
                                  cartCount--;
                                }
                              });
                            },
                          ),
                          Text('${itemCounts[index]}'),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                itemCounts[index]++;
                                cartCount++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'AED ${(itemCounts[index] * cartPricesAED[index]).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return null; // Skip items that are not added to the cart
              }
            }).whereType<TableRow>().toList(); // Filter out null values and only keep TableRow widgets
            return AlertDialog(
              backgroundColor: Colors.white, // Set background color of AlertDialog
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Set the border radius
              ),
              title: const Center(child: Text('Cart Details')),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (addedItems.isEmpty)
                      const Text('Your cart is empty.', textAlign: TextAlign.center,) // Show a message if no items are in the cart
                    else
                      Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(), // Dynamic width for first column
                          1: IntrinsicColumnWidth(), // Dynamic width for second column
                          2: IntrinsicColumnWidth(), // Dynamic width for third column
                          3: IntrinsicColumnWidth(), // Dynamic width for fourth column
                        },
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.blueAccent), // Header row color
                            children: [
                              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('ITEM', style: TextStyle(color: Colors.white), textAlign: TextAlign.center))),
                              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('PRICE', style: TextStyle(color: Colors.white),textAlign: TextAlign.center))),
                              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('QTY', style: TextStyle(color: Colors.white),textAlign: TextAlign.center))),
                              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('TOTAL', style: TextStyle(color: Colors.white),textAlign: TextAlign.center))),
                            ],
                          ),
                          ...addedItems,
                          // Add a row for total amount and quantity
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[300]), // Total row color
                            children: [
                              const TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center))),
                              const TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('', style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('$totalQuantity', style: const TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('AED ${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center))),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 15, // Adjust width to be a proportion of the screen width
                        height: MediaQuery.of(context).size.height / 25, // Adjust height for better proportion
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red, // Set the outline border color
                            width: 1.0, // Set the outline border width
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xffdf8e33).withAlpha(10),
                              offset: const Offset(2, 4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                          color: Colors.white,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: fontSize.smallerFontSize4, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Add more spacing between the buttons
                    InkWell(
                      onTap: () async {
                        resetItemCounts();
                        /////////////////////////////TXN ROUTE/////////////////////////////
                        formData['id'] = envMap['TRAN_PORTAL_ID'];
                        formData['password'] = envMap['TRAN_PORTAL_PASSWORD'];
                        formData['amt'] = totalAmount.toStringAsFixed(2).toString();
                        Logger.log('DATA 1: $formData', level: LogLevel.info);
                        String queryString = convertToQueryString(formData) + '&';
                        Logger.log('DATA 2: $queryString', level: LogLevel.info);
                        String payload = AES.encryptAES(envMap['RESOURCE_KEY'], queryString);
                        Logger.log('DATA 3: $payload', level: LogLevel.info);
                        var jsonOutput = convertToJsonString(payload, envMap['TRAN_PORTAL_ID']);
                        Logger.log('UploadData: $jsonOutput', level: LogLevel.info);
                        // var url = 'https://pguat.creditpluspinelabs.com/ipay/hostedHTTP';
                        // var url = 'https://pguat.creditpluspinelabs.com/ipay/hostedHTTP';
                        var url = 'http://localhost:9090/proxy/iPay/hostedHTTP';
                        try {
                          final response = await httpService.sendPostRequest(url, jsonOutput);
                          if (response.statusCode == 200) {
                            var data = jsonDecode(response.body);
                            final trandata = data['trandata'];
                            if (trandata != null) {
                              Logger.log('return DATA 1: $trandata', level: LogLevel.info);
                              final decryptedTrandata = AES.decryptAES(envMap['RESOURCE_KEY'], trandata);
                              Logger.log('Decrypted URL && Payment ID: $decryptedTrandata', level: LogLevel.debug);
                              int colonIndex = decryptedTrandata.indexOf(":");
                              String paymentId = decryptedTrandata.substring(0, colonIndex);
                              String url = decryptedTrandata.substring(colonIndex + 1);
                              final completeUrl = '$url?PaymentID=$paymentId';
                              Logger.log('DATA 4: $completeUrl', level: LogLevel.info);
                              Logger.log('Page: $completeUrl', level: LogLevel.critical);
                              final uri = Uri.parse(completeUrl);
                              await launchUrl(uri);
                            } else {
                              print('Error: "trandata" field not found in response');
                            }
                          } else {
                            print('Request failed with status: ${response.statusCode}');
                            print('Response body: ${response.body}');
                          }
                        } catch (e) {
                          Logger.log('Error: $e', level: LogLevel.error);
                        }
                        /////////////////////////////TXN ROUTE/////////////////////////////
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 15, // Adjust width to be a proportion of the screen width
                        height: MediaQuery.of(context).size.height / 25, // Adjust height for better proportion
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green, // Set the outline border color
                            width: 1.0, // Set the outline border width
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xffdf8e33).withAlpha(10),
                              offset: const Offset(2, 4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                          color: Colors.white,
                        ),
                        child: Text(
                          'Proceed',
                          style: TextStyle(fontSize: fontSize.smallerFontSize4, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  //////////////////////DATA CONVERSION LOGICS //////////////////////

  String encryptionPayload(String payload, String encryptionKey) {
    // Define your key (must be 16, 24, or 32 bytes for AES)
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16); // Initialization Vector

    final encrypter =
    encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
    // Create encrypter
    // final encrypter = encrypt.Encrypter(encrypt.AES(key));
    // Plain text to be encrypted
    final plainText = payload;
    // Encrypting the text
    final encrypted = encrypter.encrypt(plainText);
    Logger.log('Encrypted: ${encrypted.base64}', level: LogLevel.info);
    // Decrypting the text
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    Logger.log('Decrypted: $decrypted', level: LogLevel.info);
    return encrypted.base64;
  }

  String encryptionPayloadCBC(String payload, String encryptionKey) {
    Logger.log('payload: $payload', level: LogLevel.critical);
    Logger.log('encryptionKey: $encryptionKey', level: LogLevel.critical);
    Logger.log('iv: PGKEYENCDECIVSPC', level: LogLevel.critical);
    // Define your key (must be 16, 24, or 32 bytes for AES)
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromUtf8("PGKEYENCDECIVSPC");
    // final iv = encrypt.IV.fromLength(16);  // Initialization Vector
    // Use CBC mode for encryption
    final encrypter =
    encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    // Plain text to be encrypted
    final plainText = payload;
    // Encrypting the text
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    Logger.log('Encrypted: ${encrypted.base64}', level: LogLevel.critical);
    // Decrypting the text
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    Logger.log('Decrypted: $decrypted', level: LogLevel.info);
    return encrypted.base64;
  }

  String convertToQueryString(Map<String, dynamic> data) {
    List<String> queryParameters = [];

    data.forEach((key, value) {
      // Convert the value to a string without replacing spaces
      String formattedValue = value.toString();
      queryParameters.add('$key=$formattedValue');
    });
    // Join the parameters with '&' and return the query string
    return queryParameters.join('&');
  }

  String convertToJsonString(String trandata, String id) {
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

  Map<String, dynamic> convertToJson(String trandata, String id) {
    // Create a map with the required structure
    Map<String, dynamic> data = {
      'trandata': trandata,
      'id': id,
    };
    // Return the map directly
    return {
      'data': [data]
    };
  }

  //////////////////////DATA CONVERSION LOGICS //////////////////////

  @override
  Widget build(BuildContext context) {
    final fontSizes = FontSizes.fromContext(context);
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 400.0, // Minimum width
          minHeight: 600.0, // Minimum height
        ),
    child: Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fiber_smart_record_outlined,
                  color: const Color(0xFF003323),
                  size: fontSizes.largerFontSize2,
                ),
                Text(
                  'NextGen Robotics',
                  style: GoogleFonts.portLligatSans(
                    fontSize: fontSizes.baseFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF003323),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width / 4,
                  //   height: MediaQuery.of(context).size.height/30,
                  //   child: Center(child: Text('DEAL OF THE DAY : 20% OFF ON ALL ORDERS ABOVE 10000 INR.',style: TextStyle(fontSize: fontSizes.smallerFontSize6, fontStyle: FontStyle.italic, color: const Color(0xFF003323)),)),
                  // ),
                  _buildNavItem(fontSizes,'HOME'),
                  _buildNavItem(fontSizes,'PRODUCTS'),
                  _buildNavItem(fontSizes,'TECH'),
                  _buildNavItem(fontSizes,'SOLUTIONS'),
                  _buildNavItem(fontSizes,'VIDEOS'),
                  _buildNavItem(fontSizes,'ABOUT US'),
                  Container(
                    width: MediaQuery.of(context).size.width / 6,
                    height: MediaQuery.of(context).size.height / 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF003323), // Outline color
                        width: 1, // Outline thickness
                      ),
                      borderRadius: BorderRadius.circular(5.0), // Rounded corners
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center, // Centers content inside the container
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Search..',
                                hintStyle: TextStyle(fontSize: fontSizes.smallerFontSize4),
                                isDense: true, // Ensures consistent alignment for small spaces
                                contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0), // Avoid extra padding
                                border: InputBorder.none, // Removes default TextFormField border
                              ),
                              textAlignVertical: TextAlignVertical.center, // Vertically center-align text
                            ),
                          ),
                        ),
                        Text(
                          'All',
                          style: TextStyle(color: const Color(0xFF003323), fontSize: fontSizes.smallerFontSize4),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF003323)),
                        const SizedBox(width: 5.0),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF003323),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Center(
                            child:
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.white, size: fontSizes.smallerFontSize4),
                            onPressed: null,
                          ),
                          ),
                        ),
                        // const SizedBox(width: 1.0),
                      ],
                    ),
                  ),
                  SizedBox(
              width: MediaQuery.of(context).size.width / 30,
              height: MediaQuery.of(context).size.height / 30,
              child: TextButton(
                onPressed: () {
                  _showCartDetailsDialog(context, fontSizes); // Show the cart details dialog
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF003323),
                  shape: const CircleBorder(
                  ),
                ),
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  cartCount.toString(),
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSizes.smallerFontSize5,
                ),
              ),
            ),
          ),
        ],
      ),
    ),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 30,
                    height: MediaQuery.of(context).size.height/30,
                    child: TextButton(
                      onPressed: () {
                        _showLoginDialog(context); // Trigger the pop-up dialog
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, // Text color
                        backgroundColor: const Color(0xFF003323),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('LOGIN', style: TextStyle(fontSize: fontSizes.smallerFontSize6),),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 500),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height/25,
            width: double.infinity,
            color: const Color(0xFF003323),
            child: Center(child: Text('Get 20% Off for your first order above 1500 AED.', style: TextStyle(fontSize: fontSizes.smallerFontSize4, color: Colors.white),),),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 1000),
          Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
              height: MediaQuery.of(context).size.height / 1.75,
              width: MediaQuery.of(context).size.width / 6,
              color: const Color(0xFF003323),
              child: ListView.separated(
                itemCount: categories.length + 1, // Add 1 for the static box
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white,
                  height: 0.1,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Static black box with text
                    return Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(1.0),
                      child: Center(
                        child: Text(
                        'ITEMS',
                        style: TextStyle(
                          color: Colors.white,
                            fontSize: fontSizes.smallerFontSize4,
                        ),
                      ),
                      ),
                    );
                  } else {
                    // Dynamic list items (adjust index by subtracting 1)
                    return ListTile(
                      title: Text(
                        categories[index - 1],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizes.smallerFontSize5,
                        ),
                      ),
                      trailing: (index - 1) == 4 // Adding a SALE tag for 'MOTORS'
                          ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "SALE",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      )
                          : const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        // Handle menu tap
                      },
                    );
                  }
                },
              ),
            ),//LEFT MENU
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.75,
            width: MediaQuery.of(context).size.width / 1.5,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _imagePaths[index],
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                );
              },
            ),
          ),//CENTER IMAGE SCROLL
          Container(
              height: MediaQuery.of(context).size.height / 1.75,
              width: MediaQuery.of(context).size.width / 6,
              color: const Color(0xFF003323),
              child: ListView.separated(
                itemCount: featuredProducts.length + 1, // Add 1 for the static box
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white,
                  height: 0.1,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Static black box with text
                    return Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(1.0),
                      child: Center(
                        child: Text(
                          'FEATURED PRODUCTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizes.smallerFontSize4,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Dynamic list items (adjust index by subtracting 1)
                    return ListTile(
                      title: Text(
                        featuredProducts[index - 1],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizes.smallerFontSize5,
                        ),
                      ),
                      onTap: () {
                        // Handle menu tap
                      },
                    );
                  }
                },
              ),
            ),//RIGHT MENU
          ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 10,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 6 columns
                    crossAxisSpacing: 1.0, // Spacing between cards horizontally
                    mainAxisSpacing: 1.0, // Spacing between cards vertically
                    childAspectRatio: 1.75, // Adjusted to make the cards smaller
                  ),
                  itemCount: 20, // Number of items to display
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 10, // Slightly reduced elevation for a softer effect
                      child: Stack(
                        fit: StackFit.loose, // Ensure the stack takes the full card space
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5), // Smaller rounded corners for the image as well
                              image: DecorationImage(
                                image: AssetImage('assets/itemImages/${index + 1}.jpg'),
                                fit: BoxFit.cover, // Ensures the image covers the entire container
                              ),
                              border: Border.all( // Adding border to the container
                                color: Colors.blue, // Dark green border
                                width: 1.0, // Border width
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.black.withOpacity(0.1),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom:  10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItems[index], // Product title
                                  style: GoogleFonts.roboto( // Change the font to Roboto (you can choose other fonts here)
                                    color: Colors.white,
                                    fontSize: fontSizes.smallerFontSize4, // Slightly smaller text for the title
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'AED ${cartPricesAED[index].toStringAsFixed(2)}', // Display price in AED with two decimal places
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: fontSizes.smallerFontSize4, // Slightly smaller price text
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      Icons.star,
                                      color: starIndex < ratings[index] ? Colors.yellow : Colors.grey,
                                      size: fontSizes.smallerFontSize6,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Row(
                              children: [
                                // Minus Button
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.yellow),
                                  onPressed: () {
                                    setState(() {
                                      if (itemCounts[index] > 0) {
                                        itemCounts[index]--; // Decrease item count
                                        cartCount--; // Decrease total cart count
                                      }
                                    });
                                  },
                                ),
                                // Display Item Count
                                Text(
                                  '${itemCounts[index]}',
                                  style: TextStyle(
                                    fontSize: fontSizes.smallerFontSize4,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                ),
                                // Plus Button
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.yellow),
                                  onPressed: () {
                                    setState(() {
                                      itemCounts[index]++; // Increase item count
                                      cartCount++; // Increase total cart count
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle FAB press action
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Floating Action Button Pressed!')),
          );
        },
        backgroundColor: const Color(0xFF003323),
        label: Text("Chat", style: TextStyle(color: Colors.white, fontSize: fontSizes.smallerFontSize4),),
        icon: const Icon(Icons.chat, color: Colors.white),
        elevation: 5,
        hoverColor: const Color(0xFF004426),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        )
      ),
    ),
    );
  }
}
