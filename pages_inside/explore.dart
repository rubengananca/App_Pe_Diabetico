import 'package:app_pe_diabetico/services/GridItem.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  int _selectedIndex = 0;
  late List<GridItem> artigos;
  late List<GridItem> medicoes;
  late List<GridItem> relatorios;
  late List<GridItem> estatistica;

  @override
  void initState(){
    super.initState();

    artigos = [
      GridItem(
          imagePath: "assets/foot_care_cover.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/foot_care");
          },
          label: "Cuidados com os pés"
      ),

      GridItem(
          imagePath: "assets/tying_laces.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/adequate_shoes");
          },
          label: "Calçado Adequado"
      ),

      GridItem(
          imagePath: "assets/sinais_alerta_wpp.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/alert_signals");
          },
          label: "Sinais de Alerta"
      ),

      GridItem(
          imagePath: "assets/foot_examination_wpp.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/foot_examination");
          },
          label: "Rotina e avaliação dos pés"
      ),

      GridItem(
          imagePath: "assets/neuropathy_wpp.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/neuropathy_article");
          },
          label: "Neuropatia e Circulação"
      ),

    ];

    medicoes = [
      GridItem(
          imagePath: "assets/medicao_glicose.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/glicose_monitoring");
          },
          label: "Registo da Glicemia"
      ),

      GridItem(
          imagePath: "assets/blood_pressure.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/bpm_monitoring");
          },
          label: "Registo da Pressão Sanguínea"
      ),

      GridItem(
          imagePath: "assets/mood_forms.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/well_being");
          },
          label: "Registo da Dor e Bem-estar"
      ),
    ];

    relatorios = [
      GridItem(
          imagePath: "assets/diabetes_reports.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/glicose_reports");
          },
          label: "Relatórios da Glicemia"
      ),

      GridItem(
          imagePath: "assets/bpm_reports.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/bpm_reports");
          },
          label: "Relatórios da Pressão Sanguínea"
      ),

      GridItem(
          imagePath: "assets/medical_report.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/well_being_reports");
          },
          label: "Relatórios de Bem Estar"
      ),
    ];

    estatistica = [
      GridItem(
          imagePath: "assets/glicose_statistics.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/glicose_statistics");
          },
          label: "Estatística da Glicemia"
      ),

      GridItem(
          imagePath: "assets/blood_pressure_statistics.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/blood_pressure_statistics");
          },
          label: "Estatística da Pressão Sanguínea"
      ),

      GridItem(
          imagePath: "assets/wellbeing_statistics.jpg",
          onTap: () {
            Navigator.pushNamed(context, "/well_being_statistics");
          },
          label: "Estatística de Bem Estar"
      ),
    ];

  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            child: Image.asset("assets/explore_1.jpg",
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: _selectedIndex == 0 ?  AppColors.subtitlesText : Colors.grey.shade300,
                    ),

                    child: Text("Dicas",
                      style: TextStyle(
                        color: _selectedIndex == 0 ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1
                      ),
                    ),
                  ),

                  SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: _selectedIndex == 1 ? AppColors.subtitlesText : Colors.grey.shade300,
                    ),

                    child: Text("Medições",
                      style: TextStyle(
                        color: _selectedIndex == 1 ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1
                      ),
                    ),
                  ),

                  SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: _selectedIndex == 2 ? AppColors.subtitlesText : Colors.grey.shade300,
                    ),

                    child: Text("Relatórios",
                      style: TextStyle(
                          color: _selectedIndex == 2 ? Colors.white : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1
                      ),
                    ),
                  ),

                  SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: _selectedIndex == 3 ? AppColors.subtitlesText : Colors.grey.shade300,
                    ),

                    child: Text("Estatística",
                      style: TextStyle(
                          color: _selectedIndex == 3 ? Colors.white : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ),

          // E necessario expanded porque ocupa o resto do ecra
          Expanded(
            child: _selectedIndex == 0 ?
                _buildGrid(artigos) :
                _selectedIndex == 1 ?
                    _buildGrid(medicoes):
                    _selectedIndex == 2 ?
                        _buildGrid(relatorios) : _buildGrid(estatistica)
          ),

        ],
      ),
    );
  }
}

Widget _buildGrid (List<GridItem> items) {
  return GridView.builder(
    padding: EdgeInsets.fromLTRB(10, 0, 10, 50),
    itemCount: items.length,

    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
    ),

    itemBuilder: (context, index) {
      final item = items[index];
      return GestureDetector(
        onTap: item.onTap,

        // Frequentemente utilizado para criar cantos arredondados em imagens ou outros widgets
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                item.imagePath,
                width: 150,
                height: 100,
                fit: BoxFit.cover, // ajusta a imagem
              ),
            ),

            SizedBox(height: 6),

            Text(item.label,
              style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    }
  );
}
