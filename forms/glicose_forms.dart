import 'package:app_pe_diabetico/services/time_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:app_pe_diabetico/api/api_forms.dart';

class GlicoseForms extends StatefulWidget {
  const GlicoseForms({super.key});

  @override
  State<GlicoseForms> createState() => _GlicoseFormsState();
}

class _GlicoseFormsState extends State<GlicoseForms> with TimeService{

  final _glicoseController = TextEditingController();
  final _timeController = TextEditingController();
  String? _stateMeasuserController;
  final _commentController = TextEditingController();

  final ApiForms _apiService = ApiForms();

  TimeOfDay selectedTime = TimeOfDay.now();
  List<String> options = ["Em jejum", "Antes da refeição", "Depois da refeição", "Antes de dormir", "Outro"];

  @override
  void dispose() {
    _glicoseController.dispose();
    _timeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void register() async {
    String glicoseValue = _glicoseController.text;
    String time = _timeController.text;
    String? stateMeasure = _stateMeasuserController;
    String? comment = _commentController.text;

    if(glicoseValue.isEmpty || time.isEmpty || stateMeasure==null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Esqueceu-se de preencher algo!"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Por favor preencha todos os campos!\n'),
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

      bool success = await _apiService.uploadGlicoseForms(
        glicoseValue: int.parse(glicoseValue), measurementTime: formattedTime, stateMeasure: stateMeasure, comment: comment);


      if (success){
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
      } else {
        throw Exception("Falha no registo!");
      }

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

                Container(
                  child: Text("Registo da Glicemia",
                    style: GoogleFonts.roboto(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.subtitlesText
                    ),
                  ),
                ),

                Container(
                  child: Text("Introduza todas as informações relevantes para um registo eficaz",
                    style: GoogleFonts.roboto(
                        fontSize: 12.0,
                        color: AppColors.subtitlesText
                    ),
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


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Valor da Glicemia (mg/dL)",
                    style: GoogleFonts.roboto(
                      color: AppColors.darkBlueBorder,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: _glicoseController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.roboto(color: Colors.black),
                  decoration: InputDecoration(
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

                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Estado da Medição",
                    style: GoogleFonts.roboto(
                      color: AppColors.darkBlueBorder,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Column(
                  children: options.map((option) =>
                      RadioListTile(
                          activeColor: AppColors.subtitlesText,
                          dense: true,
                          title: Text(option,
                            style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                          value: option,
                          groupValue: _stateMeasuserController,
                          onChanged: (value) {
                            setState(() {
                              _stateMeasuserController = value.toString();
                            });
                          }
                      )
                  ).toList(),
                ),

                SizedBox(height: 30),

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

              ]
          ),
        ),
      ),
    );
  }
}
