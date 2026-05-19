import 'package:app_pe_diabetico/pages_inside/reauthentication_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final _newPassword1 = TextEditingController();
  final _newPassword2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _newPassword1.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password1 = _newPassword1.text;
    final password2 = _newPassword2.text;

    try {
      setState(() {
        _isLoading = true;
      });

      if (password1 == password2) {
        await _auth.currentUser!.updatePassword(password1);

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Alterou a sua palavra-passe com sucesso!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
            }
        );
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Erro"),
                content: Text("As palavra-passe não são coincidem!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
            }
        );
      }

    } on FirebaseAuthException catch (e) {
      print("Error: $e");

      setState(() {
        _isLoading = false;
      });

      if (e.code == "requires-recent-login") {
        final reauthenticated = await _showReauthentication();
        if (reauthenticated) {
          await _resetPassword();
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Erro"),
                  content: Text(_getErrorMessage(e)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ],
                );
              }
          );
        }
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e){
    switch (e.code) {
      case "weak-password":
        return "A palavra-passe demasiado fraca. Use pelo menos 6 caracteres.";
      case "requires-recent-login":
        return "Para a sua segurança, tente fazer login novamente antes de alterar a palavra-passe";
      default:
        return e.message ?? "Ocorreu um erro inesperado.";

    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Por favor, insira a palavra-passe";
    }

    if (value.length < 6) {
      return "A palavra-passe deve ter pelo menos 6 caractereres";
    }
    return null;
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme a palavra-passe';
    }
    if (value != _newPassword1.text) {
      return 'As palavras-passe não coincidem';
    }
    return null;
  }

  Future<bool> _showReauthentication() async {
    return await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Verificação de Segurança requerida"),
        content: Text("Para sua proteção, é preciso verificar a sua identidade antes de alterar a palavra-passe."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar")
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ReauthenticationPage())
            ).then((value) => Navigator.pop(context, value)), 
            child: Text("Verificar")
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundGreen,
        iconTheme: IconThemeData(
            color: AppColors.textDarkGreen
        ),
        title: Text(
          "Alterar Palavra-Passe",
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkGreen
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                    color: AppColors.textDarkGreen.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 20),

                Text("Alterar Palavra-Passe",
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkGreen
                  ),
                ),

                SizedBox(height: 8),

                Text("Introduza e confirme a sua nova palavra-passe",
                  style: GoogleFonts.roboto(
                      fontSize: 14.0,
                      color: AppColors.textDarkGreen.withOpacity(0.8)
                  ),
                ),

                SizedBox(height: 40),

                Text(
                  "Nova Palavra-Passe",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDarkGreen,
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: _newPassword1,
                  style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                  obscureText: _obscureText1,
                  validator: _validatePassword,

                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_rounded, color: AppColors.textDarkGreen,),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText1 = !_obscureText1;
                          });
                        },
                        icon: Icon(_obscureText1 ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textDarkGreen,
                        )
                      ),

                      hintText: "Digite a nova palavra-passe",
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

                SizedBox(height: 25),

                Text("Confirme palavra-passe",
                  style: GoogleFonts.roboto(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDarkGreen
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: _newPassword2,
                  style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                  obscureText: _obscureText2,
                  validator: _validatePasswordConfirmation,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textDarkGreen,),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText2 = !_obscureText2;
                          });
                        },
                        icon: Icon(
                          _obscureText2 ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textDarkGreen,
                        )
                      ),
                      hintText: "Digite a nova palavra-passe",
                      hintStyle: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.textDarkGreen)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.focusedBorderGreen)
                      ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.red, width: 2)
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.red, width: 2)
                    ),
                    filled: true,
                    fillColor: AppColors.textDarkGreen.withOpacity(0.1)
                  ),
                ),

                SizedBox(height: 50),

                Center(
                  child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _resetPassword, // desativa o botao enquanto carrega
                      icon: Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                          backgroundColor: AppColors.textDarkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          )
                      ),
                      label: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          :Text("Confirmar Alteração",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0
                            ),
                          )
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
