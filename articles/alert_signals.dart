import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertSignals extends StatelessWidget {
  const AlertSignals({super.key});

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

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset("assets/foot_covered.jpg",
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
                "Sinais de Alerta!",
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtitlesText,
                ),
              ),

              Text(
                "Quando procurar ajuda?",
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtitlesText,
                ),
              ),

              const SizedBox(height: 12,),

              _buildParagraphs(
                  "Reconhecer precocemente um problema nos pés é a melhor forma de evitar complicações sérias. Sempre que notar algo diferente, pare, observe e, se necessário, peça ajuda. Estes são os sinais que merecem atenção especial:"
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
                    _buildBulletPoint(text: "Feridas que não cicatrizam ou que demoram mais de dois dias a fechar;"),
                    _buildBulletPoint(text: "Vermelhidão, sensação de calor ou inchaço numa zona específica do pé;"),
                    _buildBulletPoint(text: "Dor incomum ou mudança repentina da sensibilidade;"),
                    _buildBulletPoint(text: "Mau cheiro persistente, mesmo após lavar e secar bem o pé;"),
                    _buildBulletPoint(text: "Alterações na cor da pele ou das unhas, como manchas escuras, palidez ou coloração azulada."),
                  ],
                ),
              ),

              SizedBox(height: 15,),

              _buildParagraphs("Se algum destes sinais surgir — sobretudo se houver pus, febre ou agravamento rápido — procure um profissional de saúde de imediato. Quanto mais cedo iniciar o tratamento, maior a probabilidade de evitar infeções graves e de acelerar a cicatrização.")


            ],
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
