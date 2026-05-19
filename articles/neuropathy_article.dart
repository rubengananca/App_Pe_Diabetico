import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class NeuropathyArticle extends StatelessWidget {
  const NeuropathyArticle({super.key});

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
                  child: Image.asset("assets/neuropathy_wpp.jpg",
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
                  "Neuropatia e Circulação",
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subtitlesText,
                  ),
                ),

                Text(
                  "Compreender o Risco",
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subtitlesText,
                  ),
                ),

                const SizedBox(height: 12,),

                _buildParagraphs(
                  "Para quem vive com diabetes, compreender os riscos associados aos pés é essencial para prevenir complicações graves. Dois dos principais problemas que tornam o pé diabético tão perigoso são a neuropatia e a má circulação sanguínea."
                ),

                _buildParagraphs("A neuropatia periférica é uma condição que afeta os nervos dos pés, levando à perda de sensibilidade. Isso significa que pode não sentir uma ferida, uma bolha ou um sapato apertado — e quando não se sente, não se cuida. Com o tempo, isso pode originar infeções sérias."),

                _buildParagraphs("Além disso, a diabetes pode afetar os vasos sanguíneos, dificultando a circulação do sangue até aos pés. Quando há má circulação, as feridas demoram mais a cicatrizar e o risco de infeção aumenta."),
              
                _buildParagraphs("É por isso que até uma pequena ferida pode tornar-se um problema grave: o corpo não sente, não repara e não consegue curar com facilidade. Mas com vigilância e cuidados regulares, é possível evitar estas situações."),
                
                _buildParagraphs("Com conhecimento, prevenção e rotina, é possível manter os pés saudáveis e evitar complicações.")
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
