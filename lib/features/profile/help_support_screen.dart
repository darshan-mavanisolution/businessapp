import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../core/utils/app_launcher.dart';
import '../../core/services/remote_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I call a business or doctor?',
      'a': 'Simply tap the Call button on any card or detail screen. Your phone dialer will open with the number pre-filled.',
    },
    {
      'q': 'How do I get directions to a clinic or store?',
      'a': 'Tap "Directions" on the detail page or "Open in Google Maps" on the Location screen to view turn-by-turn routing.',
    },
    {
      'q': 'How do I filter businesses by rating or city?',
      'a': 'Use the filter chips at the top of the search and listing screens or tap the filter sliders icon to open all filter options.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future _loadFaqs() async {
    var res = await RemoteService.getFaqs();
    print("getFaqs Res--------->>>> $res");
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['faqs'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        setState(() {
          _faqs.clear();
          _faqs.addAll(list.map((item) => {
                'q': item['question']?.toString() ?? item['q']?.toString() ?? '',
                'a': item['answer']?.toString() ?? item['a']?.toString() ?? '',
              }));
        });
      }
    }
  }

  void _showInquiryDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Submit Support Ticket'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: messageCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message / Issue Details'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailCtrl.text.isEmpty || messageCtrl.text.isEmpty) {
                Get.snackbar('Error', 'Please fill in required fields');
                return;
              }
              Get.back();

              RemoteService.submitSupportInquiry(
                map: {
                  'name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'subject': subjectCtrl.text.trim(),
                  'message': messageCtrl.text.trim(),
                },
              );

              Get.snackbar(
                'Ticket Submitted',
                'Thank you! Our support team will reply within 24 hours.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
              );
            },
            child: const Text('Submit'),
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
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

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
          'Help & Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Direct Assistance?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Our support team is available 24/7 to help you resolve any issues.',
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => AppLauncher.makePhoneCall('+919876543210'),
                          icon: const Icon(Icons.phone_outlined, size: 16),
                          label: const Text('Call Helpline'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showInquiryDialog,
                          icon: const Icon(Icons.support_agent_rounded, size: 16),
                          label: const Text('Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQs Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ..._faqs.map((faq) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 1),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(
                    faq['q'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  iconColor: isDark ? Colors.white : Colors.black,
                  collapsedIconColor: textSecondary,
                  children: [
                    Text(
                      faq['a'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
