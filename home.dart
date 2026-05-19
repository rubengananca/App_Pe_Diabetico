import 'package:app_pe_diabetico/login.dart';
import 'package:app_pe_diabetico/register.dart';
import 'package:app_pe_diabetico/services/route_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // pre carregamento da imagem
    precacheImage(const AssetImage("assets/hospital_care.jpg"), context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/hospital_care.jpg", fit: BoxFit.cover)
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            )
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[

                  SizedBox(height: 200),

                  Text("Olá!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  )),
                  //SizedBox(height: 10),

                  Text(
                    "Acompanhe a saúde dos seus pés",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),

                  SizedBox(height: 300),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                      elevation: 0.5,
                      backgroundColor: AppColors.buttonBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text("Registar",
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2
                        )
                    ),
                    onPressed: () {
                      Navigator.push(context, RouteNavRightLeft(Register()));
                    },
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 93.5),
                      elevation: 0.5,
                      backgroundColor: AppColors.focusedBorderGreen,
                      //backgroundColor: AppColors.loadingSecondRing,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text("Login",
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2
                        )
                      ),
                    onPressed: () {
                      Navigator.push(context, RouteNavRightLeft(LoginPage()));
                    },
                  ),
                ]
              )
            ),
          )
        ],

      ),

    );
  }
}
