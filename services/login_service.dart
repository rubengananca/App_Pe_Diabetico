import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signIn(String email, String password, BuildContext context) async{

    if (email.isEmpty || password.isEmpty){
      _showErrorDialog("Preencha todos os campos!", context);
      return null;
    }

    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
      return null;
    }
  }

  void _handleAuthError(FirebaseAuthException e, BuildContext context) {

    //print("Código de erro: ${e.code}");
    //print("Mensagem de erro: ${e.message}");

    String errorMessage = "Ocorreu um erro. Tente Novamente.";

    if (e.code == "user-not-found"){
      errorMessage = "Utilizador não encontrado. Verifique o email.";
    } else if (e.code == "wrong-password"){
      errorMessage = "Senha incorreta. Tente novamente.";
    } else if (e.code == "invalid-email"){
      errorMessage = "Formato do email inválido.";
    } else if (e.code == "user-disabled") {
      errorMessage = "Esta conta foi desativada.";
    } else if (e.code == "network-request-failed") {
      errorMessage = "Erro de conexão. Verifique sua internet.";
    } else if (e.code == "too-many-requests") {
      errorMessage = "Muitas tentativas. Tente novamente mais tarde.";
    } else if (e.code == "invalid-credential") {
      errorMessage = "Credenciais inválidas. Verifique email e password.";
    } else {
      errorMessage = "Erro desconhecido: ${e.message}";
    }

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

}