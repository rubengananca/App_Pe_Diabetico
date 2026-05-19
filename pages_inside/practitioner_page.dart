import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/api/api_practitioner.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/services/main_screen.dart';

class PractitionerPage extends StatefulWidget {

  // recebe o id para conseguir ir buscar a sua informação
  final String practitionerCode;
  const PractitionerPage({super.key, required this.practitionerCode});

  @override
  State<PractitionerPage> createState() => _PractitionerPageState();
}

class _PractitionerPageState extends State<PractitionerPage> {

  final ApiPractitioner _apiService = ApiPractitioner();
  Future<Map<String,dynamic>?>? _practitionerInfo;
  String? associatedPractitionerID;
  bool isLoading = false;

  void _showDialog(String title, String content) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: AppColors.subtitlesText)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializePractitionerInfo() async {
    final association = await _apiService.getAssociation();

    // impede o setState se o widget já não estiver na árvore de widgets.
    if (!mounted) return;

    if (association != null && association.containsKey("result")) {
      setState(() {
        associatedPractitionerID = association["result"]["practitioner_id"];
        _practitionerInfo = _apiService.getPractitionerAssociatedInfo();
      });
    } else {
      setState(() {
        _practitionerInfo = _apiService.getPractitionerInfoByCode(widget.practitionerCode);
      });
    }
  }

  // ao abrir a página verifica se este medico está associado ao utilizador
  // importante pois esta página pode ser mostrada das duas uma:
  //   - Utilizador abre esta página a partir da pagina dos códigos (nao associado e portanto pode querer associar-se);
  //   - Utilizador abre esta página porque esta associado a este medico (pode querer desassociar-se).

  // recebe o codigo do medico para o utilizador se associar a ele
  void _linkUserToPractitioner(String code) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    var associationStatus = await _apiService.associateUserWithPractitioner(code);
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (associationStatus) {
      _showDialog("Sucesso!","Associou-se ao médico com sucesso!");
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/main",
            (Route<dynamic> route) => false, // remove todas as rotas anteriores
      );

    } else {
      _showDialog("Erro!","Houve um erro ao associá-lo ao médico!");
    }
  }

  void _unlinkUserFromPractitioner() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    await _apiService.deleteAssociation();
    if (!mounted) return;

    setState(() => isLoading = false);

    _showDialog("Sucesso!","Desassociou-se do médico com sucesso!");
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/main",
          (Route<dynamic> route) => false, // remove todas as rotas anteriores
    );
  }


  @override
  void initState() {
    super.initState();
    _initializePractitionerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Perfil do Médico",
            style: GoogleFonts.roboto(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: _practitionerInfo,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null){
          return Center(child: Text("Erro ao carregar perfil"));
        }

        Map<String, dynamic> practitionerData = snapshot.data!;
        String name = practitionerData["name"];
        String code = practitionerData["code"];
        String telecom = practitionerData["telecom"];
        String? practitionerID = practitionerData["practitioner_id"];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 100, right: 10, left: 10, bottom: 40) ,
                width: double.infinity, // Faz com que o container ocupe toda a largura possível
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.MediumBrown, AppColors.LightBrown],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
          
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.medical_services_rounded, color: AppColors.MediumBrown, size: 40)
                    ),
          
                    const SizedBox(height: 15),
          
                    Text(name,
                      style: GoogleFonts.roboto(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6,
                  shadowColor: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow("Nome", name, Icons.person),
                        const Divider(height: 30),
                        _buildInfoRow("Código", code, Icons.verified_user),
                        const Divider(height: 30),
                        _buildInfoRow("Contacto", telecom, Icons.phone),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (associatedPractitionerID == practitionerID) {
                      _unlinkUserFromPractitioner();
                    } else {
                      _linkUserToPractitioner(code);
                    }
                  },

                  icon: Icon((associatedPractitionerID == practitionerID)
                      ? Icons.link_off
                      : Icons.link,
                    color: Colors.white,
                  ),

                  label: Text(
                    (associatedPractitionerID == practitionerID)
                        ? "Eliminar Conexão"
                        : "Associar-se",
                    style: const TextStyle(fontSize: 16),
                  ),

                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                    ),
                    backgroundColor: (associatedPractitionerID == practitionerID)
                        ? AppColors.MediumBrown
                        : Color(0xFF587171),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),

                    elevation: 4,
                  ),

                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
        }
      )
    );
  }
}

Widget _buildInfoRow(String label, String value, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: Colors.black87),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$label: ",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 16)),
              TextSpan(
                text: value,
                style: GoogleFonts.roboto(
                    //fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16)),
            ]
          )
        )
      )
    ],
  );
}

