import 'package:blog_application/src/core/utils/validators.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is AuthSuccess) {
              // After successful login
              context.go('/post',extra: state.accessToken);
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailCtrl,
                    validator: Validators.email,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextFormField(
                    controller: passCtrl,
                    validator: Validators.password,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            LoginEvent(
                              username: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                            ),
                          );
                        }
                      },
                      child: const Text("Login"),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
