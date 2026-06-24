import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/bindings/initial_binding.dart';
import '../../../shared/widgets/alert_widgets.dart';
import '../../activity/activity_controller.dart';
import '../../expenses/add_expense_controller.dart';
import '../../friends/friends_controller.dart';
import '../../groups/Controllers/groups_controller.dart';
import '../../navigation/nav_controller.dart';
import '../../navigation/navigation_view.dart';
import '../../profile/profile_controller.dart';
import '../Views/login_view.dart';
import '../Views/verify_email_view.dart';
import '../Views/verify_phone_view.dart';
import '../auth_services.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();
  final storage = const FlutterSecureStorage();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final forgotEmailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  RxBool isLoggedIn = false.obs;
  var isLoading = false.obs;
  RxBool isPhoneLogin = false.obs;
  RxString pendingPhone = ''.obs;
  RxString completePhone = ''.obs;

  // Field-level validation errors
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  void _clearErrors() => fieldErrors.clear();

  // Returns true if valid, false if not
  bool _validateRegister() {
    fieldErrors.clear();
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (name.length < 2)
      fieldErrors['name'] = 'Name must be at least 2 characters';
    if (!GetUtils.isEmail(email))
      fieldErrors['email'] = 'Enter a valid email address';
    if (pass.length < 8)
      fieldErrors['password'] = 'Password must be at least 8 characters';
    else if (!pass.contains(RegExp(r'[0-9]')) ||
        !pass.contains(RegExp(r'[a-zA-Z]')))
      fieldErrors['password'] = 'Password must contain letters and numbers';

    return fieldErrors.isEmpty;
  }

  bool _validateLogin() {
    fieldErrors.clear();
    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      fieldErrors['email'] = 'Enter a valid email address';
    }
    if (passCtrl.text.isEmpty) {
      fieldErrors['password'] = 'Password cannot be empty';
    }
    return fieldErrors.isEmpty;
  }

  // ✅ Just reads token, NO navigation
  Future<void> checkLogin() async {
    final token = await storage.read(key: "token");
    isLoggedIn.value = token != null;
  }

  Future login() async {
    try {
      if (!_validateLogin()) return;
      isLoading.value = true;

      final res = await _service.login(
        emailCtrl.text,
        passCtrl.text,
      );

      final token = res["token"];
      await storage.write(key: "token", value: token);

      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      Get.closeAllSnackbars();

      ensureAppControllers();
      try {
        await Get.find<ProfileController>().getUserDetails();
      } catch (_) {
        // login succeeded + token stored; profile will refetch inside the app
      }

      loadInitialAppData();
      Get.offAll(() => NavigationView());
      emailCtrl.clear();
      passCtrl.clear();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final email = emailCtrl.text.trim();
        Get.to(() => VerifyEmailView(email: email));
      } else {
        final message = e.response?.data['message'] ?? 'Login failed';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Login failed",
            snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future register() async {
    try {
      if (!_validateRegister()) return;
      isLoading.value = true;

      final res = await _service.register(
        nameCtrl.text,
        emailCtrl.text,
        passCtrl.text,
      );

      final email = res['email'] as String? ?? emailCtrl.text.trim();
      Get.off(() => VerifyEmailView(email: email));
      nameCtrl.clear();
      emailCtrl.clear();
      passCtrl.clear();
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Registration failed';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Registration failed",
            snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> forgotPassword() async {
    fieldErrors.clear();
    if (!GetUtils.isEmail(forgotEmailCtrl.text.trim())) {
      fieldErrors['forgotEmail'] = 'Enter a valid email address';
      return false;
    }
    try {
      isLoading.value = true;
      await _service.forgotPassword(forgotEmailCtrl.text.trim());
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map ? data['message'] as String? : null) ??
          'Something went wrong';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
      });
      return false;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Something went wrong",
            snackPosition: SnackPosition.BOTTOM);
      });
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future resendVerification(String email) async {
    try {
      isLoading.value = true;
      await _service.resendVerification(email);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Email sent", "Check your inbox for the verification link",
            snackPosition: SnackPosition.BOTTOM);
      });
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Could not resend email';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Could not resend email",
            snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerWithPhone() async {
    final name = nameCtrl.text.trim();
    final phone = completePhone.value.trim();
    final password = passCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      AlertWidgets.showSnackBar(message: 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;
      final res = await _service.registerWithPhone(
        name: name,
        phone: phone,
        password: password,
      );
      if (res['requiresPhoneVerification'] == true) {
        pendingPhone.value = phone;
        nameCtrl.clear();
        passCtrl.clear();
        completePhone.value = '';
        Get.to(
          () => VerifyPhoneView(phone: phone, otpAlreadySent: true),
        );
      }
    } catch (e) {
      String message = 'Something went wrong. Please try again.';
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        } else if (e.response!.statusCode == 401) {
          message = 'Invalid phone number or password';
        } else if (e.response!.statusCode == 404) {
          message = 'No account found with this phone number';
        }
      }
      AlertWidgets.showSnackBar(message: message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: Platform.isIOS
            ? '404438906252-cvm8dtcld1ae0soujl0asiauhohj8m6g.apps.googleusercontent.com' // iOS client ID
            : null, // Android uses serverClientId only
        // web client (backend audience) — both platforms
        serverClientId:
            '404438906252-1busgkil24ede462vfbqd5pq1tieu8jl.apps.googleusercontent.com',
      );
      final GoogleSignInAccount account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        AlertWidgets.showSnackBar(message: 'Google sign-in failed');
        return;
      }

      final res = await _service.googleAuth(idToken);
      await storage.write(key: 'token', value: res['token']);

      ensureAppControllers();
      try {
        await Get.find<ProfileController>().getUserDetails();
      } catch (_) {}
      loadInitialAppData();
      Get.offAll(() => NavigationView());
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        AlertWidgets.showSnackBar(message: 'Google sign-in failed');
      }
      // canceled → silent, user backed out
    } catch (e) {
      AlertWidgets.showSnackBar(message: 'Google sign-in failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        AlertWidgets.showSnackBar(message: 'Apple sign-in failed');
        return;
      }

      // Apple sends name ONLY on first sign-in — capture it
      final name = [credential.givenName, credential.familyName]
          .where((p) => p != null && p.isNotEmpty)
          .join(' ');

      final res = await _service.appleAuth(idToken, name.isEmpty ? null : name);
      await storage.write(key: 'token', value: res['token']);

      ensureAppControllers();
      try {
        await Get.find<ProfileController>().getUserDetails();
      } catch (_) {}
      loadInitialAppData();
      Get.offAll(() => NavigationView());
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        AlertWidgets.showSnackBar(message: 'Apple sign-in failed');
      }
    } catch (e) {
      AlertWidgets.showSnackBar(message: 'Apple sign-in failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithPhone() async {
    final phone = completePhone.value.trim();
    final password = passCtrl.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      AlertWidgets.showSnackBar(message: 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;
      final res = await _service.loginWithPhone(
        phone: phone,
        password: password,
      );
      if (res['requiresPhoneVerification'] == true) {
        final verifyPhone = res['phone'] as String? ?? phone;
        pendingPhone.value = verifyPhone;
        phoneCtrl.clear();
        passCtrl.clear();
        AlertWidgets.showSnackBar(
          message: res['message'] ?? 'Please verify your phone number',
        );
        Get.to(
          () => VerifyPhoneView(phone: verifyPhone, otpAlreadySent: false),
        );
        return;
      }
      await storage.write(key: 'token', value: res['token']);
      completePhone.value = '';
      passCtrl.clear();

      ensureAppControllers();
      try {
        await Get.find<ProfileController>().getUserDetails();
      } catch (_) {
        // login succeeded + token stored; profile will refetch inside the app
      }

      loadInitialAppData();
      Get.offAll(() => NavigationView());
    } catch (e) {
      String message = 'Something went wrong. Please try again.';
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        } else if (e.response!.statusCode == 401) {
          message = 'Invalid phone number or password';
        } else if (e.response!.statusCode == 404) {
          message = 'No account found with this phone number';
        }
      }
      AlertWidgets.showSnackBar(message: message);
    } finally {
      isLoading.value = false;
    }
  }

  Future logout() async {
    _clearErrors();
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.closeAllSnackbars();
    await storage.delete(key: "token");

    // Delete all controllers so stale data is not shown to the next user
    await Get.delete<AddExpenseController>(force: true);
    await Get.delete<FriendsController>(tag: 'friends', force: true);
    await Get.delete<ActivityController>(force: true);
    await Get.delete<GroupsController>(force: true);
    await Get.delete<ProfileController>(force: true);
    await Get.delete<NavigationController>(force: true);

    Get.offAll(() => LoginView());
  }

  @override
  void onInit() {
    super.onInit();
    checkLogin(); // ✅ only sets isLoggedIn, no navigation
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    forgotEmailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
