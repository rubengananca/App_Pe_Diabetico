import 'package:app_pe_diabetico/services/route_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:app_pe_diabetico/utils/directory_forms.dart';
import 'package:app_pe_diabetico/utils/directory_articles.dart';
import 'package:app_pe_diabetico/api/api_practitioner.dart';
import 'package:app_pe_diabetico/services/forms_service.dart';
import 'package:app_pe_diabetico/api/api_messages.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiPractitioner apiService = ApiPractitioner();
  final ApiMessages apiMessages = ApiMessages();
  final FormsService _formsServices = FormsService();

  late final Future<Map<String, dynamic>?> _userFuture;
  late final Future<List<List<dynamic>>> _medicoesFuture;

  late Future<List<dynamic>> _medicoesGlicose;
  late Future<List<dynamic>> _medicoesBPM;
  late Future<List<dynamic>> _medicoesWellBeing;

  // lista de imagens para serem carregadas logo que a pagina abre
  List<String> imageUrls = [
    "assets/foot_care_cover.jpg",
    "assets/tying_laces.jpg",
    "assets/sinais_alerta_wpp.jpg",
    "assets/foot_examination_wpp.jpg",
    "assets/neuropathy_wpp.jpg",
    "assets/medicao_glicose.jpg",
    "assets/blood_pressure.jpg",
    "assets/mood_forms.jpg"
  ];

  // carrega a informação do utilzador quando abre a página
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

  @override
  void initState() {
    super.initState();
    _userFuture = _getUserData();
    _medicoesFuture = Future.wait([
      _formsServices.getLastReportsGlicose(),
      _formsServices.getLastReportsBPM(),
      _formsServices.getLastReportsWellBeing(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // precarrega as imagens
    for (var url in imageUrls) {
      precacheImage(AssetImage(url), context);
    }

    return Scaffold(
      backgroundColor: Color(0xFFE3E6DF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: _userFuture,
            builder: (context, snapshot) {
          
              // verifica o estado dos dados, neste caso se ainda não chegaram mostra um spinner
              if (snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 100,
                    secondRingColor: AppColors.loadingSecondRing,
                    thirdRingColor: AppColors.loadingThirdRing
                  ),
                );
              }
          
              if (!snapshot.hasData || snapshot.data == null){
                return Center(child: Text("Erro ao carregar perfil"));
              }
          
              Map<String, dynamic> userData = snapshot.data!;
              String username = userData['username'] ?? "Utilizador";
              List<String> names = username.trim().split(" ");
              String firstName = names[0];
              String lastName = "";
          
              if(names[0] != names.last){ // se uma pessoa tiver o primeiro e ultimo nome igual n mostra - talvez mudar para names.len==1
                lastName = names.last;
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Olá, ',
                            style: GoogleFonts.nunito(fontSize: 30, color: Colors.black),
                          ),
                          TextSpan(
                            text: "$firstName $lastName",
                            style: GoogleFonts.nunito(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.subtitlesText
                            ),
                          ),
                        ],
                      ),
                    ),
          
                    SizedBox(height: 20),


                    // Estatistica de comparar
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Comparação dos últimos registos",
                              style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            FutureBuilder(
                              future: _medicoesFuture,
                              builder: (context, snapshot){
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                //print("Teste ${snapshot.data}");

                                if (!snapshot.hasData || snapshot.data == null) {
                                  return Center(child: Text("Erro ao carregar medições"));
                                }

                                final dados = snapshot.data!;
                                final glicose = dados[0];
                                final bpm = dados[1];
                                final wellBeing = dados[2];

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatCard("Glicose", "${glicose[1]} ➜ ${glicose[0]}", Icons.bloodtype, Colors.orange),
                                    _buildStatCard("Pressão", "${bpm[2]}/${bpm[3]} ➜ ${bpm[0]}/${bpm[1]}", Icons.monitor_heart, Colors.red),
                                    _buildStatCard("Dor", "${wellBeing[1]} ➜ ${wellBeing[0]}", Icons.sentiment_satisfied_alt, Colors.green),
                                  ],
                                );
                              }
                            )
                          ],
                        ),
                      )
                    ),
          
                    SizedBox(height: 10),

                    // Dicas de emergência
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: ListTile(
                        leading: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30,),
                        title: Text("Dicas de Emergência",
                          style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        trailing: Icon(Icons.chevron_right, color: Colors.white,),
                        onTap: () {Navigator.push(context, RouteNavRightLeft(EmergencyTips()));},
                      ),
                    ),


                    SizedBox(height: 10),
          
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
          
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _buildSectionTitle("Educação em saúde", Icons.article_rounded),
          
                            SizedBox(height: 10),
          
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildButtonImage(
                                      imagePath: "assets/foot_care_cover.jpg",
                                      onTap: () {
                                        Navigator.push(context, RouteNavRightLeft(FootCarePage()));
                                      },
                                    label: "Cuidados com os pés"
                                  ),
          
                                  _buildButtonImage(
                                      imagePath: "assets/tying_laces.jpg",
                                      onTap: () {
                                        Navigator.push(context, RouteNavRightLeft(AdequateShoesPage()));
                                      },
                                    label: "Calçado Adequado"
                                  ),
          
                                  _buildButtonImage(
                                      imagePath: "assets/sinais_alerta_wpp.jpg",
                                      onTap: () {
                                        Navigator.push(context, RouteNavRightLeft(AlertSignals()));
                                      },
                                    label: "Sinais de Alerta"
                                  ),
          
                                  _buildButtonImage(
                                      imagePath: "assets/foot_examination_wpp.jpg",
                                      onTap: () {
                                        Navigator.push(context, RouteNavRightLeft(WeeklyExamination()));
                                      },
                                      label: "Rotina e avaliação dos pés"
                                  ),
          
                                  _buildButtonImage(
                                      imagePath: "assets/neuropathy_wpp.jpg",
                                      onTap: () {
                                        Navigator.push(context, RouteNavRightLeft(NeuropathyArticle()));
                                      },
                                      label: "Neuropatia e Circulação"
                                  ),

                                ],
                              ),
                            ),
          
                          ],
                        ),
                      )
                    ),
          
                    SizedBox(height: 20),
          
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
          
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _buildSectionTitle("Medições", Icons.healing_rounded),
          
                            SizedBox(height: 10),
          
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildButtonImage(
                                      imagePath: "assets/medicao_glicose.jpg",
                                      onTap: () async {
                                        await Navigator.push(context, RouteNavRightLeft(GlicoseForms()));

                                        // Após retornar da página atualiza os dados:
                                        setState(() {
                                          _medicoesGlicose = _formsServices.getLastReportsGlicose();
                                        });
                                      },
                                    label: "Registo da Glicemia"
                                  ),
          
                                  _buildButtonImage(
                                      imagePath: "assets/blood_pressure.jpg",
                                      onTap: () async {
                                        await Navigator.push(context, RouteNavRightLeft(BloodPressure()));

                                        // Após retornar da página atualiza os dados:
                                        setState(() {
                                          _medicoesBPM = _formsServices.getLastReportsBPM();
                                        });
                                      },

                                    label: "Registo da Pressão Sanguínea"
                                  ),
          
                                  _buildButtonImage(
                                      imagePath: "assets/mood_forms.jpg",
                                      onTap: () async{
                                        await Navigator.push(context, RouteNavRightLeft(WellBeing()));

                                        // Após retornar da página atualiza os dados:
                                        setState(() {
                                          _medicoesWellBeing = _formsServices.getLastReportsWellBeing();
                                        });
                                      },
                                    label: "Registo da Dor e Bem-estar"
                                  ),
          
                                ],
                              ),
                            )
          
                          ],
                        ),
          
                      ),
                    ),
          
                  ],
                ),
              );
            },
          ),
        )
      ),

    );
  }
}


// Widget para itens da Lista
Widget _buildButtonImage(
    {required String imagePath, required VoidCallback onTap, required String label})
{
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),

    // Permite reconhecer e responder a vários gestos de toque (deslizar, tocar duas vezes, arrastar...)
    child: GestureDetector(
      onTap: onTap,

      // Frequentemente utilizado para criar cantos arredondados em imagens ou outros widgets
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              width: 150,
              height: 100,
              fit: BoxFit.cover, // ajusta a imagem
            ),
          ),

          SizedBox(height: 6),

          Text(label,
            style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold),
          )
        ],
      ),
    ),
  );
}


Widget _buildStatCard (String title, String value, IconData icon, Color color) {
  return Column (
    children: [
      Icon(icon, color: color, size: 28),
      SizedBox(height: 5,),
      Text(title, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600)),
      Text(value, style: GoogleFonts.roboto(fontSize: 12, color: Colors.black54)),
    ],
  );
}

Widget _buildSectionTitle(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, color: AppColors.subtitlesText),
        SizedBox(width: 10),
        Text(title,
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color:  AppColors.subtitlesText),
        )
      ],
    ),
  );
}