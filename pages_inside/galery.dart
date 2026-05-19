import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/api/api_camera.dart';
import 'dart:convert'; // Import necessário para base64
import 'package:app_pe_diabetico/services/ImageModel.dart';
import 'package:app_pe_diabetico/services/camera_funcionalities.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Galery extends StatefulWidget {
  const Galery({super.key});

  @override
  State<Galery> createState() => _GaleryState();

}

class _GaleryState extends State<Galery> with Camera_Functionalities {

  final ApiService _apiService = ApiService();
  late Future<List<ImageModel>> _imageFuture;

  @override
  // garante que a api só é chamada quando esta página é aberta
  void initState() {
    super.initState();
    _imageFuture = _loadImages();
  }

  void _refreshImages() {
    setState(() {
      _imageFuture = _loadImages();
    });
  }

  Future<List<ImageModel>> _loadImages() async {
    final images = await _apiService.getImages();
    return images.reversed.toList();
  }

  void _loadImagesPage(ImageModel imageModel) async {

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
      final result = await apiService.analyzeImage(imageModel.base64Data);
      if (Navigator.canPop(context)) Navigator.pop(context);

      if (result != null && result["success"] == true) {

        var processedBase64 = result["overlay_image"];

        if (processedBase64 == null || processedBase64 is! String) {

          //if (Navigator.canPop(context)) Navigator.pop(context);

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

        Navigator.pushNamed(
            context,
            "/image_page",
            arguments: {
              "base64DataOriginal": imageModel.base64Data,
              "base64DataProcessada": processedBase64,
              "num_detections": result["num_detections"],
              "timestamp": imageModel.timestamp,
              "results": jsonEncode(result["results"])
            }
        );
      } else {
        print("Erro ao processar imagem");
      }
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const  Color(0xFFE3E6DF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFE3E6DF),
          title: Text("Galeria",
            style: GoogleFonts.roboto(
              fontSize: 22,
              color: Color(0xFF4A5D4E),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5
            ),
          ),

          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),

          actions: [
            IconButton(
              onPressed: _refreshImages, icon: Icon(Icons.refresh),
              color: const Color(0xFF4A5D4E),
            )
          ],
        ),

        body: FutureBuilder<List<ImageModel>> (
          future: _imageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  size: 100,
                  secondRingColor: AppColors.loadingSecondRing,
                  thirdRingColor: AppColors.loadingThirdRing
              ),);
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Nenhuma imagem encontrada."));
            }

            return GridView.builder( // se nao estiver vazio mostra a galeria
                padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // numero de colunas
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 18.0,
                ),
                itemCount: snapshot.data?.length,


                itemBuilder: (context, index){
                  var imageModel = snapshot.data![index]; //Acede ao Map

                return _buildImage(
                  onTap: () {
                    /*Navigator.pushNamed(context,
                      "/image_page",
                      arguments: imageModel.toMap()
                    );*/
                    _loadImagesPage(imageModel);
                  },
                  imageModel: imageModel,
                  text: convertData(imageModel.timestamp)
                );
                }
            );
          },
        ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
          backgroundColor: Color(0xFF627E67),
          shape: RoundedRectangleBorder( // Define bordas arredondadas
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () => captureImageFromCamera(context),
          child: Icon(Icons.camera_alt,
            color: Colors.white
          )

        ),
      ),

    );
  }
}



// Widget para itens da Lista
Widget _buildImage(
    {required VoidCallback onTap, required ImageModel imageModel, required String text})
{
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),

    // Permite reconhecer e responder a vários gestos de toque (deslizar, tocar duas vezes, arrastar...)
    child: GestureDetector(
      onTap: onTap,

      child: Column(
          children: [
            Expanded(
              child: imageModel.base64Data.isNotEmpty
                ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.memory(
                      base64Decode(imageModel.base64Data),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 100, color: Colors.grey,)
                      ,
                    ),
                  ),
                )

              : Icon(Icons.broken_image, size: 100, color: Colors.grey)
            ),

            const SizedBox(height: 5),

            Text(text, style: GoogleFonts.roboto(fontSize: 12.0))
          ]
      )
    ),
  );
}

