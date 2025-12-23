import "package:flutter/material.dart";
import "package:taskboard/screens/auth_gate.dart";
import "package:taskboard/services/auth_api.dart";
import "package:taskboard/services/auth_storage.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthApi _api = AuthApi();
  String _email = "";
  String _password = "";
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Email"),
                const SizedBox(height: 6),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Please enter email"
                      : null,
                  onSaved: (newValue) => _email = newValue?.trim() ?? "",
                ),
                const SizedBox(height: 16),
                const Text("Password"),
                const SizedBox(height: 6),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Please enter password"
                      : null,
                  onSaved: (newValue) => _password = newValue ?? "",
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            _formKey.currentState!.save();
                            setState(() => _isSubmitting = true);
                            try {
                              final token = await _api.register(
                                email: _email,
                                password: _password,
                              );
                              await AuthStorage.setToken(token);
                              await AuthStorage.setLoggedIn(true);
                              if (!mounted) {
                                return;
                              }
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AuthGate(),
                                ),
                                (route) => false,
                              );
                            } catch (_) {
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Register failed"),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    child:
                        Text(_isSubmitting ? "Creating..." : "Create account"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
