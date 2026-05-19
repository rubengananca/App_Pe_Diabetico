import 'dart:typed_data';
import 'package:app_pe_diabetico/services/ImageModel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app_pe_diabetico/services/camera_funcionalities.dart';
import 'package:google_fonts/google_fonts.dart';

class ImagesPage extends StatelessWidget with Camera_Functionalities {

  @override
  Widget build(BuildContext context) {

    /*final Map<String, String> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    ImageModel imageModel = ImageModel.fromMap(arguments);*/

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final original = base64Decode(args["base64DataOriginal"]);
    var processed = base64Decode(args["base64DataProcessada"]);

    final timestamp = args["timestamp"];
    final results = jsonDecode(args["results"]);

    String traduzirTipo(String? tipoIngles) {
      switch (tipoIngles) {
        case "Ischaemia":
          return "Isquemia";
        case "Infected":
          return "Infetado";
        default:
          return tipoIngles ?? "N/A";
      }
    }

    String formatarPercentual(dynamic valor) {
      if (valor is num) {
        return "${(valor * 100).toStringAsFixed(1)}%";
      }
      return "N/A";
    }

    return Scaffold(
      backgroundColor: Color(0xFFE3E6DF),
      appBar: AppBar(
        backgroundColor: Color(0xFF627E67),
        iconTheme: IconThemeData(
          color: Color(0xFFE3E6DF),
        ),
        title: Text(
          "Informações da Foto",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE3E6DF),
            letterSpacing: 1.5
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(13),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 360,
                child: PageView(
                  controller: PageController(
                    viewportFraction: 0.80
                  ),

                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStyledImage(
                      original,
                      label: "Original"
                    ),

                    _buildStyledImage(
                      processed,
                      label: "Processada"
                    )

                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Text("Informações",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF627E67)
                          ),
                        ),

                        const Spacer(),
                        Icon(Icons.info, color: Color(0xFF627E67)),
                      ],
                    ),


                    SizedBox(height: 16),

                    _infoItem("Data da fotografia", convertData(timestamp)),
                    /*_infoItem("Tipo de Ferida", "Úlcera"),
                    _infoItem("Largura da Ferida", "300"),
                    _infoItem("Altura da Ferida", "300"),*/

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < results.length; i++) ... [
                          SizedBox(height: 12),

                          Text("Ferida ${i+1}",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF627E67)
                            ),
                          ),

                          SizedBox(height: 8),

                          _infoItem("Tipo",
                              traduzirTipo(results[i]["classification"]?["class_name"])
                          ),

                          _infoItem(
                            "Confiança (classificação)",
                            formatarPercentual(results[i]["classification"]?["confidence"])
                          ),

                          _infoItem(
                            "Confiança (deteção)",
                            formatarPercentual(results[i]["detection"]?["confidence"])
                          ),

                          _infoItem(
                            "Área (px²)",
                            results[i]["segmentation"]?["area_pixels"]?.toString() ?? "N/A",
                          ),

                          _infoItem(
                            "Perímetro (px)",
                            results[i]["segmentation"]?["perimeter_pixels"]?.toString() ?? "N/A",
                          ),

                          Divider(height: 20),
                        ]
                      ],
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),

      ),

    );
  }
}

Widget _buildStyledImage(Uint8List imageBytes, {required String label}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: Column(
      children: [
        Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4)
                    )
                  ]
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  imageBytes, // Converte Base64 para imagem
                  fit: BoxFit.cover,
                  width: 260,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                  },
                ),
              ),
            )
        ),

        const SizedBox(height: 8),

        Text(label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5D4E)
          ),
        )
      ],
    ),
  );
}

Widget _infoItem(String label, String valor) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        Text(valor, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14))
      ],
    ),
  );
}


