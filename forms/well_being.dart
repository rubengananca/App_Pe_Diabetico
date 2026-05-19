import 'package:app_pe_diabetico/services/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/api/api_forms.dart';
import 'package:app_pe_diabetico/services/time_services.dart';

class WellBeing extends StatefulWidget {
  const WellBeing({super.key});

  @override
  State<WellBeing> createState() => _WellBeingState();
}

class _WellBeingState extends State<WellBeing> with TimeService {

  String? _painLevelController;
  String? _painPlaceController;
  String? _painDurationController;
  final _painDescriptionController = TextEditingController();
  String? _moodTodayController;
  String? _stressLevelController;
  final _timeController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _commentController = TextEditingController();

  final ApiForms _apiService = ApiForms();

  @override
  void dispose() {
    _painDescriptionController.dispose();
    _timeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void register() async {
    String? painLevel = _painLevelController;
    String? painPlace = _painPlaceController;
    String? painDuration = _painDurationController;
    String painDescription = _painDescriptionController.text;
    String? moodToday = _moodTodayController;
    String? stressLevel = _stressLevelController;
    String time = _timeController.text;
    String? comment = _commentController.text;

    if(painLevel == null || painPlace == null || painDuration == null || moodToday == null || stressLevel == null || time.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Esqueceu-se de preencher algo!"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Por favor preencha todos os campos obrigatórios!\n'),
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
          );
        },
      );
    }

    try {

      DateTime now = DateTime.now();
      String formattedTime = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${time.padLeft(5, '0')}:00Z";

      bool success = await _apiService.uploadWellBeingForms(pain_level: int.parse(painLevel), pain_place: painPlace, pain_duration: painDuration, pain_description: painDescription, mood_today: moodToday, stress_level: stressLevel, measurementTime: formattedTime, comment: comment);

      Navigator.pushNamedAndRemoveUntil(
        context,
        "/main",
            (Route<dynamic> route) => false, // remove todas as rotas anteriores
      );

      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Formulário preenchido com sucesso!"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Os seus dados foram registados.'),
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
          );
        },
      );
    } catch (e) {
      print("Erro na submicao: $e");
    }

  }

  Future<void> _pickTime() async {
    TimeOfDay? timeOfDay = await selectTime(context);

    if (timeOfDay != null){
      setState(() {
        selectedTime = timeOfDay;
        _timeController.text = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBege,
      appBar: AppBar(
        toolbarHeight: 40,
        centerTitle: true,
        backgroundColor: AppColors.backgroundBege,
        iconTheme: IconThemeData(
          color: AppColors.subtitlesText,
        ),
      ),
      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text("Registo de Dor e Bem-estar psicológico",
                style: GoogleFonts.roboto(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtitlesText
                ),
              ),

              Text("Introduza todas as informações relevantes.\nConsidere nas medições como 1 um nível de dor e stress inexistente e 10 insuportável.",
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.subtitlesText
                ),
              ),

              SizedBox(height: 22),

              Container(
                margin: EdgeInsetsDirectional.only(
                  start: 1.0,
                  end: 1.0,
                ),
                height: 1.0,
                color: Colors.grey.shade300,
              ),

              SizedBox(height: 22),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Nível de Dor (1-10)",
                  labelStyle: TextStyle(color: AppColors.darkBlueBorder),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.darkBlueBorder)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.subtitlesText)
                  ),
                  //border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                value: _painLevelController,
                items: List.generate(10, (index) {
                  final value = (index + 1).toString();
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _painLevelController = value;
                  });
                },
                validator: (value) => value == null ? "Escolha um valor de 1 a 10" : null,
              ),

              SizedBox(height: 22),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Local da Dor",
                  labelStyle: TextStyle(color: AppColors.darkBlueBorder),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.darkBlueBorder)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.subtitlesText)
                  ),
                  //border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                value: _painPlaceController,
                items: [
                  DropdownMenuItem(value: "Pé esquerdo", child: Text("Pé esquerdo")),
                  DropdownMenuItem(value: "Pé direito", child: Text("Pé direito")),
                  DropdownMenuItem(value: "Ambos", child: Text("Ambos")),
                  DropdownMenuItem(value: "Nenhum", child: Text("Nenhum")),
                ],
                onChanged: (value) {
                  setState(() {
                    _painPlaceController = value;
                  });
                },
                validator: (value) => value == null ? "Escolha local para a dor" : null,
              ),

              SizedBox(height: 22),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Duração da Dor",
                  labelStyle: TextStyle(color: AppColors.darkBlueBorder),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.darkBlueBorder)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.subtitlesText)
                  ),
                  //border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                value: _painDurationController,
                items: [
                  DropdownMenuItem(value: "Momentânea", child: Text("Momentânea")),
                  DropdownMenuItem(value: "Menos de 1 hora", child: Text("Menos de 1 hora")),
                  DropdownMenuItem(value: "Entre 1 a 3 horas", child: Text("Entre 1 a 3 horas")),
                  DropdownMenuItem(value: "Mais de 3 horas", child: Text("Mais de 3 horas")),
                ],
                onChanged: (value) {
                  setState(() {
                    _painDurationController = value;
                  });
                },
                validator: (value) => value == null ? "Escolha duração para a dor" : null,
              ),

              SizedBox(height: 22),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Humor hoje",
                  labelStyle: TextStyle(color: AppColors.darkBlueBorder),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.darkBlueBorder)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.subtitlesText)
                  ),
                  //border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                value: _moodTodayController,
                items: [
                  DropdownMenuItem(value: "Calmo", child: Text("Calmo")),
                  DropdownMenuItem(value: "Ansioso", child: Text("Ansioso")),
                  DropdownMenuItem(value: "Triste", child: Text("Triste")),
                  DropdownMenuItem(value: "Irritado", child: Text("Irritado")),
                  DropdownMenuItem(value: "Motivado", child: Text("Motivado")),
                ],
                onChanged: (value) {
                  setState(() {
                    _moodTodayController = value;
                  });
                },
                validator: (value) => value == null ? "Escolha um humor para o dia" : null,
              ),

              SizedBox(height: 22),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Nível de Stress (1-10)",
                  labelStyle: TextStyle(color: AppColors.darkBlueBorder),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.darkBlueBorder)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppColors.subtitlesText)
                  ),
                  //border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                value: _stressLevelController,
                items: List.generate(10, (index) {
                  final value = (index + 1).toString();
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _stressLevelController = value;
                  });
                },
                validator: (value) => value == null ? "Escolha um valor de 1 a 10" : null,
              ),

              SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("O que pode ter causado a dor",
                  style: GoogleFonts.roboto(
                    color: AppColors.darkBlueBorder,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: TextField(
                  controller: _painDescriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.roboto(color: Colors.black),
                  decoration: InputDecoration(
                    //labelText: "Hora de Medição",
                      labelStyle: GoogleFonts.roboto(color: AppColors.darkBlueBorder),
                      //filled: true,
                      //prefixIcon: Icon(Icons.access_time_rounded, color: Color(0xFF9E7545),),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.darkBlueBorder)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.subtitlesText)
                      )
                  ),
                ),
              ),

              SizedBox(height: 22),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("Hora da Medição",
                  style: GoogleFonts.roboto(
                    color: AppColors.darkBlueBorder,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: _timeController,
                style: GoogleFonts.roboto(color: Colors.black),
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time_rounded, color: AppColors.subtitlesText),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: AppColors.darkBlueBorder)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: AppColors.subtitlesText)
                    )
                ),
                readOnly: true,
                onTap: (){
                  _pickTime();
                },
              ),


              SizedBox(height: 22),

              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("Comentário adicional",
                  style: GoogleFonts.roboto(
                    color: AppColors.darkBlueBorder,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: TextField(
                  controller: _commentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.roboto(color: Colors.black),
                  decoration: InputDecoration(
                    //labelText: "Hora de Medição",
                      labelStyle: GoogleFonts.roboto(color: AppColors.darkBlueBorder),
                      //filled: true,
                      //prefixIcon: Icon(Icons.access_time_rounded, color: Color(0xFF9E7545),),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.darkBlueBorder)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.subtitlesText)
                      )
                  ),
                ),
              ),

              SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                      backgroundColor: AppColors.subtitlesText,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      )
                  ),
                  child: Text("Submeter",
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.5
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40,)
              
            ],
          ),
        ),
      ),

    );
  }
}
