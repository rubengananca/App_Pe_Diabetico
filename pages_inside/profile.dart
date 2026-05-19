import 'package:app_pe_diabetico/pages_inside/change_password.dart';
import 'package:app_pe_diabetico/services/route_animation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_pe_diabetico/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:app_pe_diabetico/pages_inside/practitioner_codes.dart';
import 'package:app_pe_diabetico/pages_inside/practitioner_page.dart';
import 'package:app_pe_diabetico/api/api_practitioner.dart';
import 'package:app_pe_diabetico/pages_inside/messages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // Para autenticar o utilizador e guardar o uid - Obtém a instância da autenticação para verificar quem está autenticado.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Guarda e recurpera os dados do utilizador
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ApiPractitioner apiService = ApiPractitioner();
  late final Future<Map<String, dynamic>?> _userFuture;
  
  Future<Map<String, dynamic>?> _getUserData() async {
    User? user = _auth.currentUser;

    if(user != null){
      DocumentSnapshot userInfo = await _firestore.collection("users").doc(user.uid).get();

      if( userInfo.exists){
        return userInfo.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future _logout() async {
    await FirebaseAuth.instance.signOut().then(
            (value) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Home()),
                (route) => false
        )
    );
  }

  Future<void> _verifyUserLink() async {
    Map<String,dynamic>? linkInformation = await apiService.getAssociation(); // Verifica se o utilizador está ligado

    if (linkInformation != null && linkInformation.containsKey("message")) {
      // Nao tem associacao
      if (linkInformation['message'] == "user has no associated practitioner") {
        Navigator.push(context, RouteNavRightLeft(PractitionerCodesPage()));
      } else {
        // Ja tem associacao
        // Leva para a página o id do utilizador para conseguir ver a sua informacao
        Navigator.push(context, RouteNavRightLeft(PractitionerPage(practitionerCode: linkInformation["result"]["practitioner_id"])));
      }

    } else {
      print("O mapa e vazio ou nao tem a chave correspondente");
    }
  }

  @override
  void initState() {
    super.initState();
    _userFuture = _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3E6DF),
      body: FutureBuilder(
        future: _userFuture,
        builder: (context, snapshot) {

          // verifica o estado dos dados, neste caso se ainda não chegaram mostra um spinner
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null){
            return Center(child: Text("Erro ao carregar perfil"));
          }

          Map<String, dynamic> userData = snapshot.data!;
          String username = userData['username'] ?? "Utilizador";
          String userEmail = userData['email'] ?? "Email não disponível";
          String userBirth = userData['date'] ?? "Data de Nascimento não encontrada";

          return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  width: double.infinity, // Faz com que o container ocupe toda a largura possível
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3E7C63), Color(0xFF6BA292)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  child: Column(
                    children: [

                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 45, color: Color(0xFF3E7C63)),
                      ),

                      const SizedBox(height: 25),

                      Text(username,
                        style: GoogleFonts.roboto(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),

                      Text(userEmail,
                          style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70)),

                      //const SizedBox(height: 10),
                    ],
                  ),
                ),

                // O Expanded faz com que o ListView ocupe a totalidade do espaço disponível na vertical dentro da Column
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 15),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            //padding: const EdgeInsets.all(16),
                            children: [

                              _buildOptionTile(
                                  icon: Icons.edit,
                                  text: "Editar Palavra-Passe",
                                  onTap: () {
                                    Navigator.push(context, RouteNavRightLeft(
                                        ChangePassword())
                                    );
                                  }
                              ),

                              _buildOptionTile(
                                  icon: Icons.medical_services,
                                  text: "Médico Associado",
                                  onTap: () {
                                    _verifyUserLink();
                                  }
                              ),

                              _buildOptionTile(
                                  icon: Icons.message_rounded,
                                  text: "Mensagens com Médico",
                                  onTap: () {
                                    Navigator.push(context, RouteNavRightLeft(
                                        MessagesPage())
                                    );
                                  }
                              ),

                              /*_buildOptionTile(
                                  icon: Icons.settings,
                                  text: "Configurações",
                                  onTap: () {}
                              ),*/

                              const SizedBox(height: 20),

                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: _logout,
                                  icon: Icon(Icons.logout_rounded, color: Colors.white),
                                  label: Text(
                                    "Logout",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.white
                                    ),
                                  ),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonBrown,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 5,
                                  ),
                                )
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ],
            );
        }
      )
    );
  }
}

// Widget para itens da Lista
Widget _buildOptionTile(
  {required IconData icon, required String text, required VoidCallback onTap})
{
  return Card(
    shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(15)),
    elevation: 3,
    //color: Colors.white,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.focusedBorderGreen.withOpacity(0.1),
        child: Icon(icon, color: AppColors.focusedBorderGreen),
      ),
      title: Text(text, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ),
  );
}

Widget perfilItem(String label, String valor) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.roboto(fontSize: 15)),
        Text(valor, style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 15))
      ],
    ),
  );
}