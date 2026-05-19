import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {

      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);

      // Show success message
      showDialog(
        context: context,
        builder: (context) =>
          AlertDialog(
            title: Text("O email para alterar a palavra passe foi enviado!"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK", style: TextStyle(color: Color(0xFF008597)),))
            ],
          )
      );


    } on FirebaseAuthException catch (e) {
      print("Error: $e");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          }
      );
    }
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
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Redifinir Palavra-Passe",
                style: GoogleFonts.roboto(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkGreen
                )
              ),
        
              Text("Introduza o email para alterar a palavra-passe",
                style: GoogleFonts.roboto(
                    fontSize: 12.0,
                    color: AppColors.textDarkGreen
                ),
              ),
        
              SizedBox(height: 45),
        
              TextField(
                controller: _emailController,
                style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_rounded, color: AppColors.textDarkGreen,),
                    hintText: "Digite o seu email",
                    hintStyle: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: AppColors.textDarkGreen)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: AppColors.focusedBorderGreen)
                    )
                ),
              ),
        
              SizedBox(height: 100),
        
              Center(
                child: ElevatedButton(
                    onPressed: _isLoading ? null : passwordReset, // desativa o botao enquanto carrega
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
                        : Text("Enviar Email",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.5
                      ),
                    )
                ),
              ),
        
            ],
          ),
        ),
      )

    );
  }
}
