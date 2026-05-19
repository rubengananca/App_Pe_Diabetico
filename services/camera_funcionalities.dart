import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:app_pe_diabetico/api/api_camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Como a classe nao recebe parametros nao precisa de construtor
mixin Camera_Functionalities {

  final ApiService apiService = ApiService();

  // Foram alterados valores para que a imagem nao seja tao grande
  Future<File> compressImage(File image) async {
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path, "${image.path}_compress.jpg",
      quality: 40, // define a qualidade da compressao
      minWidth: 600,  // Reduz a largura da imagem
      minHeight: 400,
    );

    // Ensure that compressedImage is not null before returning
    if (compressedImage != null) {
      return File(compressedImage.path); // Converte XFile (tipo de dado retornado pelo FlutterImageCompress) em File
    } else {
      throw Exception("Image compression failed");
    }
  }

  Future<void> saveImageToGallery(String imagePath) async {

    final result = await ImageGallerySaverPlus.saveFile(imagePath);
    if (result["isSuccess"]) {
      print("Imaged Saved to gallery");
    } else {
      print("Failed to save image");
    }
  }

  Future<String> convertToBase64(File compressedImage) async {
    Uint8List bytes = await compressedImage.readAsBytes();
    String base64String = base64.encode(bytes);

    return base64String;
  }

  String convertData(String timestamp){
    DateTime dateTime = DateTime.parse(timestamp);
    String formattedDate = DateFormat("dd/MM/yyyy").format(dateTime);
    return formattedDate;
  }

  Future<void> captureImageFromCamera(BuildContext context) async {

    final imageCaptured = await ImagePicker().pickImage(
        source: ImageSource.camera
    );

    if(imageCaptured != null){

      showDialog(
        context: context,
        barrierDismissible: false, // o utilizador não pode sair ao clicar fora
        builder: (context) => Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: Colors.white,
            size: 100,
            secondRingColor: AppColors.loadingSecondRing,
            thirdRingColor: AppColors.loadingThirdRing,
          ),
        ),
      );

      try {
        File compressedImage = await compressImage(File(imageCaptured.path));
        String imageBase64 = await convertToBase64(compressedImage);
        final startTime = DateTime.now();

        String timestamp = DateTime.now().toIso8601String();
        bool success = await apiService.uploadImage(imageBase64, timestamp);
        final result = await apiService.analyzeImage(imageBase64);

        final endTime = DateTime.now();
        final totalTime = endTime.difference(startTime).inMilliseconds;

        if (Navigator.canPop(context)) Navigator.pop(context);

        if (result != null && result["success"] == true) {

          var processedBase64 = result["overlay_image"];

          if (processedBase64 == null || processedBase64 is! String) {

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Ocorreu um problema na submissão da foto!"),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Por favor tente de novo submeter uma fotografia!\n'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK',
                      style: TextStyle(
                          color: AppColors.subtitlesText
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );

            return;
          }

          if (processedBase64.contains(',')) {
            processedBase64 = processedBase64.split(',')[1];
          }


          //final savedPath = await saveBase64ToFile(processedBase64);

          Navigator.pushNamed(
              context,
              "/image_page",
              arguments: {
                "base64DataOriginal": imageBase64,
                "base64DataProcessada": processedBase64,
                "num_detections": result["num_detections"],
                "timestamp": timestamp,
                "results": jsonEncode(result["results"])
              }
          );
        } else {
          print("Erro ao processar imagem");
        }

        await saveImageToGallery(compressedImage.path); // guarda na galeria
      } catch (e) {

        if (Navigator.canPop(context)) Navigator.pop(context);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erro"),
            content: Text("Ocorreu um erro: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: AppColors.subtitlesText)),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String> saveBase64ToFile(String base64Image) async {

    final bytes = base64Decode(base64Image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png";
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}