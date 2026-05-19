import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/api/api_forms.dart';

class BloodPressureReports extends StatefulWidget {
  const BloodPressureReports({super.key});

  @override
  State<BloodPressureReports> createState() => _BloodPressureReportsState();
}

class _BloodPressureReportsState extends State<BloodPressureReports> {

  final ApiForms _apiService = ApiForms();
  late Future<List<Map<String,dynamic>>?> _listaRelatorios;

  String _formatarData(String isoDate) {
    try{
      final data = DateTime.parse(isoDate);
      return "${data.day.toString().padLeft(2,'0')}/${data.month.toString().padLeft(2,'0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
    } catch(e) {
      return "Data Inválida";
    }
  }

  @override
  void initState() {
    super.initState();
    _listaRelatorios = _apiService.getFormsInfo("blood_pressure");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundLightBlueStatistics,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text("Relatórios da Pressão Sanguínea",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.blueTitleStatistics,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: FutureBuilder<List<Map<String,dynamic>>?>(
            future: _listaRelatorios,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Erro ao carregar os dados", style: GoogleFonts.poppins(fontSize: 16, color: Colors.redAccent),));
              }

              final relatorios = (snapshot.data ?? []).reversed.toList();

              if (relatorios.isEmpty){
                return Center(child: Text("Nenhum relatório encontrado",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ));
              }

              return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: relatorios.length,
                  itemBuilder: (context, index) {
                    final relatorio = relatorios[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)
                      ),

                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.blueTitleStatistics.withOpacity(0.1),
                          child: const Icon(Icons.monitor_heart_rounded, color: AppColors.blueTitleStatistics),
                        ),

                        title: Text(
                          "Pressão Arterial: ${relatorio["systolic_pressure"]}/${relatorio["diastolic_pressure"]}",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blueTitleStatistics
                          ),
                        ),

                        subtitle: Text(
                          _formatarData(relatorio["measurement_time"]),
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey.shade700),
                        ),

                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric( horizontal: 16, vertical: 10),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detalheItem("Frequência Cardíaca: ", relatorio["bpm"]),

                                const SizedBox(height: 8),
                                _detalheItem("Comentário: ", relatorio["comment"].toString().isEmpty ? "Sem comentário" : relatorio["comment"]),
                              ],
                            ),
                          ),

                        ],
                      ),
                    );
                  }

              );

            }

        )

    );
  }
}

Widget _detalheItem(String titulo, String valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: RichText(
        text: TextSpan(
            text: "$titulo ",
            style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500
            ),
            children: [
              TextSpan(
                  text: valor,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black
                  )
              )
            ]
        )
    ),
  );
}
