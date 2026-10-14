import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/themes/app_colors.dart';
import '../authentication/auth_controller.dart';
import '../../core/widgets/app_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final authController = Get.find<AuthController>();
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  File? _selectedAvatar;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = authController.currentUser.value;
    nameController = TextEditingController(text: user?.name ?? 'Darshan Pambhar');
    phoneController = TextEditingController(text: user?.phoneNumber ?? '+91 98765 43210');
    emailController = TextEditingController(text: user?.email ?? 'darshan.pambhar@gmail.com');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: textPrimary),
              title: Text('Choose from Gallery', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
              onTap: () async {
                Get.back();
                final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (picked != null) {
                  setState(() => _selectedAvatar = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: textPrimary),
              title: Text('Take a Photo', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
              onTap: () async {
                Get.back();
                final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (picked != null) {
                  setState(() => _selectedAvatar = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final saveBtnBg = isDark ? Colors.white : Colors.black;
    final saveBtnText = isDark ? Colors.black : Colors.white;

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
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Avatar with camera change button
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    if (_selectedAvatar != null)
                      ClipOval(
                        child: Image.file(
                          _selectedAvatar!,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      AppAvatar(
                        imageUrl: authController.currentUser.value?.avatarUrl ?? '',
                        initials: 'DP',
                        size: 88,
                        isCircle: true,
                      ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: saveBtnBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: bg, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: saveBtnText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Full Name field
              _buildInputField(
                label: 'Full Name',
                controller: nameController,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                cardBg: cardBg,
                border: border,
              ),

              const SizedBox(height: 18),

              // Phone Number field
              _buildInputField(
                label: 'Phone Number',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                cardBg: cardBg,
                border: border,
              ),

              const SizedBox(height: 18),

              // Email Address field
              _buildInputField(
                label: 'Email Address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                cardBg: cardBg,
                border: border,
              ),

              const SizedBox(height: 36),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    authController.updateProfile(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      avatarPath: _selectedAvatar?.path,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saveBtnBg,
                    foregroundColor: saveBtnText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: saveBtnText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color border,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
