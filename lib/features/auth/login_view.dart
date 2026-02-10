import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitify/features/auth/register_view.dart';

import 'auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final c = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: c.emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: c.passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            Obx(() => c.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: c.login,
                    child: const Text("Login"),
                  )),
            TextButton(
              onPressed: () => Get.to(() => RegisterView()),
              child: const Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}
