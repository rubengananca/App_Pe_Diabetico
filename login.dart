import 'package:app_pe_diabetico/forgot_password.dart';
import 'package:app_pe_diabetico/services/route_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/services/login_service.dart';
import 'package:flutter/gestures.dart';
import 'package:app_pe_diabetico/services/main_screen.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // verifica o estado do login
  bool _obscureText = true;
  final LoginService _loginService = LoginService();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void signIn() async {

    setState(() {
      _isLoading = true;
    });

    // O UserCredential guarda as informações do utilizador
    UserCredential? userCredential = await _loginService.signIn(
      _emailController.text.trim(), _passwordController.text.trim(), context);

    setState(() {
      _isLoading = false;
    });

    if (userCredential != null){
      // remove todas as páginas da pilha de páginas até so ficar esta
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
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
          color: AppColors.textDarkGreen,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Login",
                style: GoogleFonts.roboto(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkGreen
                )
              ),

              Text("Introduza as informações da sua conta",
                style: GoogleFonts.roboto(
                  fontSize: 12.0,
                  color: AppColors.textDarkGreen
                ),
              ),

              SizedBox(height: 45,),

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

              SizedBox(height: 20,),

              TextFormField(
                  controller: _passwordController,
                  style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password_rounded, color: AppColors.textDarkGreen,),
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
                      hintText: "Digite a sua senha",
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
                  obscureText : _obscureText,

              ),

              SizedBox(height: 10,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, RouteNavRightLeft(ForgotPasswordPage()));
                    },

                    child: Text("Esqueceu-se da palavra-passe?",
                      style: GoogleFonts.roboto(
                        color: AppColors.textDarkGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],  
              ),
              
              SizedBox(height: 40,),

              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signIn, // desativa o botao enquanto carrega
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
                    : Text("Sign In",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.5
                      ),
                    )
                ),
              ),

              SizedBox(height: 100),

              Center(
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Ainda não tem conta? Faça antes o seu ',
                          style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                        ),
                        TextSpan(
                          text: 'registo.',
                          style: GoogleFonts.roboto(
                            color: AppColors.textDarkGreen,
                            fontWeight: FontWeight.bold,
                            //decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushReplacementNamed(context, "/register"),
                        ),
                      ],
                    ),
                  )
              )

            ],
          ),
        ),
      ),

    );
  }
}
