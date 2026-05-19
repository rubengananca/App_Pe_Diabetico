import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_pe_diabetico/api/api_forms.dart';

class StatisticsGlicosePage extends StatefulWidget {
  const StatisticsGlicosePage({super.key});

  @override
  State<StatisticsGlicosePage> createState() => _StatisticsGlicosePageState();
}

class _StatisticsGlicosePageState extends State<StatisticsGlicosePage> {

  String _selectedRange = "week";
  final ApiForms _apiService = ApiForms();
  late List<Map<String,dynamic>>? _listaRelatoriosGlicose;
  List<(DateTime, int)> _dadosNoIntervalo = [];
  bool _loading = true;

  Future<List<(DateTime,int)>> dadosNoIntervalo(String range) async{
    final currentDate = DateTime.now();
    final inicioDaSemana = currentDate.subtract(Duration(days: 7));
    final inicioDoMes = currentDate.subtract(Duration(days: 30));

    _listaRelatoriosGlicose = await _apiService.getFormsInfo("glicose");
    List<(DateTime,int)> listaDeValores = [];

    for (var elemento in _listaRelatoriosGlicose ?? []){
      try {
        // converte a string para data
        final measurementTime = DateTime.parse(elemento["measurement_time"]);

        if (range == "week" && measurementTime.isAfter(inicioDaSemana)){
          final glicoseValue = int.parse(elemento["glicose_value"]);
          listaDeValores.add((measurementTime,glicoseValue));
        } else if (range == "month" && measurementTime.isAfter(inicioDoMes)){
          final glicoseValue = int.parse(elemento["glicose_value"]);
          listaDeValores.add((measurementTime,glicoseValue));
        }

      } catch (e) {
        print("Erro ao processar elemento: $e");
      }
    }

    return listaDeValores;
  }

  List<dynamic> dadosEstatistica(List<(DateTime,int)> listaDeValores){
    late double media;
    List<dynamic> listaEstatistica = [];

    if (listaDeValores.isNotEmpty){

      final copiaOrdenada = List<(DateTime, int)>.from(listaDeValores); // copia a lista para trablhar com uma copia e nao trabalhar com a original
      copiaOrdenada.sort((a,b) => a.$2.compareTo(b.$2)); // ordena de forma crescente de acordo com os valores na segunda posicao do tuplo (glicose)
      int maximo = copiaOrdenada.last.$2;
      int minimo = copiaOrdenada[0].$2;

      // fold e um metodo iterativo que começa em 0 e soma um determinado valor iterativamente, no caso, soma ao contador (vem de cada iteração) o valor da glicose
      int soma = copiaOrdenada.fold(0, (contador, val) => contador + val.$2);
      media = soma / copiaOrdenada.length;

      listaEstatistica.add(minimo);
      listaEstatistica.add(maximo);
      listaEstatistica.add(media);
    } else {
      return [];
    }

    return listaEstatistica;
  }

  List<FlSpot> _generateData(List<(DateTime,int)> listaDeValores) {
    return List.generate(listaDeValores.length, (i) {
      return FlSpot(i.toDouble(), listaDeValores[i].$2.toDouble());
    });
  }

  void _atualizarDados(String intervalo) async {
    final novosDados = await dadosNoIntervalo(intervalo);
    novosDados.sort((a, b) => a.$1.compareTo(b.$1));
    setState(() {
      _selectedRange = intervalo;
      _dadosNoIntervalo = novosDados;
    });
  }

  @override
  void initState() {
    super.initState();
    dadosNoIntervalo("week").then((valores) {
      valores.sort((a, b) => a.$1.compareTo(b.$1));
      setState(() {
        _dadosNoIntervalo = valores;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _listaRelatoriosGlicose?.clear(); // OPICIONAL: se a lista for muito grande
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Estatística da Glicemia")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _generateData(_dadosNoIntervalo);
    final listaEstatistica = dadosEstatistica(_dadosNoIntervalo);

    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Estatística da Glicemia",
          style: GoogleFonts.roboto(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF93B5B1),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),


      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Intervalo de tempo",
              style: GoogleFonts.roboto(
                fontSize: 16, fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            // botoes de selecao de intervalo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text("Última semana",
                    style: TextStyle(
                      color: _selectedRange == 'week' ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  selected: _selectedRange == 'week',
                  selectedColor: Color(0xFF93B5B1),
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) => setState(() {
                    _atualizarDados("week");
                  }),
                ),

                SizedBox(width: 12),

                ChoiceChip(
                  label: Text("Último mês",
                    style: TextStyle(
                      color: _selectedRange == 'month' ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  selected: _selectedRange == 'month',
                  selectedColor: Color(0xFF93B5B1),
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) => setState(() {
                    _atualizarDados("month");
                  }),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Grafico
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Gráfico da Glicemia",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A8078)
                      ),
                    ),

                    SizedBox(height: 12),

                    SizedBox(
                      height: 300,
                      child: _dadosNoIntervalo.isEmpty ?
                        Center(
                          child: Text("Nenhum dado disponível para exibir no gráfico",
                            style: GoogleFonts.roboto(),
                          ),
                        ) :

                        LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 200,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 30,
                                  reservedSize: 35,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false
                                )
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= _dadosNoIntervalo.length) return Container();
                                    final date = _dadosNoIntervalo[index].$1;
                                    final mes = date.month.toString().padLeft(2, "0");
                                    final dia = date.day.toString().padLeft(2, '0');
                                    final hora = date.hour.toString().padLeft(2, '0');
                                    final minuto = date.minute.toString().padLeft(2, '0');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text("$dia/$mes\n$hora:$minuto", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                                    );
                                  }
                                )
                              )
                            ),

                            lineBarsData: [
                              LineChartBarData(
                                spots: data,
                                isCurved: true,
                                color: Color(0xFFFF6B6B),
                                barWidth: 3,
                                dotData: FlDotData(show: true)
                              )
                            ],
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false)
                          )

                        )
                    ),
                  ],
                ),
              ),
            ),


            SizedBox(height: 32),

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
                        Text("Estatísticas",
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A8078)
                          ),
                        ),

                        SizedBox(width: 160),
                        Icon(Icons.bar_chart_rounded, color: Color(0xFF4A8078)),
                      ],
                    ),

                    SizedBox(height: 16),

                    if (listaEstatistica.isEmpty)
                      Text("Sem dados disponíveis",
                        style: GoogleFonts.roboto(fontSize: 12),
                      )
                    else ... [
                      estatisticaItem("Valor mínimo", listaEstatistica[0].toString()),
                      estatisticaItem("Valor máximo", listaEstatistica[1].toString()),
                      estatisticaItem("Média", listaEstatistica[2].toStringAsFixed(1)),
                    ]
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}

Widget estatisticaItem(String label, String valor) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.roboto(fontSize: 14)),
        Text(valor, style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14))
      ],
    ),
  );
}
