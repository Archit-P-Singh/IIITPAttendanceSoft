import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'local_database_helper.dart';
import 'dart:convert';

class OfflineSyncService {
  final String backendUrl = 'http://localhost:8080/api'; // Replace with actual IP if running on physical device

  // Check if device is connected to the internet
  Future<bool> hasNetworkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Attempt to sync all pending offline scans to the backend
  Future<void> syncPendingScans() async {
    bool isConnected = await hasNetworkConnection();
    if (!isConnected) return; // Still offline, do nothing

    final pendingScans = await LocalDatabaseHelper.instance.getPendingScans();
    if (pendingScans.isEmpty) return; // Nothing to sync

    print('Attempting to sync ${pendingScans.length} offline scans...');

    bool allSynced = true;

    // A real production app might use a bulk API endpoint, but we'll simulate individual requests for now
    for (var scan in pendingScans) {
      final qrCode = scan['qr_code'];
      try {
        final response = await http.post(
          Uri.parse('$backendUrl/attendance/mark?qrCode=$qrCode'),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          allSynced = false;
          print('Failed to sync QR: $qrCode');
        }
      } catch (e) {
        allSynced = false;
        print('Error syncing QR $qrCode: $e');
      }
    }

    if (allSynced) {
      print('All offline scans synced successfully!');
      await LocalDatabaseHelper.instance.clearPendingScans();
    } else {
      print('Some scans failed to sync. They will remain in local storage.');
      // In a real app, you'd selectively delete only the successful ones, 
      // but for this B.Tech project demo, we will keep it simple.
    }
  }

  // Modified markAttendance to use Offline-First approach
  Future<String> markAttendance(String qrCode) async {
    bool isConnected = await hasNetworkConnection();
    
    if (isConnected) {
      // Online: Sync any pending background scans first, then make the direct request
      await syncPendingScans();
      try {
        final response = await http.post(
          Uri.parse('$backendUrl/attendance/mark?qrCode=$qrCode'),
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          return "Attendance Marked Successfully!";
        } else {
          return "Error from Server: ${response.body}";
        }
      } catch (e) {
        // Fallback if the request failed despite having an active network connection (e.g. backend down)
        await LocalDatabaseHelper.instance.insertPendingScan(qrCode);
        return "Backend unreachable. Saved offline!";
      }
    } else {
      // Offline: Save to local database
      await LocalDatabaseHelper.instance.insertPendingScan(qrCode);
      return "No internet connection. Saved offline for later sync!";
    }
  }
}
