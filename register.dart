import 'package:app_pe_diabetico/services/time_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:app_pe_diabetico/services/main_screen.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TimeService {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isLoading = false;

  // Variável para armazenar a data selecionada
  DateTime? selectedDate;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Funcao para registar o utilizador
  void register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String email = _emailController.text;
    String? date = selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null;


    if(username.isEmpty || password.isEmpty || email.isEmpty || date == null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Esqueceu-se de preencher algo!"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Por favor preencha todos os campos!\n'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK',
                  style: TextStyle(
                    color: Color(0xFF008597)
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Registar no Firebase
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password);

      // Guardar os dados adicionais no Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection("users").doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'date': date,
      });

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _handleRegisterError(e, context);
      return null;
    }

  }

  // funcao para criar e escolher a data no calendario
  Future<void> _pickDate() async {
    DateTime? picked = await selectDate(context);

    if (picked == null) return;
    final now = DateTime.now();
    
    if (now.difference(picked).inDays < 6570) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Deve ser maior de idade para poder se registar!"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(color: Color(0xFF008597)),))
            ],
          )
      );
      return;
    } else if (now.difference(picked).inDays < 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Selecionou uma data futura. Por favor selecione uma data válida!"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Color(0xFF008597)),))
          ],
        )
      );
      return;
    }

    setState(() {
      selectedDate = picked;
      _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    });

  }

  void _handleRegisterError(FirebaseAuthException e, BuildContext context) {

    //print("Código de erro: ${e.code}");
    //print("Mensagem de erro: ${e.message}");

    String errorMessage = "Ocorreu um erro. Tente Novamente.";

    if (e.code == "email-already-in-use"){
      errorMessage = "O email já está associado a uma conta. Tente com outro email.";
    } else if (e.code == "weak-password"){
      errorMessage = "Palavra passe fraca. Tente uma palavra passe mais complexa";
    } else if (e.code == "invalid-email"){
      errorMessage = "Formato do email inválido.";
    } else if (e.code == "user-disabled") {
      errorMessage = "Esta conta foi desativada.";
    } else {
      errorMessage = "Erro desconhecido: ${e.message}";
    }

    setState(() {
      _isLoading = false;
    });

    _showErrorDialog(errorMessage, context);
  }

  void _showErrorDialog(String message, BuildContext context){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Color(0xFF008597)),))
          ],
        )
    );
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
              Text("Criar Conta",
                style: GoogleFonts.roboto(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkGreen
                ),
              ),
        
              Text("Introduza as suas informações para começar a sua experiência",
                style: GoogleFonts.roboto(
                  fontSize: 12.0,
                  color: AppColors.textDarkGreen
                ),
              ),
              SizedBox(height: 45),

              TextField(
                controller: _usernameController,
                style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: AppColors.textDarkGreen,),
                  hintText: "Nome Completo",
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
              SizedBox(height: 20),

              TextField(
                controller: _emailController,
                style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_rounded, color: AppColors.textDarkGreen,),
                  hintText: "Email",
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
        
              SizedBox(height: 20),

              TextField(
                controller: _dateController,
                style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                decoration: InputDecoration(
                  labelText: "Data de Nascimento",
                  labelStyle: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                  //filled: true,
                  prefixIcon: Icon(Icons.calendar_month_outlined, color: AppColors.textDarkGreen,),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.textDarkGreen)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.focusedBorderGreen)
                  )
                ),
                readOnly: true,
                onTap: (){
                  _pickDate();
                },
              ),
        
              SizedBox(height: 20),
              /*Text("Senha",
                style: GoogleFonts.roboto(fontSize: 18),
              ),*/
              TextField(
                controller: _passwordController,
                style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.password_rounded, color: AppColors.textDarkGreen,),
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
                obscureText : true
              ),
        
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                    onPressed: _isLoading ? null : register, // desativa o botao enquanto carrega
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
                        : Text("Registar",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.5
                      ),
                    )
                ),
              ),

              SizedBox(height: 120),

              Center(
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Já tem conta? Faça então ',
                          style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                        ),
                        TextSpan(
                          text: 'login.',
                          style: GoogleFonts.roboto(
                            color: AppColors.textDarkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushReplacementNamed(context, "/login"),
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
