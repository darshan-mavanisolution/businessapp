import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class AppLauncher {
  /// Opens device dialer with the phone number
  static Future<void> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');
    if (cleanNumber.isEmpty) {
      Get.snackbar(
        'Invalid Phone Number',
        'No phone number available to call',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar(
        'Call Error',
        'Could not open dialer for $cleanNumber: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  /// Opens Google Maps with coordinates or search query
  static Future<void> openMap(double lat, double lng, String label) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Map Error',
          'Could not open Google Maps',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Map Error',
        'Could not launch maps: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Opens WhatsApp with message
  static Future<void> openWhatsApp(String phoneNumber, {String text = 'Hello, I found your business on BizFinder'}) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s+()-]'), '');
    final uri = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      Get.snackbar(
        'WhatsApp Error',
        'Could not open WhatsApp for $phoneNumber',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sends email via mailto
  static Future<void> sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Inquiry from BizFinder App'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Get.snackbar(
          'Email Error',
          'No email client found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Email Error',
        'Could not open email client',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Shares business info
  static Future<void> shareBusiness({
    required String name,
    required String specialty,
    required String address,
    required String phone,
  }) async {
    final text = 'Check out $name ($specialty) on BizFinder!\n\n'
        'Address: $address\n'
        'Contact: $phone\n\n'
        'Discover more trusted professionals on BizFinder app.';
    await Share.share(text, subject: '$name on BizFinder');
  }
}
