import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/home.dart';
import 'package:app_pe_diabetico/services/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Verifica antes de direcionar para as páginas, se já há um utilizador com a conta ligada
class AuthVerification extends StatefulWidget {
  const AuthVerification({super.key});

  @override
  State<AuthVerification> createState() => _AuthVerificationState();
}

class _AuthVerificationState extends State<AuthVerification> {
  @override
  void initState() {
    super.initState();
    _updateLastOpenTime();
  }

  Future<void> _updateLastOpenTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("last_app_open", DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // enquanto espera pela resposta mostra um icone circular a carregar
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center( child: CircularProgressIndicator());
        }

        if (snapshot.hasData){
          return MainScreen();
        } else {
          return Home();
        }
      }
    );
  }
}
