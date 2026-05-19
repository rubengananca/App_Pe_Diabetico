import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyTips extends StatefulWidget {
  const EmergencyTips({super.key});

  @override
  State<EmergencyTips> createState() => _EmergencyTipsState();
}

class _EmergencyTipsState extends State<EmergencyTips> {

  void _callSaude24() async {
    const phone = '808242424';               // número correto sem espaços
    final Uri uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // opcional: mostrar SnackBar ou diálogo
        debugPrint('Não foi possível abrir o marcador.');
      }
    } catch (e) {
      debugPrint('Erro ao tentar abrir o marcador: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFFFE7EA),

      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        centerTitle: true,
        backgroundColor: Color(0xFFFFE7EA),
        iconTheme: IconThemeData(
          color: Colors.redAccent.shade700,
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.phone, color: Colors.white),
            label: const Text(
              "Ligar para Saúde 24",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: _callSaude24,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("assets/emergency_tips.jpg",
                    width: 350,
                    height: 220,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    cacheHeight: 400,
                  )
                ),

                SizedBox(height: 20),

                Text(
                  "Dicas de Emergência!",
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent.shade700,
                  ),
                ),

                SizedBox(height: 12),

                _buildParagraph("Algumas situações exigem atenção médica imediata. Conhecer os sinais de alarme e saber como agir pode fazer toda a diferença na recuperação e na prevenção de complicações graves."),

                _buildSectionTitle("⚠️ Sinais de Alerta Grave"),
                _buildBullet("Ferida com pus, dor intensa ou que está a piorar"),
                _buildBullet("Febre ou mal-estar associado ao pé"),
                _buildBullet("Pele escurecida, arroxeada ou com má circulação"),
                _buildBullet("Pé frio ou dormente com coloração azulada"),
                _buildBullet("Inchaço exagerado ou diferente do habitual"),

                const SizedBox(height: 20),
                _buildSectionTitle("🩹 O que fazer de imediato"),
                _buildBullet("Lave o pé suavemente com água e sabão neutro"),
                _buildBullet("Seque bem com uma toalha macia, sem esfregar"),
                _buildBullet("Evite apoiar o pé ou andar com ele"),
                _buildBullet("Não aplique cremes, pomadas ou pensos fechados"),
                _buildBullet("Procure ajuda médica imediatamente"),

                const SizedBox(height: 20),
                _buildSectionTitle("📞 Precisa de ajuda agora?"),
                _buildParagraph("Se está em dúvida ou apresenta algum dos sinais acima, não espere. Use o botão abaixo para contactar diretamente a Saúde 24 e receber orientação médica adequada.")


              ],
            ),
          ),
        )
      ),


    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.redAccent.shade400,
      ),
    ),
  );
}

Widget _buildBullet(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("•", style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

Widget _buildParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      textAlign: TextAlign.justify,
      style: GoogleFonts.roboto(fontSize: 16, height: 1.5),
    ),
  );
}

