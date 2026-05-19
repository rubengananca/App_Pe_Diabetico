import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/api/api_practitioner.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LinkUserPractitionerPage extends StatefulWidget {
  const LinkUserPractitionerPage({super.key});

  @override
  State<LinkUserPractitionerPage> createState() => _LinkUserPractitionerPageState();
}

class _LinkUserPractitionerPageState extends State<LinkUserPractitionerPage> {

  final _codeController = TextEditingController();
  final ApiPractitioner apiService = ApiPractitioner();

  @override
  void initState() {
    super.initState();
    _checkAssociationOnStart();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkAssociationOnStart() async {
    final result = await apiService.getAssociation();

    if (result != null) {
      print("Utilizador já está associado ao médico com ID: ${result['practitioner_id']}");
    } else {
      print("Utilizador ainda não tem médico associado.");
    }
  }

  void _linkUserToPractitioner() async {
    String code = _codeController.text;
    var associationStatus = apiService.associateUserWithPractitioner(code);


    if (await associationStatus){
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Associou o médico com sucesso!"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Foi possível associá-lo a um médico\n'),
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
    }else{
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Não existe um médico com esse código!"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Tente preencher com um código válido.\n'),
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

  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        centerTitle: true,
        backgroundColor: AppColors.backgroundGreen,
        iconTheme: IconThemeData(
          color: AppColors.textDarkGreen,
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
                  child: Text("Associação com um médico",
                    style: GoogleFonts.roboto(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkGreen
                    ),
                  ),
                ),

                Container(
                  child: Text("Introduza um código válido para se associar a um médico",
                    style: GoogleFonts.roboto(
                        fontSize: 12.0,
                        color: AppColors.textDarkGreen
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
                  color: AppColors.textDarkGreen,
                ),

                SizedBox(height: 22),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Código do médico",
                    style: GoogleFonts.roboto(
                      color: AppColors.textDarkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: _codeController,
                  //keyboardType: TextInputType.,
                  style: GoogleFonts.roboto(color: AppColors.textDarkGreen),
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.textDarkGreen)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.focusedBorderGreen)
                      )
                  ),
                ),


                SizedBox(height: 40),

                Center(
                  child: ElevatedButton(
                    onPressed: _linkUserToPractitioner,
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                        backgroundColor: AppColors.textDarkGreen,
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
              ]
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // puxa para o lado direito
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 65),
        child: FloatingActionButton(
            heroTag: "practitioner_codes",
            tooltip: "Contactar profissional de saúde",
            shape: RoundedRectangleBorder( // Define bordas arredondadas
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: Colors.white,
            child: Icon(Icons.message_rounded, color: AppColors.subtitlesText, size: 25,),
            onPressed: (){
              Navigator.pushNamed(context, "/practitioner_list");
            }
        ),
      ),
    );
  }
}
