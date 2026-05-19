import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AdequateShoesPage extends StatelessWidget {
  const AdequateShoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/shoe_strap.jpg"), context);

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
                  child: Image.asset("assets/shoe_strap.jpg",
                    width: 350,          // largura desejada do widget
                    height: 220,         // altura desejada do widget
                    fit: BoxFit.cover,
                    cacheWidth: 600,     // define a largura da imagem em cache (ajuda performance)
                    cacheHeight: 400,
                  ),
                ),

                SizedBox(height: 20,),

                // Titulo Principal
                Text(
                  "Que calçado será adequado?",
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subtitlesText,
                  ),
                ),

                const SizedBox(height: 12,),

                _buildParagraphs(
                    "Para quem tem diabetes, escolher bem os sapatos é tão importante como cuidar da alimentação ou tomar a medicação. Sapatos mal ajustados podem causar feridas sem dor, que podem tornar-se sérias se não forem tratadas. Por isso, proteger os pés com calçado adequado é um cuidado diário essencial."
                ),

                _buildParagraphs(
                    "Mesmo dentro de casa, é importante evitar andar descalço ou com chinelos abertos. A maioria das feridas nos pés acontece por pequenos acidentes que poderiam ser evitados com o sapato certo."
                ),

                SizedBox(height: 30),

                Text("O que procurar num bom sapato",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.subtitlesText
                  ),
                ),

                SizedBox(height: 10),

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
                      _buildBulletPoint(text: "Ponta larga para não apertar os dedos;"),
                      _buildBulletPoint(text: "Sola macia e almofadada, que absorve o impacto ao caminhar;"),
                      _buildBulletPoint(text: "Fecho ajustável, como velcro ou atacadores;"),
                      _buildBulletPoint(text: "Espaço suficiente para usar palmilhas ortopédicas, se necessário;"),
                      _buildBulletPoint(text: "Material respirável, como couro macio, para evitar humidade."),
                    ],
                  ),
                ),


                SizedBox(height: 30),

                Text("Outras dicas",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.subtitlesText
                  ),
                ),

                SizedBox(height: 10),
                
                _buildParagraphs("O calçado deve oferecer proteção, conforto e estabilidade, e deve ser escolhido com tanto cuidado como qualquer outro aspeto do tratamento da diabetes. Sapatos demasiado fechados podem causar excesso de transpiração e favorecer infeções fúngicas, especialmente em climas quentes e húmidos. Por outro lado, sapatos abertos, como sandálias com tiras entre os dedos, deixam o pé desprotegido e mais suscetível a traumas."),
                
                _buildParagraphs("Por outro lado, é também aconselhado a que troque de sapatos ao longo do dia para evitar zonas de pressão e que opte por sapatos de caminhada ou de corrida, mesmo para o dia a dia.")

              ],
            ),
          ),
        ),
      ),
    );
  }
}


Widget _buildSectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(
      label,
      style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlueBorder
      ),
    ),
  );
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
