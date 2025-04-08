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
import 'dart:html' as html;
import 'package:provider/provider.dart';
import 'master_card_model.dart';
import 'websocket_provider.dart';

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
  final Map<String, List<String>> products = {
    "MULTIROTOR SPARE PARTS": [
      "Propeller Blades",
      "Flight Controller Board",
      "Brushless Motors",
      "ESC Modules",
      "GPS Module",
      "Landing Gear Set",
      "Camera Gimbal",
      "Motor Mounts",
      "Power Distribution Board",
      "Battery Straps",
    ],
    "BATTERIES & CHARGERS": [
      "LiPo 11.1V 2200mAh",
      "NiMH Rechargeable Battery",
      "18650 Battery Pack",
      "Battery Management System",
      "Fast Charger for LiPo",
      "USB-C Charging Hub",
      "Solar Power Bank",
      "Car Battery Charger",
      "Lead Acid Battery 12V",
      "Lithium-Ion Battery 3.7V",
    ],
    "MECHANICAL PARTS": [
      "Aluminum Rods",
      "Stainless Steel Gears",
      "Bearings (608ZZ)",
      "Timing Belts",
      "Shaft Couplers",
      "Pulley Wheels",
      "Carbon Fiber Sheets",
      "Ball Joints",
      "Springs Set",
      "Robotic Arm Frame",
    ],
    "AUTOMATION": [
      "Stepper Motor with Driver",
      "PLC Control Unit",
      "Servo Motor",
      "Relay Module",
      "Limit Switches",
      "Pneumatic Actuator",
      "Linear Actuator",
      "Conveyor Belt System",
      "Automation Sensors Kit",
      "Industrial Robot Controller",
    ],
    "MOTOR DRIVES & DRIVERS": [
      "L298N Motor Driver",
      "TB6600 Stepper Driver",
      "Brushless Motor ESC",
      "DC Motor Driver Module",
      "PWM Speed Controller",
      "H-Bridge Motor Driver",
      "DRV8825 Stepper Driver",
      "VFD Motor Controller",
      "Brush Motor Driver",
      "Stepper Driver Kit",
    ],
    "POWER SUPPLY": [
      "12V SMPS",
      "Adjustable Power Supply",
      "Solar Panel 100W",
      "DC-DC Converter",
      "Battery Eliminator Circuit",
      "USB Power Adapter",
      "UPS Backup System",
      "5V 2A Regulated Power Supply",
      "AC-DC Adapter",
      "Voltage Regulator Module",
    ],
    "ROBOT KITS": [
      "2WD Robot Chassis Kit",
      "4WD Smart Robot Kit",
      "Line Follower Robot Kit",
      "Bluetooth Controlled Robot",
      "Obstacle Avoidance Robot",
      "DIY Robotic Arm Kit",
      "Raspberry Pi Robot Kit",
      "Tank Robot Kit",
      "Arduino Robotic Kit",
      "Solar Robot Kit",
    ],
    "ROBOT WHEELS": [
      "Rubber Wheel 65mm",
      "Caster Wheel 50mm",
      "Omni Wheel 100mm",
      "Mecanum Wheel Set",
      "PU Foam Wheel",
      "Metallic Wheel 90mm",
      "Treaded Robot Wheels",
      "Plastic Wheel Hub",
      "High Torque Robot Wheel",
      "Wheel with Encoder",
    ],
    "ROBOT PARTS": [
      "Robotic Arm Gripper",
      "Servo Brackets",
      "Stepper Motor Mount",
      "Robot Chassis Frame",
      "Robot Track System",
      "Metal Joints Kit",
      "AI Camera Module",
      "High Torque Servos",
      "Flexible Coupling",
      "Battery Holder for Robots",
    ],
    "IOT - WIRELESS SOLUTIONS": [
      "ESP32 Wi-Fi Module",
      "LoRa Communication Kit",
      "Zigbee Transceiver",
      "Wi-Fi Smart Plug",
      "IoT Relay Module",
      "Bluetooth Beacon",
      "RFID Module",
      "GSM Module SIM800L",
      "IoT Development Kit",
      "NB-IoT Kit",
    ],
    "DEVELOPMENT BOARD": [
      "Arduino UNO R3",
      "ESP8266 Wi-Fi Board",
      "STM32 Development Board",
      "BeagleBone Black",
      "Teensy 4.1",
      "Intel Edison Kit",
      "Adafruit Feather",
      "NodeMCU ESP32",
      "LPC2148 Development Kit",
      "PIC Microcontroller Board",
    ],
    "RASPBERRY PI": [
      "Raspberry Pi 4 Model B",
      "Pi Camera Module",
      "Pi Sense HAT",
      "Pi GPIO Expansion Board",
      "Pi Official Case",
      "Pi Touchscreen Display",
      "Pi Cooling Fan",
      "Pi Power Supply",
      "Pi HAT Starter Kit",
      "Pi Desktop Kit",
    ],
    "PROGRAMMERS": [
      "USB ASP Programmer",
      "AVR ISP Programmer",
      "Pickit3 Programmer",
      "FTDI USB to Serial",
      "JTAG Debugger",
      "ST-Link V2",
      "Arduino Bootloader Programmer",
      "CH341A Programmer",
      "EEPROM Programmer",
      "Universal Programmer Kit",
    ],
    "SENSORS": [
      "Ultrasonic Sensor HC-SR04",
      "IR Proximity Sensor",
      "DHT11 Temperature Sensor",
      "Gas Sensor MQ-2",
      "Gyroscope Sensor",
      "Flex Sensor",
      "Light Dependent Resistor",
      "Soil Moisture Sensor",
      "Pressure Sensor",
      "Current Sensor ACS712",
    ],
    "DISPLAYS": [
      "7-Segment Display",
      "OLED Display 0.96 inch",
      "TFT LCD 2.8 inch",
      "ePaper Display Module",
      "Dot Matrix LED Panel",
      "16x2 LCD Module",
      "Touch Screen Display",
      "Graphic LCD 128x64",
      "LED Bar Graph",
      "RGB LED Matrix Display",
    ],
  };
  String? hoveredCategory;
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
    99.99, // ZigBee Hub
    89.50, // Sonoff Smart Switch
    180.00, // DRV8825 Stepper Driver
    220.25, // A2212 Brushless Motor
    100.00, // MeanWell 12V Power
    75.75, // Pololu 12V Supply
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
  List<int> ratings =
      List<int>.generate(20, (index) => Random().nextInt(4) + 2);
  int cartCount = 0; // Total items in the cart
  List<int> itemCounts =
      List.generate(20, (_) => 0); // Tracks items added for each product
  final Map<String, String> formData = {
    'amt': '65.00',
    'action': '1',
    'trackId': 'RnxkiOvuj4VWjDykkC',
    'udf1': 'PRATHEESH',
    'udf2': '0529716497',
    'udf3': 'test udf3',
    'udf4': 'test udf4',
    'udf5': 'test udf5',
    'currencycode': '784',
    'id': 'ipay90ce0bff79d54',
    'password': '122N14#2l507122',
  };
  var envData = '';
  Map<String, dynamic> envMap = {};
  final httpService = HttpService();
  String platformInfo = '';
  bool _isChatBarVisible = false;
  bool isCancelHovered_WL = false;
  bool isProceedHovered_WL = false;
  bool isAuthdHovered_WL = false;

  bool isCancelHovered_MPGS = false;
  bool isProceedHovered_MPGS = false;
  bool isAuthdHovered_MPGS = false;

  bool isCancelHovered_CYBS = false;
  bool isProceedHovered_CYBS = false;
  bool isAuthdHovered_CYBS = false;
  html.Window? paymentWindow;
  var MasterCard;

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

  String generateTrackId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random.secure();
    return List.generate(18, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Define the function BEFORE it is used
  MPGS createMasterCardFromEnv() {
    return MPGS(
      host: dotenv.env['HOST'] ?? '',
      merchantId: dotenv.env['MERCHANT_ID'] ?? '',
      currency: dotenv.env['CURRENCY'] ?? '',
      fpan: dotenv.env['FPAN'] ?? '',
      expMonth: dotenv.env['EXP_MONTH'] ?? '',
      expYear: dotenv.env['EXP_YEAR'] ?? '',
      securityCode: dotenv.env['SECURITY_CODE'] ?? '',
      fpanAdditional: dotenv.env['FPAN_ADDITIONAL'] ?? '',
      expMonthAdditional: dotenv.env['EXP_MONTH_ADDITIONAL'] ?? '',
      expYearAdditional: dotenv.env['EXP_YEAR_ADDITIONAL'] ?? '',
      authorizationCode: dotenv.env['AUTHORIZATION_CODE'] ?? '',
      giftCardNumber: dotenv.env['GIFT_CARD_NUMBER'] ?? '',
      costcoGiftCardNumber: dotenv.env['COSTCO_GIFT_CARD_NUMBER'] ?? '',
      costcoCardPin: dotenv.env['COSTCO_CARD_PIN'] ?? '',
      apiPassword: dotenv.env['API_PASSWORD'] ?? '',
      orderId: dotenv.env['ORDER_ID'] ?? '',
    );
  }

  Future<void> loadEnvData() async {
    try {
      if (platformInfo == 'WIN') {
        await dotenv.load(fileName: 'assets/.env');
      } else if (platformInfo == 'WEB') {
        await dotenv.load();
      }
      envMap = dotenv.env; // Directly get the env variables as a Map
      MasterCard = createMasterCardFromEnv();
      Logger.log('Loaded ENV data: $envMap', level: LogLevel.debug);
    } catch (e) {
      Logger.log(e.toString(), level: LogLevel.error);
      Logger.log('ERROR LOADING ENV FILE: ${e.toString()}',
          level: LogLevel.info);
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
      cartCount = 0;
    });
  }

  void _showLoginDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Disable dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Center(
            child: Text(
              'Welcome',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
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
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Add login logic here
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Login'),
                ),
              ],
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the login dialog
                  _showSignUpDialog(context); // Show the sign-up dialog
                },
                child: Text('Don’t have an account? Sign Up'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignUpDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Disable dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            // Sign Up Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Add sign-up logic here
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Sign Up'),
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
          Navigator.pushNamed(context, '/response');
          print('$title tapped');
        },
        child: Text(
          title,
          style: TextStyle(
              color: Colors.black, fontSize: fontSize.smallerFontSize5),
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
          duration: const Duration(
              milliseconds: 800), // Increase duration for smoother effect
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
            // Calculate totalAmount and totalQuantity
            final addedItems = List.generate(cartItems.length, (index) {
              if (itemCounts[index] > 0) {
                double itemTotal = itemCounts[index] * cartPricesAED[index];
                totalAmount += itemTotal;
                totalQuantity += itemCounts[index];

                return TableRow(
                  decoration: BoxDecoration(
                    color: (index % 2 == 0)
                        ? Colors.grey[200]
                        : Colors.white, // Alternate row colors
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
            })
                .whereType<TableRow>()
                .toList(); // Filter out null values and only keep TableRow widgets

            // Discount Calculation
            double discount = 0;
            if (totalAmount > 1500) {
              discount = totalAmount * 0.20;
            }
            double finalTotal = totalAmount - discount;
            return AlertDialog(
              backgroundColor:
                  Colors.white, // Set background color of AlertDialog
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Set the border radius
              ),
              title: Center(
                child: Text(
                  'Cart Details',
                  style: TextStyle(fontSize: fontSize.smallerFontSize4),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (addedItems.isEmpty)
                      Text(
                        'Your cart is empty.\nPlease add items to cart.',
                        style: TextStyle(fontSize: fontSize.smallerFontSize6),
                        textAlign: TextAlign.center,
                      ) // Show a message if no items are in the cart
                    else
                      Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(),
                          1: IntrinsicColumnWidth(),
                          2: IntrinsicColumnWidth(),
                          3: IntrinsicColumnWidth(),
                        },
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                                color: Colors.blueAccent), // Header row color
                            children: [
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('ITEM',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center))),
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('PRICE',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center))),
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('QTY',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center))),
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('TOTAL',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center))),
                            ],
                          ),
                          ...addedItems,
                          TableRow(
                            decoration: BoxDecoration(
                                color: Colors.grey[300]), // Total row color
                            children: [
                              const TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('TOTAL',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center))),
                              const TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('',
                                          textAlign: TextAlign.center))),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('$totalQuantity',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      'AED ${totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                          if (discount > 0)
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors
                                      .greenAccent[100]), // Discount row color
                              children: [
                                const TableCell(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('DISCOUNT',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center))),
                                const TableCell(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('',
                                            textAlign: TextAlign.center))),
                                const TableCell(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('',
                                            textAlign: TextAlign.center))),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        '-AED ${discount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ],
                            ),
                          TableRow(
                            decoration: BoxDecoration(
                                color:
                                    Colors.grey[200]), // Final total row color
                            children: [
                              const TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('NET PAYABLE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center))),
                              const TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('',
                                          textAlign: TextAlign.center))),
                              const TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('',
                                          textAlign: TextAlign.center))),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      'AED ${finalTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (addedItems.isNotEmpty)
                  Column(
                    children: [
                      const Center(
                        child: Text(
                          'WL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Center the buttons
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isCancelHovered_WL = true),
                              onExit: (event) =>
                                  setState(() => isCancelHovered_WL = false),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isCancelHovered_WL
                                          ? Colors.orange
                                          : Colors.red, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isCancelHovered_WL
                                        ? Colors.red[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isProceedHovered_WL = true),
                              onExit: (event) =>
                                  setState(() => isProceedHovered_WL = false),
                              child: InkWell(
                                onTap: () async {
                                  resetItemCounts();
                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  formData['id'] = envMap['TRAN_PORTAL_ID'];
                                  formData['password'] =
                                      envMap['TRAN_PORTAL_PASSWORD'];
                                  formData['amt'] =
                                      totalAmount.toStringAsFixed(2).toString();
                                  formData['trackId'] = generateTrackId();
                                  Logger.log('DATA 1: $formData',
                                      level: LogLevel.info);
                                  String queryString =
                                      convertToQueryString(formData) + '&';
                                  Logger.log('DATA 2: $queryString',
                                      level: LogLevel.info);
                                  String payload = AES.encryptAES(
                                      envMap['RESOURCE_KEY'], queryString);
                                  Logger.log('DATA 3: $payload',
                                      level: LogLevel.info);
                                  var jsonOutput = AES.convertToJsonString(
                                      payload, envMap['TRAN_PORTAL_ID']);
                                  Logger.log('UploadData: $jsonOutput',
                                      level: LogLevel.info);
                                  Map<String, dynamic> dbData = {
                                    'TRANSACTION_ID': formData['trackId'],
                                    'AMOUNT': double.parse(formData['amt']!),
                                    'CURRENCY': envMap['CURRENCY'] ??
                                        'AED', // Default to 'USD' if not provided
                                    'TRANSACTION_DATE':
                                        DateTime.now().toIso8601String(),
                                    'PAYMENT_ID': '',
                                    'PAYMENT_URL': ''
                                  };
                                  handlePaymentResponse(jsonOutput, dbData);
                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isProceedHovered_WL
                                          ? Colors.blue
                                          : Colors.green, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isProceedHovered_WL
                                        ? Colors.green[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isAuthdHovered_WL = true),
                              onExit: (event) =>
                                  setState(() => isAuthdHovered_WL = false),
                              child: InkWell(
                                onTap: () async {
                                  resetItemCounts();
                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  formData['id'] = envMap['TRAN_PORTAL_ID'];
                                  formData['password'] =
                                      envMap['TRAN_PORTAL_PASSWORD'];
                                  formData['amt'] =
                                      totalAmount.toStringAsFixed(2).toString();
                                  formData['action'] = '4';
                                  formData['trackId'] = generateTrackId();
                                  Logger.log('DATA 1: $formData',
                                      level: LogLevel.info);
                                  String queryString =
                                      convertToQueryString(formData) + '&';
                                  Logger.log('DATA 2: $queryString',
                                      level: LogLevel.info);
                                  String payload = AES.encryptAES(
                                      envMap['RESOURCE_KEY'], queryString);
                                  Logger.log('DATA 3: $payload',
                                      level: LogLevel.info);
                                  var jsonOutput = AES.convertToJsonString(
                                      payload, envMap['TRAN_PORTAL_ID']);
                                  Logger.log('UploadData: $jsonOutput',
                                      level: LogLevel.info);
                                  Map<String, dynamic> dbData = {
                                    'TRANSACTION_ID': formData['trackId'],
                                    'AMOUNT': double.parse(formData['amt']!),
                                    'CURRENCY': envMap['CURRENCY'] ??
                                        'AED', // Default to 'USD' if not provided
                                    'TRANSACTION_DATE':
                                        DateTime.now().toIso8601String(),
                                    'PAYMENT_ID': '',
                                    'PAYMENT_URL': ''
                                  };
                                  handlePaymentResponse(jsonOutput, dbData);
                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isAuthdHovered_WL
                                          ? Colors.blue
                                          : Colors
                                              .indigoAccent, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isAuthdHovered_WL
                                        ? Colors.blue[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Auth',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]), //WLPG
                      const Divider(color: Colors.blue),
                      const Center(
                        child: Text(
                          'MPGS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Center the buttons
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isCancelHovered_MPGS = true),
                              onExit: (event) =>
                                  setState(() => isCancelHovered_MPGS = false),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isCancelHovered_MPGS
                                          ? Colors.orange
                                          : Colors.red, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isCancelHovered_MPGS
                                        ? Colors.red[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isProceedHovered_MPGS = true),
                              onExit: (event) =>
                                  setState(() => isProceedHovered_MPGS = false),
                              child: InkWell(
                                onTap: () async {
                                  resetItemCounts();
                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Logger.log(
                                      '------------------ENTRY-------------------------',
                                      level: LogLevel.critical);
                                  Map<String, dynamic> dbData = {
                                    'TRANSACTION_ID': formData['trackId'],
                                    'AMOUNT': double.parse(formData['amt']!),
                                    'CURRENCY': envMap['CURRENCY'] ??
                                        'AED', // Default to 'USD' if not provided
                                    'TRANSACTION_DATE':
                                        DateTime.now().toIso8601String(),
                                    'PAYMENT_ID': '',
                                    'PAYMENT_URL': ''
                                  };
                                  mpgsCheckoutPurchase(dbData);
                                  Logger.log(
                                      '------------------ENTRY-------------------------',
                                      level: LogLevel.critical);
                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isProceedHovered_MPGS
                                          ? Colors.blue
                                          : Colors.green, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isProceedHovered_MPGS
                                        ? Colors.green[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isAuthdHovered_MPGS = true),
                              onExit: (event) =>
                                  setState(() => isAuthdHovered_MPGS = false),
                              child: InkWell(
                                onTap: () async {
                                  resetItemCounts();
                                  /////////////////////////////TXN ROUTE/////////////////////////////

                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isAuthdHovered_MPGS
                                          ? Colors.blue
                                          : Colors
                                              .indigoAccent, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isAuthdHovered_MPGS
                                        ? Colors.blue[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Auth',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]), //MPGS
                      const Divider(color: Colors.blue),
                      const Center(
                        child: Text(
                          'CYBS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Center the buttons
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isCancelHovered_CYBS = true),
                              onExit: (event) =>
                                  setState(() => isCancelHovered_CYBS = false),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isCancelHovered_CYBS
                                          ? Colors.orange
                                          : Colors.red, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isCancelHovered_CYBS
                                        ? Colors.red[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isProceedHovered_CYBS = true),
                              onExit: (event) =>
                                  setState(() => isProceedHovered_CYBS = false),
                              child: InkWell(
                                onTap: () async {
                                  resetItemCounts();
                                  /////////////////////////////TXN ROUTE/////////////////////////////

                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isProceedHovered_CYBS
                                          ? Colors.blue
                                          : Colors.green, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isProceedHovered_CYBS
                                        ? Colors.green[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isAuthdHovered_CYBS = true),
                              onExit: (event) =>
                                  setState(() => isAuthdHovered_CYBS = false),
                              child: InkWell(
                                onTap: () async {
                                  resetItemCounts();
                                  /////////////////////////////TXN ROUTE/////////////////////////////

                                  /////////////////////////////TXN ROUTE/////////////////////////////
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isAuthdHovered_CYBS
                                          ? Colors.blue
                                          : Colors
                                              .indigoAccent, // Highlight on hover
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xffdf8e33)
                                            .withAlpha(10),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: isAuthdHovered_CYBS
                                        ? Colors.blue[50]
                                        : Colors.white, // Background on hover
                                  ),
                                  child: Text(
                                    'Auth',
                                    style: TextStyle(
                                      fontSize: fontSize.smallerFontSize5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]), //CYBS
                    ],
                  )
                else
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set your desired background color
                        foregroundColor: Colors.white, // Set the text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: Text(
                        'Ok',
                        style: TextStyle(fontSize: fontSize.smallerFontSize6),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildChatBox(BuildContext context) {
    return Positioned(
      right: 5, // Align to the right side with some margin
      bottom: MediaQuery.of(context).size.height /
          15, // Position above the FloatingActionButton
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isChatBarVisible
            ? MediaQuery.of(context).size.height / 2
            : 0, // Set height to 0 when hidden
        width: MediaQuery.of(context).size.width / 8, // Adjust width as needed
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: _isChatBarVisible
            ? Column(
                children: [
                  // Chat bar header
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF004426),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Chat",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isChatBarVisible = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Chat messages area
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: const [
                        Text("Welcome to the chat!",
                            style: TextStyle(fontSize: 16)),
                        // Add more messages here
                      ],
                    ),
                  ),
                  // Input field
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Type a message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon:
                              const Icon(Icons.send, color: Color(0xFF004426)),
                          onPressed: () {
                            // Handle send action here
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Future<void> handlePaymentResponse(var jsonOutput, var dbData) async {
    var url = 'http://localhost:9090/proxy/iPay/hostedHTTP';
    // var url = 'http://wlpgtest.pinelabs.com:9090/proxy/iPay/hostedHTTP';
    Logger.log('$jsonOutput', level: LogLevel.critical);
    try {
      final response = await httpService.sendPostRequest(url, jsonOutput);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Logger.log('return DATA 0: $data', level: LogLevel.info);
        final trandata = data['trandata'];
        if (trandata != null) {
          Logger.log('return DATA 1: $trandata', level: LogLevel.info);
          final decryptedTrandata =
              AES.decryptAES(envMap['RESOURCE_KEY'], trandata);
          Logger.log('Decrypted URL && Payment ID: $decryptedTrandata',
              level: LogLevel.debug);
          int colonIndex = decryptedTrandata.indexOf(":");
          String paymentId = decryptedTrandata.substring(0, colonIndex);
          String redirectUrl = decryptedTrandata.substring(colonIndex + 1);
          final completeUrl = '$redirectUrl?PaymentID=$paymentId';

          //insert into database
          dbData['PAYMENT_ID'] = paymentId;
          dbData['PAYMENT_URL'] = redirectUrl;
          Logger.log('DB DATA: $dbData', level: LogLevel.debug);
          const url = 'http://localhost:9090/insertERPtxn';
          final response = await httpService.sendPostRequest(
            url,
            jsonEncode(dbData), // Serialize dbData into JSON
          );
          Logger.log('DB INSERT STATUS = $response', level: LogLevel.critical);

          Logger.log('Redirecting to: $completeUrl', level: LogLevel.critical);

          if (kIsWeb) {
            Logger.log('kIsWeb is true', level: LogLevel.warning);
            // html.window.open(completeUrl, '_blank');
            // Open the payment page in a new window/tab and store the reference
            html.WindowBase? paymentWindow =
                html.window.open(completeUrl, '_blank');
            html.window.onMessage.listen((event) {
              if (event.data == 'paymentWindowClosed') {
                // Handle payment window closure, e.g., perform some action like closing the page
                _closePaymentWindow(paymentWindow);
              }
            });
            // html.window.location.assign(completeUrl);
          } else {
            Logger.log('kIsWeb is false', level: LogLevel.warning);
          }
        } else {
          Logger.log('Error: "trandata" field not found in response',
              level: LogLevel.error);
        }
      } else {
        Logger.log('Request failed with status: ${response.statusCode}',
            level: LogLevel.critical);
        Logger.log('Response body: ${response.body}', level: LogLevel.error);
      }
    } catch (e) {
      Logger.log('Exception: $e', level: LogLevel.error);
    }
  }

  //////////////////////////MPGS DATA REQUEST ////////////////////////
  Future<void> mpgsCheckoutPurchase(dbData) async {
    // Construct the URL using the host and merchantId from the environment variables
    final host = MasterCard.host;
    final merchantId = MasterCard.merchantId;
    // final url = 'https://$host/api/rest/version/100/merchant/$merchantId/session';
    final url = 'http://localhost:9090/proxy/mpgsCheckoutPurchase';
    // Prepare the request body
    final body = {
      "host": host, // Pass host from Flutter
      "merchantId": merchantId, // Pass merchantId from Flutter
      "apiOperation": "INITIATE_CHECKOUT",
      "checkoutMode": "WEBSITE",
      "interaction": {
        "operation": "PURCHASE",
        "merchant": {
          "name": "Pine Labs Dubai",
          "url": "https://www.your.site.url.com",
        },
        "returnUrl": "https://www.your.site.url.com",
      },
      "order": {
        "currency": MasterCard.currency, // Use currency from .env
        // "amount": totalAmount.toStringAsFixed(2).toString();,
        "id": MasterCard.orderId, // Use orderId from .env
        "description": "Goods and Services",
      },
    };

    // Encode the body to JSON
    final bodyJson = jsonEncode(body);
    Logger.log(bodyJson);

    // Prepare basic authentication
    final username = 'merchant.$merchantId';
    final password = MasterCard.apiPassword;
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Logger.log(basicAuth, level: LogLevel.critical);
    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: bodyJson,
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Logger.log('return DATA 0: $data', level: LogLevel.info);
      } else {
        Logger.log('Request failed with status: ${response.statusCode}',
            level: LogLevel.critical);
        Logger.log('Response body: ${response.body}', level: LogLevel.error);
      }
    } catch (e) {
      Logger.log('Exception: $e', level: LogLevel.error);
    }
  }
  //////////////////////////MPGS DATA REQUEST ////////////////////////

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

  void _performRedirect(BuildContext context, String message) {
    final url = _extractUrlFromMessage(message);
    if (url.isNotEmpty) {
      // Navigate to the new URL or route
      Navigator.pushReplacementNamed(context, url);
    }
  }

  String _extractUrlFromMessage(String message) {
    Logger.log('APP DATA RECEIVED : $message', level: LogLevel.error);
    return message; // For now, return the message itself as a placeholder
  }

  void _closePaymentWindow(html.WindowBase paymentWindow) {
    Logger.log('$paymentWindow', level: LogLevel.critical);
    if (paymentWindow.opener != null) {
      paymentWindow.close(); // This will close the payment window
      Logger.log("Payment window closed.", level: LogLevel.info);
    } else {
      Logger.log("Payment window is already closed or null.",
          level: LogLevel.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizes = FontSizes.fromContext(context);
    // final webSocketProvider = Provider.of<WebSocketProvider>(context);
    // Listen for WebSocket data and show dialog when received
    // Set the callback for handling messages from the WebSocket provider
    final webSocketProvider =
        Provider.of<WebSocketProvider>(context, listen: false);
    // Future<void> showDecryptedDataDialog(String decryptedData) async {
    //   final Map<String, String> dataMap = {};
    //   decryptedData.split('&').forEach((pair) {
    //     final split = pair.split('=');
    //     if (split.length == 2) {
    //       dataMap[split[0]] = split[1];
    //     }
    //   });
    //
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: const Text('Decrypted Transaction Data'),
    //         content: SingleChildScrollView(
    //           child: DataTable(
    //             columns: const [
    //               DataColumn(label: Text('Key')),
    //               DataColumn(label: Text('Value')),
    //             ],
    //             rows: dataMap.entries
    //                 .map(
    //                   (entry) => DataRow(
    //                     cells: [
    //                       DataCell(Text(entry.key)),
    //                       DataCell(Text(entry.value)),
    //                     ],
    //                   ),
    //                 )
    //                 .toList(),
    //           ),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(),
    //             child: const Text('Close'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    // Update WebSocketProvider to use the showDialogCallback
    // webSocketProvider.showDialogCallback = showDecryptedDataDialog;
    // Listen to changes and perform navigation if needed
    // if (webSocketProvider.message.contains('redirect_to_page')) {
    //   // Perform the redirection if the message indicates to do so
    //   _performRedirect(context, webSocketProvider.message);
    // }
    // Set the callback to handle incoming decrypted data
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
                      color: webSocketProvider.isConnected
                          ? const Color(0xFF003323)
                          : Colors.red,
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
                    _buildNavItem(fontSizes, 'HOME'),
                    _buildNavItem(fontSizes, 'PRODUCTS'),
                    _buildNavItem(fontSizes, 'TECH'),
                    _buildNavItem(fontSizes, 'SOLUTIONS'),
                    _buildNavItem(fontSizes, 'VIDEOS'),
                    _buildNavItem(fontSizes, 'ABOUT US'),
                    Container(
                      width: MediaQuery.of(context).size.width / 6,
                      height: MediaQuery.of(context).size.height / 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF003323), // Outline color
                          width: 1, // Outline thickness
                        ),
                        borderRadius:
                            BorderRadius.circular(5.0), // Rounded corners
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment
                                  .center, // Centers content inside the container
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Search..',
                                  hintStyle: TextStyle(
                                      fontSize: fontSizes.smallerFontSize4),
                                  isDense:
                                      true, // Ensures consistent alignment for small spaces
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      10, 0, 0, 0), // Avoid extra padding
                                  border: InputBorder
                                      .none, // Removes default TextFormField border
                                ),
                                textAlignVertical: TextAlignVertical
                                    .center, // Vertically center-align text
                              ),
                            ),
                          ),
                          Text(
                            'All',
                            style: TextStyle(
                                color: const Color(0xFF003323),
                                fontSize: fontSizes.smallerFontSize4),
                          ),
                          const Icon(Icons.arrow_drop_down,
                              color: Color(0xFF003323)),
                          const SizedBox(width: 5.0),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF003323),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.search,
                                    color: Colors.white,
                                    size: fontSizes.smallerFontSize4),
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
                          _showCartDetailsDialog(context,
                              fontSizes); // Show the cart details dialog
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF003323),
                          shape: const CircleBorder(),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.shopping_cart,
                                color: Colors.white),
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
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 30,
                      height: MediaQuery.of(context).size.height / 30,
                      child: TextButton(
                        onPressed: () {
                          _showLoginDialog(
                              context); // Trigger the pop-up dialog
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, // Text color
                          backgroundColor: const Color(0xFF003323),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'LOGIN',
                          style:
                              TextStyle(fontSize: fontSizes.smallerFontSize6),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 500),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
                child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 25,
                  width: double.infinity,
                  color: const Color(0xFF003323),
                  child: Center(
                    child: Text(
                      'Get 20% Off for your first order above 1500 AED.',
                      style: TextStyle(
                          fontSize: fontSizes.smallerFontSize4,
                          color: Colors.white),
                    ),
                  ),
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
                        itemCount:
                            categories.length + 1, // Add 1 for the static box
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
                              trailing: (index - 1) ==
                                      4 // Adding a SALE tag for 'MOTORS'
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "SALE",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            color: Colors.white),
                                      ],
                                    )
                                  : const Icon(Icons.arrow_forward_ios,
                                      color: Colors.white),
                              onTap: () {
                                // Handle menu tap
                              },
                            );
                          }
                        },
                      ),
                    ), //LEFT MENU
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
                    ), //CENTER IMAGE SCROLL
                    Container(
                      height: MediaQuery.of(context).size.height / 1.75,
                      width: MediaQuery.of(context).size.width / 6,
                      color: const Color(0xFF003323),
                      child: ListView.separated(
                        itemCount: featuredProducts.length +
                            1, // Add 1 for the static box
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
                    ), //RIGHT MENU
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // 6 columns
                          crossAxisSpacing:
                              1.0, // Spacing between cards horizontally
                          mainAxisSpacing:
                              1.0, // Spacing between cards vertically
                          childAspectRatio:
                              1.75, // Adjusted to make the cards smaller
                        ),
                        itemCount: 20, // Number of items to display
                        itemBuilder: (context, index) {
                          return Card(
                            elevation:
                                10, // Slightly reduced elevation for a softer effect
                            child: Stack(
                              fit: StackFit
                                  .loose, // Ensure the stack takes the full card space
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        5), // Smaller rounded corners for the image as well
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/itemImages/${index + 1}.jpg'),
                                      fit: BoxFit
                                          .cover, // Ensures the image covers the entire container
                                    ),
                                    border: Border.all(
                                      // Adding border to the container
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
                                  bottom: 10,
                                  left: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItems[index], // Product title
                                        style: GoogleFonts.roboto(
                                          // Change the font to Roboto (you can choose other fonts here)
                                          color: Colors.white,
                                          fontSize: fontSizes
                                              .smallerFontSize4, // Slightly smaller text for the title
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'AED ${cartPricesAED[index].toStringAsFixed(2)}', // Display price in AED with two decimal places
                                        style: TextStyle(
                                          color: Colors.yellow,
                                          fontSize: fontSizes
                                              .smallerFontSize4, // Slightly smaller price text
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            Icons.star,
                                            color: starIndex < ratings[index]
                                                ? Colors.yellow
                                                : Colors.grey,
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
                                        icon: const Icon(Icons.remove,
                                            color: Colors.yellow),
                                        onPressed: () {
                                          setState(() {
                                            if (itemCounts[index] > 0) {
                                              itemCounts[
                                                  index]--; // Decrease item count
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
                                        icon: const Icon(Icons.add,
                                            color: Colors.yellow),
                                        onPressed: () {
                                          setState(() {
                                            itemCounts[
                                                index]++; // Increase item count
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
                ),
              ],
            )),
            if (_isChatBarVisible) buildChatBox(context),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _isChatBarVisible = !_isChatBarVisible;
              });
            },
            backgroundColor: const Color(0xFF003323),
            label: Text(
              "Chat",
              style: TextStyle(
                  color: Colors.white, fontSize: fontSizes.smallerFontSize4),
            ),
            icon: const Icon(Icons.chat, color: Colors.white),
            elevation: 5,
            hoverColor: const Color(0xFF004426),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            )),
      ),
    );
  }
}
