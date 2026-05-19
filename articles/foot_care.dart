import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FootCarePage extends StatelessWidget {
  const FootCarePage({super.key});

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
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset("assets/feet_care_photo.jpg",
                  width: 350,
                  height: 220,
                  fit: BoxFit.cover,
                  cacheWidth: 600,
                  cacheHeight: 400,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Cuidados com os pés",
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtitlesText,
                ),
              ),

              SizedBox(height: 12),

              _buildParagraphs(
                  "Cuidar dos pés pode parecer algo simples, mas para quem vive com diabetes é um gesto diário que faz toda a diferença. É importante, portanto, controlar os níveis de glicose no sangue e manter um estilo de vida saudável e é fundamental prestar atenção aos pés todos os dias."
              ),

              _buildParagraphs(
                  "Estar informado e consciente sobre a própria saúde é uma forma poderosa de prevenção. Saber como cuidar dos pés, reconhecer sinais de alerta e procurar ajuda médica quando necessário pode evitar complicações e melhorar muito a qualidade de vida."
              ),

              _buildParagraphs(
                  "A prevenção e o tratamento de complicações nos pés, como úlceras ou infeções, exigem muitas vezes o apoio de vários profissionais de saúde que trabalham em conjunto — desde médicos e enfermeiros a podologistas e nutricionistas. Quando todos estão envolvidos, incluindo a própria pessoa, torna-se mais fácil garantir que os cuidados certos são prestados na altura certa."
              ),

              _buildParagraphs(
                  "Desta forma, é apresentado de seguinda uma check list de cuidados que deve ter em conta diáriamente, bem como ações que deve evitar fazer para não piorar as úlceras existentes."
              ),

              SizedBox(height: 30),

              Text("Check List de Cuidados Diários",
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
                    _buildSectionLabel("O que fazer:"),
                    _buildBulletPoint(text: "Inspecionar os pés diariamente por bolhas, cortes, arrahões e áreas avermelhadas. Deve ser feita sempre uma verificação entre os dedos dos pés;"),
                    _buildBulletPoint(text: "Lavar os pés diariamente, enxaguando e secando cuidadosamente, principalmente entre os dedos dos pés;"),
                    _buildBulletPoint(text: "Usar meias limpas e intactas e adequadas com os sapatos usados;"),
                    _buildBulletPoint(text: "Para pele seca, meter uma fina camada de lubrificante óleo ou creme, exceto entre os dedos dos pés."),

                    const SizedBox(height: 10,),
                    _buildSectionLabel("O que evitar"),
                    _buildBulletPoint(text: "Evitar temperaturas extremas. Testar a água com a mão ou cotovelo antes de tomar banho;"),
                    _buildBulletPoint(text: "Não andar descalço;"),
                    _buildBulletPoint(text: "Não remover calos ou calosidades."),
                  ],
                ),
              )

            ],
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
