import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_genius_scan/flutter_genius_scan.dart';
import 'package:open_filex/open_filex.dart';
import 'package:project/Provider/scan_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setLicenseKey();
    });
  }

  Future<void> setLicenseKey() async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    try {
      FlutterGeniusScan.setLicenseKey(
          '533c5007565209080653055739525a0e4a064a145158415c01574412424a551e0344143d090204035c0502005450');
      scanProvider.setLicenseKey(true);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting license key: ${e.message}')),
      );
    }
  }

  Future<void> openScanner(BuildContext context) async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);

    if (!scanProvider.isLicenseSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License key not set. Please try again.')),
      );
      return;
    }

    scanProvider.setLoading(true);

    try {
      var scanConfiguration = {
        'source': 'camera',
        'multiPage': false,
        'ocr': true,
        'ocrConfiguration': {
          'languages': ['en-US'],
        },
      };
      var scanResult =
          await FlutterGeniusScan.scanWithConfiguration(scanConfiguration);

      debugPrint('Scan result: $scanResult');

      String? documentUrl = scanResult['multiPageDocumentUrl'];
      List<dynamic>? scans = scanResult['scans'];

      if (scans != null && scans.isNotEmpty) {
        String extractedText = scans
            .map((scan) => scan['ocrResult'] != null
                ? scan['ocrResult']['text'].toString()
                : '')
            .join('\n');
        debugPrint('Extracted text: $extractedText');

        scanProvider.setDocumentUrl(documentUrl ?? '');
        scanProvider.setExtractedText(extractedText);

        if (documentUrl != null && documentUrl.isNotEmpty) {
          await OpenFilex.open(documentUrl.replaceAll('file://', ''));
        }
      } else {
        debugPrint('No OCR results found');
        scanProvider.setExtractedText('No text extracted');
      }
    } on PlatformException catch (e) {
      debugPrint('Error: ${e.message}');
      scanProvider.setExtractedText('Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      scanProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Genius Scan Demo')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed:
                  scanProvider.isLoading ? null : () => openScanner(context),
              child: const Text('Scan me'),
            ),
            if (scanProvider.isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            if (scanProvider.extractedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  scanProvider.extractedText,
                  style: const TextStyle(fontSize: 16, color: Colors.teal),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
