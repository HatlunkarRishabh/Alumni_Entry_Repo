import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  String qrResult = 'Status';
  String status = 'Details';
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Theme(
      data: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Attendance'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              icon: isDarkMode
                  ? const Icon(Icons.nightlight_round)
                  : const Icon(Icons.wb_sunny_rounded),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(status,style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'Dosis',// Replace with your custom font
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 30),
              Text(qrResult, style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'Dosis',// Replace with your custom font
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),),
              const SizedBox(height: 50),
              ElevatedButton(onPressed: scanQR,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200.0, 50.0), // Adjust width and height as needed
                ),
                child: const Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 20.0,
                  fontFamily: 'Dosis',// Replace with your custom font
                  fontWeight: FontWeight.bold,
                  ),// Adjust font size as needed
                ),),
              const SizedBox(height: 30),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await checkNetworkConnectivity();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100.0, 25.0),
                  backgroundColor: isDarkMode ? Colors.grey[950] : Colors.white,
                  foregroundColor: isDarkMode ? Colors.white : Colors.black,

                ),
                child: const Text(
                  'TroubleShoot',
                  style: TextStyle(

                    fontFamily: 'Dosis',
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),

            ],

    ),),
    ),
    );
  }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      setState(() {
        qrResult = qrCode.toString();
        result();
      });
    } on PlatformException {
      qrResult = 'Fail to read QR Code';
    }
  }

  Future<void> result() async {
    setState(() {
      status = 'Processing Request';
    });
    try {
      final serviceAccountCredentials =
      auth.ServiceAccountCredentials.fromJson({
          "Json file for project is required here", 
          "Not given json file due to privacy issues..."
      });

      final client = await auth.clientViaServiceAccount(
        serviceAccountCredentials,
        [
          sheets.SheetsApi.driveScope,
          sheets.SheetsApi.spreadsheetsReadonlyScope
        ],
      );

      final sheetsApi = sheets.SheetsApi(client);

      const spreadsheetId = '19MnTMX_QZY4vliKT1UYYpu4vizSxfRdTwQeFDXyVX6s';
      const rangeUniqueKey = 'Alumni1!E2:E'; // Adjust the sheet name and column as needed
      const rangeStatus = 'Alumni1!H2:H'; // Adjust the sheet name and column as needed

      // Fetch the values from UniqueKey and Status columns
      final responseUniqueKey = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, rangeUniqueKey);
      final responseStatus = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, rangeStatus);

      final allUniqueKeyValues = responseUniqueKey.values;
      final allStatusValues = responseStatus.values;

      // Check if the scanned QR code matches any value in the "UniqueKey" column
      for (int i = 0; i < allUniqueKeyValues!.length; i++) {
        final cellValueUniqueKey = allUniqueKeyValues[i].first;
        final cellValueStatus = allStatusValues?[i].first;

        if (cellValueUniqueKey == qrResult) {
          if (cellValueStatus=='NOT CHECKED') {
            // QR code matches, update the corresponding row's "Status" column
            final rowNumber = i +
                2; // Adjusted row number since your data starts from row 2
            final cellToUpdateStatus = 'Alumni1!H$rowNumber'; // Assuming "Status" is in column F
            const valueToWriteStatus = 'CHECKED IN';
            final valueRangeStatus = sheets.ValueRange(
                values: [[valueToWriteStatus]]);
            await sheetsApi.spreadsheets.values.update(
              valueRangeStatus,
              spreadsheetId,
              cellToUpdateStatus,
              valueInputOption: 'RAW', // Use 'RAW' if your data doesn't need to be interpreted
            );

            setState(() {
              status = 'Registration Successful';
              qrResult = 'Entry Granted';
            });
            return; // Exit the function after updating the status
          } else {
            // Status is already 'YES'
            setState(() {
              status = 'Redundant Request';
              qrResult = 'Entry Denied';
            });
            return; // Exit the function as the entry is already done
          }
        }
      }

      // If the loop completes without finding a matching UniqueKey
      setState(() {
        status = 'QR Code not found in UniqueKey column';
        qrResult = 'Unauthorized/Invalid QR Code';
      });
    } catch (e) {
      setState(() {
        status = 'exception caught: $e';
        qrResult = 'Fail to read QR Code';
      });
    }
  }

  Future<void> checkNetworkConnectivity() async {
    setState(() {
      status = 'TroubleShooting Issues';
      qrResult = 'Please Wait';
    });
    try {
      final response = await http.get(Uri.parse("https://www.google.com"));
      if (response.statusCode == 200) {
        // Internet connectivity is available, force stop and clear app data
        _showawarn();
      } else {
        // No internet connectivity
        _showNetworkError();
      }
    } catch (e) {
      // An error occurred, assuming no internet connectivity
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    setState(() {
      status = 'TroubleShooter found issues with Network Connectivity';
      qrResult = 'Please check your internet connection\n  or try switching to another network';
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Network Error"),
          content: const Text("Seems like a Network Issue. Please check your internet connection or try switching to another network."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showawarn() {
    setState(() {
      status = 'TroubleShoot was not able to Identify the Issue.';
      qrResult = 'Try Advanced TroubleShooting or contact the Developer';
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Troubleshooter wasn't able to identify the problem"),
          content: const Text("Running Advanced TroubleShooting. \n\nWARNING: This Process will Delete all the Application data, cache and will force stop the Application. \nIf this doesn't solves your issue try contacting the developer"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _forceStopAndClearData();
              },
              child: const Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  void _forceStopAndClearData() {
    // This will terminate the app and clear its data
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
