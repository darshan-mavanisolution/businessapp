import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/user_model.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/remote_service.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final String _authKey = 'isLoggedIn';
  final String _userKey = 'currentUser';
  final String _tokenKey = 'accessToken';
  final String _refreshKey = 'refreshToken';

  // Login tab (Email OTP)
  final RxInt selectedLoginTab = 1.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxString selectedCountryCode = '+91'.obs;

  // OTP State
  final RxList<String> otpDigits = <String>['', '', '', '', '', ''].obs;
  final RxInt currentOtpIndex = 0.obs;
  final RxInt resendCountdown = 30.obs;
  final RxBool canResend = false.obs;
  final RxBool isLoading = false.obs;
  Timer? _timer;

  // Current User
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.text = '98765 43210';
    emailController.text = 'darshan.pambhar@gmail.com';

    final storedToken = _storage.read<String>(_tokenKey) ?? '';
    if (storedToken.isNotEmpty) {
      RemoteService.initializeAuthHeader(token: storedToken);
    }

    final storedLoggedIn = _storage.read<bool>(_authKey) ?? false;
    isLoggedIn.value = storedLoggedIn;
    final storedUser = _storage.read(_userKey);
    if (storedUser != null && storedUser is Map<String, dynamic>) {
      currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(storedUser));
    } else {
      currentUser.value = const UserModel(
        id: 'usr_1',
        name: 'Darshan Pambhar',
        phoneNumber: '+91 98765 43210',
        email: 'darshan.pambhar@gmail.com',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=600&auto=format&fit=crop&q=80',
      );
    }

    if (isLoggedIn.value) {
      fetchUserProfile();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void startResendTimer() {
    _timer?.cancel();
    resendCountdown.value = 30;
    canResend.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void resetOtp() {
    otpDigits.value = ['', '', '', '', '', ''];
    currentOtpIndex.value = 0;
    startResendTimer();
  }

  void enterDigit(String digit) {
    for (int i = 0; i < 6; i++) {
      if (otpDigits[i].isEmpty) {
        otpDigits[i] = digit;
        currentOtpIndex.value = i + 1;
        break;
      }
    }

    if (otpDigits.every((d) => d.isNotEmpty)) {
      verifyOtp();
    }
  }

  void deleteDigit() {
    for (int i = 5; i >= 0; i--) {
      if (otpDigits[i].isNotEmpty) {
        otpDigits[i] = '';
        currentOtpIndex.value = i;
        break;
      }
    }
  }

  // ==========================================
  // API Calls matching User Structure
  // ==========================================
  Future sendOtp({Map<String, dynamic>? map}) async {
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      errorSnackbar(title: 'Validation Error', subtitle: 'Please enter a valid email address');
      return {"status": 400, "message": "Invalid email"};
    }

    isLoading.value = true;
    final payload = map ?? {"email": email};
    var res = await RemoteService.sendOtp(map: payload);
    print("sendOtp Res--------->>>> $res");
    isLoading.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200 || res['status'] == 201 || res['data'] != null)) {
      resetOtp();
      Get.toNamed(AppRoutes.otp);
      Get.snackbar(
        'OTP Sent',
        res['message']?.toString() ?? 'A 6-digit verification code has been sent to $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      errorSnackbar(
        title: 'Error',
        subtitle: res?['message']?.toString() ?? 'Failed to send OTP. Please try again.',
      );
    }
    return res;
  }

  Future verifyOtp({Map<String, dynamic>? map}) async {
    final enteredOtp = otpDigits.join('');
    if (enteredOtp.length < 6) {
      errorSnackbar(title: 'Incomplete OTP', subtitle: 'Please enter all 6 digits');
      return {"status": 400, "message": "Incomplete OTP"};
    }

    isLoading.value = true;
    final payload = map ?? {
      "email": emailController.text.trim(),
      "otp": enteredOtp,
    };

    var res = await RemoteService.verifyOtp(map: payload);
    print("verifyOtp Res--------->>>> $res");
    isLoading.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200 || res['data'] != null)) {
      final data = res['data'] ?? res;
      final token = data['accessToken']?.toString() ?? data['token']?.toString() ?? '';
      final refresh = data['refreshToken']?.toString() ?? '';
      if (token.isNotEmpty) {
        _storage.write(_tokenKey, token);
        RemoteService.initializeAuthHeader(token: token);
      }
      if (refresh.isNotEmpty) {
        _storage.write(_refreshKey, refresh);
      }

      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
        _storage.write(_userKey, currentUser.value?.toJson());
      }

      // Mark as logged in
      isLoggedIn.value = true;
      _storage.write(_authKey, true);

      // Fetch fresh profile in background
      fetchUserProfile();

      Get.snackbar(
        'Verification Successful',
        'Welcome back, ${currentUser.value?.name ?? "User"}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed(AppRoutes.mainNav);
      });
    } else {
      errorSnackbar(
        title: 'Verification Failed',
        subtitle: res?['message']?.toString() ?? 'Invalid verification code',
      );
    }

    return res;
  }

  Future fetchUserProfile() async {
    var res = await RemoteService.getUserProfile();
    print("fetchUserProfile Res--------->>>> $res");
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final userData = res['data'] ?? res['user'] ?? res;
      if (userData is Map<String, dynamic>) {
        currentUser.value = UserModel.fromJson(userData);
        _storage.write(_userKey, currentUser.value?.toJson());
      }
    }
    return res;
  }

  Future googleSignIn({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    var res = await RemoteService.googleSignIn(map: map ?? {"idToken": "mock_google_id_token"});
    print("googleSignIn Res--------->>>> $res");
    isLoading.value = false;

    isLoggedIn.value = true;
    _storage.write(_authKey, true);
    Get.offAllNamed(AppRoutes.mainNav);
    return res;
  }

  void signInWithGoogle() {
    googleSignIn();
  }

  Future appleSignIn({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    var res = await RemoteService.appleSignIn(
      map: map ?? {
        "identityToken": "mock_apple_token",
        "authorizationCode": "mock_auth_code",
        "fullName": "Darshan Pambhar"
      },
    );
    print("appleSignIn Res--------->>>> $res");
    isLoading.value = false;

    isLoggedIn.value = true;
    _storage.write(_authKey, true);
    Get.offAllNamed(AppRoutes.mainNav);
    return res;
  }

  void signInWithApple() {
    appleSignIn();
  }

  Future updateProfile({required String name, required String phone, required String email, String? avatarPath}) async {
    isLoading.value = true;
    var res = await RemoteService.updateUserProfile(
      fields: {
        "name": name,
        "phoneNumber": phone,
      },
      avatarFilePath: avatarPath,
    );
    print("updateProfile Res--------->>>> $res");
    isLoading.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200 || res['data'] != null)) {
      final data = res['data'] ?? res['user'] ?? res;
      if (data is Map<String, dynamic>) {
        currentUser.value = UserModel.fromJson(data);
        _storage.write(_userKey, currentUser.value?.toJson());
      } else if (currentUser.value != null) {
        final updated = currentUser.value!.copyWith(
          name: name,
          phoneNumber: phone,
          email: email,
        );
        currentUser.value = updated;
        _storage.write(_userKey, updated.toJson());
      }
      fetchUserProfile();
      Get.snackbar(
        'Profile Updated',
        res['message']?.toString() ?? 'Your profile changes have been saved',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } else {
      errorSnackbar(
        title: 'Update Failed',
        subtitle: res?['message']?.toString() ?? 'Could not update profile',
      );
    }
    return res;
  }

  Future deleteAccount() async {
    isLoading.value = true;
    var res = await RemoteService.deleteUserAccount();
    print("deleteAccount Res--------->>>> $res");
    isLoading.value = false;
    logout();
    return res;
  }

  void logout() {
    isLoggedIn.value = false;
    _storage.write(_authKey, false);
    _storage.remove(_tokenKey);
    _storage.remove(_refreshKey);
    RemoteService.initializeAuthHeader(token: '');
    _timer?.cancel();
    Get.offAllNamed(AppRoutes.login);
  }
}
