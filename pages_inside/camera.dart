import 'dart:convert';
import 'dart:io';
import 'package:app_pe_diabetico/api/api_camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import "../services/camera_funcionalities.dart";


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with Camera_Functionalities {

  // O ponto de interrogacao indica que a variavel pode ser nula
  // Util para inicia-la a valor nulo (?). Pode-se usar o "!" para garantir que nao seja nulo
  final ApiService apiService = ApiService();
  File? image;

  Future<void> _captureImageFromCamera() async {
    print("✅ Entrou em _captureImageFromCamera");


    // o "final" indica que a variavel so pode ser atribuida uma vez.
    // Após isso torna-se imutavel - importante para que o valor nao seja alterado
    final imageCaptured = await ImagePicker().pickImage(
        source: ImageSource.camera
    );

    print("➡️ Saiu do ImagePicker"); // ADICIONA ISTO

    if(imageCaptured != null){
      File compressedImage = await compressImage(File(imageCaptured.path));
      String imageBase64 = await convertToBase64(compressedImage);

      setState(() {
        image = compressedImage;
      });

      String timestamp = DateTime.now().toIso8601String();
      // faz upload da imagem na api na mesma
      bool success = await apiService.uploadImage(imageBase64, timestamp);

      final result = await apiService.analyzeImage(imageBase64);

      /*if (success){
        print("Camera: Imagem enviada com sucesso");
      } else {
        print("Erro ao guardar a imagem no servidor");
      }

      await saveImageToGallery(image!.path); // guarda na galeria*/

      if (result != null && result["success"] == true) {

        final processedBase64 = result["overlay_image"];
        final savedPath = await saveBase64ToFile(processedBase64);

        Navigator.pushNamed(
          context,
          "/image_page",
          arguments: {
            "base64DataOriginal": imageBase64,
            "base64DataProcessada": processedBase64,
            "timestamp": timestamp,
            "results": jsonEncode(result["results"])
          }
        );
      } else {
        print("Erro ao processar imagem");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3E6DF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFE3E6DF),
        title: Text("Camera",
          style: GoogleFonts.roboto(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: image == null ? // se nao tiver escolhido ainda nenhuma image, ou se ja tiver escolhido mostra a imagem
        Text("No image Selected", style: GoogleFonts.roboto(),) :
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.file(image!)),

          ],
        )
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Color(0xFF008597),
            heroTag: 'galleryButton', // Unique hero tag
            onPressed: () { //_pickImageFromGallery,
              Navigator.pushNamed(
                  context,
                  "/galery",

              );
            },
            shape: RoundedRectangleBorder( // Define bordas arredondadas
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10.0),
          FloatingActionButton(
            backgroundColor: Color(0xFF008597),
            heroTag: 'cameraButton', // Unique hero tag
            onPressed: _captureImageFromCamera,
            shape: RoundedRectangleBorder( // Define bordas arredondadas
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
