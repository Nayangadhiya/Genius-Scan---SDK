import 'package:flutter/material.dart';

class ScanProvider with ChangeNotifier {
  String _documentUrl = '';
  String _extractedText = '';
  bool _isLoading = false;
  bool _isLicenseSet = false;

  String get documentUrl => _documentUrl;
  String get extractedText => _extractedText;
  bool get isLoading => _isLoading;
  bool get isLicenseSet => _isLicenseSet;

  void setLicenseKey(bool value) {
    _isLicenseSet = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setDocumentUrl(String url) {
    _documentUrl = url;
    notifyListeners();
  }

  void setExtractedText(String text) {
    _extractedText = text;
    notifyListeners();
  }
}
