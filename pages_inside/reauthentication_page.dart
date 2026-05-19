import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ReauthenticationPage extends StatefulWidget {
  const ReauthenticationPage({super.key});

  @override
  State<ReauthenticationPage> createState() => _ReauthenticationPageState();
}

class _ReauthenticationPageState extends State<ReauthenticationPage> {

  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _reauthenticate(BuildContext context) async {

    try {
      User user = FirebaseAuth.instance.currentUser!;

      setState(() {
        _isLoading = true;
      });

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: _passwordController.text);

      setState(() {
        _isLoading = false;
      });

      await user.reauthenticateWithCredential(credential);
      Navigator.pop(context, true);

    } catch (e) {
      print("Deu o erro $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password incorreta")),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundGreen,
        iconTheme: IconThemeData(
            color: AppColors.textDarkGreen
        ),
        title: Text(
          "Verificação de Segurança",
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkGreen
          ),
        )
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Por favor, insira a sua palavra-passe atual para continuar",
              style: GoogleFonts.roboto(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkGreen
              ),
            ),

            SizedBox(height: 40),
            
            TextFormField(
              controller: _passwordController,
              style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textDarkGreen,),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textDarkGreen,
                    )
                ),
                hintText: "Palavra-Passe atual",
                hintStyle: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.textDarkGreen)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.focusedBorderGreen)
                ),
                filled: true,
                fillColor: AppColors.textDarkGreen.withOpacity(0.1)
              ),
            ),

            SizedBox(height: 50),
            
            Center(
              child: ElevatedButton (
                onPressed: () => _isLoading ? null : _reauthenticate(context),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                    backgroundColor: AppColors.textDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    )
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    :Text("Confirmar Alteração",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
