import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../core/services/remote_service.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  String? _termsContent;
  String? _privacyContent;

  @override
  void initState() {
    super.initState();
    _loadLegal();
  }

  Future _loadLegal() async {
    var termsRes = await RemoteService.getLegalPolicy(type: 'terms');
    print("termsRes Res--------->>>> $termsRes");
    var privRes = await RemoteService.getLegalPolicy(type: 'privacy');
    print("privRes Res--------->>>> $privRes");

    if (mounted) {
      setState(() {
        if (termsRes != null && (termsRes['success'] == true || termsRes['status'] == 200)) {
          final data = termsRes['data'] ?? termsRes;
          if (data is Map && data['content'] != null) {
            _termsContent = data['content'].toString();
          } else if (data is String) {
            _termsContent = data;
          }
        }
        if (privRes != null && (privRes['success'] == true || privRes['status'] == 200)) {
          final data = privRes['data'] ?? privRes;
          if (data is Map && data['content'] != null) {
            _privacyContent = data['content'].toString();
          } else if (data is String) {
            _privacyContent = data;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Terms & Privacy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: textSecondary,
            indicatorColor: isDark ? Colors.white : Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildContent(
              title: 'BizFinder Terms of Service',
              updatedDate: 'Last updated: October 2026',
              customContent: _termsContent,
              paragraphs: const [
                '1. Acceptance of Terms: By accessing or using BizFinder, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
                '2. Service Description: BizFinder connects users with trusted local businesses, professionals, and healthcare providers across Gujarat and India.',
                '3. User Responsibilities: You agree to use the service for lawful personal purposes and not to misuse contact details or submit false ratings.',
                '4. Business Listings: While we strive to maintain accurate business hours, ratings, and contact info, businesses are independently operated.',
                '5. Limitation of Liability: BizFinder is not liable for direct or indirect disputes arising between users and independent service providers.',
              ],
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _buildContent(
              title: 'BizFinder Privacy Policy',
              updatedDate: 'Last updated: October 2026',
              customContent: _privacyContent,
              paragraphs: const [
                '1. Information We Collect: We collect your name, verified email, and approximate city location to show relevant nearby services.',
                '2. How We Use Information: To authenticate your account, recommend trusted businesses, and allow communication with listed vendors.',
                '3. Data Protection: We do not sell your personal data to third parties. All network communications are encrypted.',
                '4. User Rights: You have the right to request deletion of your account and personal data at any time from the Profile settings.',
                '5. Contact: For privacy questions, reach out to privacy@bizfinder.app.',
              ],
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required String title,
    required String updatedDate,
    String? customContent,
    required List<String> paragraphs,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          updatedDate,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        if (customContent != null && customContent.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              customContent,
              style: TextStyle(
                fontSize: 13.5,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          )
        else
          ...paragraphs.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 13.5,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
