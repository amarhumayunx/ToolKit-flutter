// provider/saved_cv_provider.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_cv.dart';

class SavedCVProvider with ChangeNotifier {
  List<SavedCV> _savedCVs = [];
  final String _prefsKey = 'saved_cvs';

  List<SavedCV> get savedCVs => _savedCVs;

  SavedCVProvider() {
    _loadSavedCVs();
  }

  // Load saved CVs from SharedPreferences
  Future<void> _loadSavedCVs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCVsJson = prefs.getStringList(_prefsKey) ?? [];

      _savedCVs = [];

      for (var cvJson in savedCVsJson) {
        final cvMap = jsonDecode(cvJson) as Map<String, dynamic>;

        // Try to load thumbnail if it exists
        Uint8List? thumbnailBytes;
        try {
          final thumbFile = File('${cvMap['filePath']}_thumb.png');
          if (await thumbFile.exists()) {
            thumbnailBytes = await thumbFile.readAsBytes();
          }
        } catch (e) {
          print('Error loading thumbnail: $e');
        }

        _savedCVs.add(SavedCV.fromMap(cvMap, thumbBytes: thumbnailBytes));
      }

      notifyListeners();
    } catch (e) {
      print('Error loading saved CVs: $e');
    }
  }

  // Save CVs to SharedPreferences
  Future<void> _saveCVsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCVsJson = _savedCVs.map((cv) => jsonEncode(cv.toMap())).toList();
      await prefs.setStringList(_prefsKey, savedCVsJson);
    } catch (e) {
      print('Error saving CVs to prefs: $e');
    }
  }

  // Add a new saved CV
  Future<void> addSavedCV(String fileName, String filePath, Uint8List? thumbnailBytes) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final dateTime = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)} | '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}${now.hour >= 12 ? 'pm' : 'am'}';

      // Get file size
      final file = File(filePath);
      final fileSize = await file.length();
      final fileSizeString = _formatFileSize(fileSize);

      // Save thumbnail if available
      if (thumbnailBytes != null) {
        // Save thumbnail with a consistent naming convention
        final thumbFile = File('${filePath}_thumb.png');
        await thumbFile.writeAsBytes(thumbnailBytes);
      }

      final savedCV = SavedCV(
        id: uuid,
        fileName: fileName,
        dateTime: dateTime,
        fileSize: fileSizeString,
        thumbnailBytes: thumbnailBytes,
        filePath: filePath,
      );

      _savedCVs.add(savedCV);
      await _saveCVsToPrefs();
      notifyListeners();
    } catch (e) {
      print('Error adding saved CV: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Format file size to readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Delete a saved CV
  Future<void> deleteSavedCV(String id) async {
    try {
      final cvToDelete = _savedCVs.firstWhere((cv) => cv.id == id);

      // Delete the actual file
      final file = File(cvToDelete.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete thumbnail if it exists
      final thumbFile = File('${cvToDelete.filePath}_thumb.png');
      if (await thumbFile.exists()) {
        await thumbFile.delete();
      }

      _savedCVs.removeWhere((cv) => cv.id == id);
      await _saveCVsToPrefs();
      notifyListeners();
    } catch (e) {
      print('Error deleting saved CV: $e');
    }
  }
}