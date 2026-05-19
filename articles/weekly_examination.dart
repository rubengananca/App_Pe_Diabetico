import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyExamination extends StatelessWidget {
  const WeeklyExamination({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        iconTheme: IconThemeData(
          color: AppColors.subtitlesText,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("assets/foot_examination.jpg",
                    width: 350,
                    height: 220,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    cacheHeight: 400,
                  ),
                ),

                SizedBox(height: 20,),

                // Titulo Principal
                Text(
                  "Rotina e Avaliação Semanal dos pés",
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subtitlesText,
                  ),
                ),

                const SizedBox(height: 12,),

                _buildParagraphs(
                    "Criar o hábito de observar os seus pés com atenção, pelo menos uma vez por semana, é uma das formas mais eficazes de prevenir complicações. Esta rotina simples pode ajudá-lo a identificar problemas logo no início — antes que se agravem."
                ),

                _buildParagraphs(
                  "Encontra aqui uma lista rápida de autoavaliação, com perguntas simples para o guiar:"
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3)
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulletPoint(text: "Tem alguma ferida, bolha ou corte visível?"),
                      _buildBulletPoint(text: "As unhas estão bem cortadas e sem sinais de inflamação?"),
                      _buildBulletPoint(text: "Consegue sentir normalmente os dedos e a planta dos pés?"),
                      _buildBulletPoint(text: "Os pés estão frios, dormentes ou com alguma sensação estranha?"),
                      _buildBulletPoint(text: "A pele está seca, gretada ou a descamar?"),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}


Widget _buildBulletPoint(
    {required String text})
{
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '•',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

Widget _buildParagraphs(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      textAlign: TextAlign.justify,
      style: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5
      ),
    ),
  );
}
