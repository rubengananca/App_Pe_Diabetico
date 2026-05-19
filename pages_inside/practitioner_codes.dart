import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/api/api_practitioner.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:app_pe_diabetico/pages_inside/practitioner_page.dart';
import 'package:app_pe_diabetico/services/route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

// Página só é mostrada a utilizadores que não têm ainda pactitioner de forma a expor os existentes
class PractitionerCodesPage extends StatefulWidget {
  const PractitionerCodesPage({super.key});

  @override
  State<PractitionerCodesPage> createState() => _PractitionerCodesPageState();
}

class _PractitionerCodesPageState extends State<PractitionerCodesPage> {

  final ApiPractitioner apiService = ApiPractitioner();
  late Future<List<dynamic>> _codesPractitioner;

  @override
  void initState() {
    super.initState();
    _codesPractitioner = apiService.getPractitionerCodes();
  }

  Future<String> _getNamePractitioner(String code) async{
    try {
      final practitionerInfo = await apiService.getPractitionerInfoByCode(code);

      if (practitionerInfo != null && practitionerInfo.containsKey("name")){
        return practitionerInfo["name"];
      }
      return "Nome não disponível";
    } catch (e) {
      print("Erro ao ir buscar o nome do médico: $e");
      return "Erro ao carregar";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text("Médicos Disponíveis",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF354949),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _codesPractitioner,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar os dados", style: GoogleFonts.roboto(fontSize: 16, color: Colors.redAccent),));
          }

          final codes = snapshot.data ?? null;

          if(codes!.isEmpty){
            return Center(child: Text("Nenhum médico encontrado",
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
            ));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: codes.length,
            itemBuilder: (context, index){
              return FutureBuilder<String>(
                future: _getNamePractitioner(codes[index]),
                builder: (context, nameSnapshot) {
                  String doctorName = "Carregando...";

                  if (nameSnapshot.connectionState == ConnectionState.done) {
                    if (nameSnapshot.hasData) {
                      doctorName = nameSnapshot.data!;
                    } else if (nameSnapshot.hasError) {
                      doctorName = "Erro ao carregar";
                    }
                  }

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),

                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      leading: CircleAvatar(
                          backgroundColor: AppColors.focusedBorderGreen.withOpacity(0.1),
                          child: Icon(Icons.medical_services, color: Color(0xFF354949))
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Médico: $doctorName",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Color(0xFF354949),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text("Código: ${codes[index]}",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.push(context, RouteNavRightLeft(PractitionerPage(practitionerCode: codes[index])));
                      },
                    ),
                  );
                }
              );

            }
          );
        }
      ),

    );

  }
}


    
