import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../core/widgets/business_card.dart';
import '../../data/models/business_model.dart';
import '../business_listing/business_controller.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/remote_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final List<BusinessModel> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future _loadListings() async {
    var res = await RemoteService.getUserBusinesses();
    print("getUserBusinesses Res--------->>>> $res");
    if (res != null && (res['success'] == true || res['status'] == 200 || res['data'] != null)) {
      final list = (res['data'] ?? res['businesses'] ?? res['listings']) as List?;
      if (list != null && list.isNotEmpty) {
        setState(() {
          _listings.clear();
          _listings.addAll(list.map((b) => BusinessModel.fromJson(Map<String, dynamic>.from(b))));
        });
        return;
      }
    }

    var vRes = await RemoteService.getVendorListings();
    if (vRes != null && (vRes['success'] == true || vRes['status'] == 200)) {
      final list = (vRes['data'] ?? vRes['listings']) as List?;
      if (list != null && list.isNotEmpty) {
        setState(() {
          _listings.clear();
          _listings.addAll(list.map((b) => BusinessModel.fromJson(Map<String, dynamic>.from(b))));
        });
        return;
      }
    }

    final businessController = Get.find<BusinessController>();
    if (_listings.isEmpty && businessController.allBusinesses.isNotEmpty) {
      setState(() {
        _listings.addAll(businessController.allBusinesses.take(3));
      });
    }
  }

  void _confirmDeleteListing(BusinessModel b) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete "${b.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              final res = await RemoteService.deleteVendorListing(id: b.id);
              if (res != null && (res['success'] == true || res['status'] == 200 || res['status'] == 204)) {
                setState(() => _listings.removeWhere((item) => item.id == b.id));
                Get.snackbar(
                  'Deleted',
                  'Listing was removed successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF10B981),
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditListingDialog(BusinessModel b) {
    final specialtyCtrl = TextEditingController(text: b.specialty);
    final closeTimeCtrl = TextEditingController(text: b.closingTime);

    Get.dialog(
      AlertDialog(
        title: Text('Edit "${b.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: specialtyCtrl, decoration: const InputDecoration(labelText: 'Specialty')),
            TextField(controller: closeTimeCtrl, decoration: const InputDecoration(labelText: 'Closing Time (e.g. 09:00 PM)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final fields = {
                if (specialtyCtrl.text.trim().isNotEmpty) 'specialty': specialtyCtrl.text.trim(),
                if (closeTimeCtrl.text.trim().isNotEmpty) 'closingTime': closeTimeCtrl.text.trim(),
              };
              final res = await RemoteService.updateVendorListing(id: b.id, map: fields);
              if (res != null && (res['success'] == true || res['status'] == 200)) {
                _loadListings();
                Get.snackbar('Updated', 'Listing updated successfully',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Listings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadListings,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              ..._listings.map((b) => Column(
                    children: [
                      BusinessCard(business: b),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 10, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditListingDialog(b),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmDeleteListing(b),
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                              label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 10),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.createBusiness)?.then((_) => _loadListings()),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Add New Business Listing'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
