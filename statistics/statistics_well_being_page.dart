import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_pe_diabetico/api/api_forms.dart';

class StatisticsWellBeingPage extends StatefulWidget {
  const StatisticsWellBeingPage({super.key});

  @override
  State<StatisticsWellBeingPage> createState() => _StatisticsWellBeingPageState();
}

class _StatisticsWellBeingPageState extends State<StatisticsWellBeingPage> {

  String _selectedRange = "week";
  final ApiForms _apiService = ApiForms();
  late List<Map<String,dynamic>>? _listaRelatoriosBemEstar;

  List<(DateTime, int)> _dadosDor = [];
  List<(DateTime, int)> _dadosStress = [];

  bool _loading = true;

  Future<void> _carregarDados(String range) async{
    setState(() => _loading = true);

    final dadosDor = await _dadosGrafico(range,"pain_level");
    final dadosStress = await _dadosGrafico(range, "stress_level");

    setState(() {
      _dadosDor = dadosDor;
      _dadosStress = dadosStress;
      _loading = false;
    });
  }

  Future<List<(DateTime,int)>> _dadosGrafico(String range, String campo) async{
    final currentDate = DateTime.now();
    final inicioDaSemana = currentDate.subtract(Duration(days: 7));
    final inicioDoMes = currentDate.subtract(Duration(days: 30));

    _listaRelatoriosBemEstar = await _apiService.getFormsInfo("well_being");
    List<(DateTime,int)> listaDeValores = [];

    for (var elemento in _listaRelatoriosBemEstar ?? []){
      try {
        // converte a string para data
        final measurementTime = DateTime.parse(elemento["measurement_time"]);
        final isSemana = range == "week" && measurementTime.isAfter(inicioDaSemana);
        final isMes = range == "month" && measurementTime.isAfter(inicioDoMes);

        if (isSemana || isMes) {
          final value = int.parse(elemento[campo].toString());
          listaDeValores.add((measurementTime, value));
        }

      } catch (e) {
        print("Erro ao processar elemento: $e");
      }
    }

    listaDeValores.sort((a,b) => a.$1.compareTo(b.$1)); //ordena a lista por ordem crescente de datas
    return listaDeValores;
  }


  List<dynamic> _dadosEstatistica(List<(DateTime,int)> dados){
    late double media;
    List<dynamic> listaEstatistica = [];

    if (dados.isNotEmpty){

      final copiaOrdenada = List<(DateTime, int)>.from(dados); // copia a lista para trablhar com uma copia e nao trabalhar com a original
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
      return [0,0,0.0];
    }

    return listaEstatistica;
  }

  Future<List<int>> _contadorLocalDeDor (String range) async{
    final currentDate = DateTime.now();
    final inicioDaSemana = currentDate.subtract(Duration(days: 7));
    final inicioDoMes = currentDate.subtract(Duration(days: 30));

    final listaRelatorios = await _apiService.getFormsInfo("well_being");

    if (listaRelatorios?.isEmpty ?? true) return [0,0,0,0];

    int contadorPeEsquerdo = 0;
    int contadorPeDireito = 0;
    int contadorAmbosPes = 0;
    int contadorNenhumPe = 0;

    for (var elemento in listaRelatorios!) {
      try {
        final measurementTime = DateTime.parse(elemento["measurement_time"]);

        // verifica se está no intervalo
        final isDentroDoIntervalo = range == "week"
            ? measurementTime.isAfter(inicioDaSemana)
            : measurementTime.isAfter(inicioDoMes);

        // se não estiver dentro do intervalo salta esta iteração do for e passa para a proxima iteração
        if (!isDentroDoIntervalo) continue;

        if (elemento["pain_place"] == "Pé esquerdo"){
          contadorPeEsquerdo ++;
        } else if (elemento["pain_place"] == "Pé direito"){
          contadorPeDireito ++;
        } else if (elemento["pain_place"] == "Ambos"){
          contadorAmbosPes ++;
        } else if (elemento["pain_place"] == "Ambos"){
          contadorNenhumPe ++;
        }
      } catch (e) {
        print("Erro ao fazer contadores: $e");
      }
    }

    return [contadorPeEsquerdo,contadorPeDireito,contadorAmbosPes,contadorNenhumPe];
  }

  List<FlSpot> _generateData(List<(DateTime,int)> listaDeValores) {
    return List.generate(listaDeValores.length, (i) {
      return FlSpot(i.toDouble(), listaDeValores[i].$2.toDouble());
    });
  }


  @override
  void initState() {
    super.initState();
    _carregarDados(_selectedRange);
  }

  @override
  void dispose() {
    _listaRelatoriosBemEstar?.clear(); // OPICIONAL: se a lista for muito grande
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Estatística do Bem Estar")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    

    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Estatística do Bem Estar",
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
                    _selectedRange = "week";
                    _carregarDados("week");
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
                    _selectedRange = "month";
                    _carregarDados("month");
                  }),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Grafico
            _construirGrafico("Nível de Dor", _dadosDor, Color(0xFFFF6B6B)),
            //_construirEstatistica("Estatística de Dor", _dadosEstatistica(_dadosDor)),
            FutureBuilder<List<int>>(
              future: _contadorLocalDeDor(_selectedRange),
              builder: (context, snapshot) {
                final contadoresDor = snapshot.data ?? [0, 0, 0, 0];
                return _construirEstatisticaDaDor(
                  "Estatísticas de Dor",
                  _dadosEstatistica(_dadosDor),
                  contadoresDor,
                );
              },
            ),

            SizedBox(height: 24),

            _construirGrafico("Nível de Stress", _dadosStress, Color(0xFF6B8CFF)),
            _construirEstatistica("Estatística de Stress", _dadosEstatistica(_dadosStress))

          ],
        ),
      ),
    );
  }

  Widget _estatisticaItem(String label, String valor) {
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

  Widget _construirGrafico(String titulo, List<(DateTime, int)> dados, Color cor){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titulo,
              style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A8078)
              ),
            ),

            SizedBox(height: 12),

            SizedBox(
                height: 300,
                child: dados.isEmpty ?
                Center(
                  child: Text("Nenhum dado disponível para exibir no gráfico",
                    style: GoogleFonts.roboto(),
                  ),
                ):
                LineChart(
                    LineChartData(
                        minY: 0,
                        maxY: 10,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 30,
                                getTitlesWidget: (value,meta) => Text(value.toInt().toString())
                            ),
                          ),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= dados.length) return Container();
                                    final date = dados[index].$1;
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
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false
                              )
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                              spots: _generateData(dados),
                              isCurved: false,
                              color: cor,
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
    );
  }

  Widget _construirEstatisticaLocalDaDor (List<int> contadores){
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Localização da Dor",
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A8078)
            ),
          ),

          SizedBox(height: 12),

          if (contadores.isEmpty)
            Text("Sem dados disponíveis",
              style: GoogleFonts.roboto(fontSize: 12),
            )
          else ... [
            _estatisticaItem("Pé esquerdo", contadores[0].toString()),
            _estatisticaItem("Pé direito", contadores[1].toString()),
            _estatisticaItem("Ambos os pés", contadores[2].toString()),
            _estatisticaItem("Nenhum", contadores[3].toString()),
          ]
        ],
      ),
    );
  }

  Widget _construirEstatistica (String titulo, List<dynamic> estatistica){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Text(titulo,
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A8078)
                  ),
                ),
                Spacer(),
                //SizedBox(width: 160),
                Icon(Icons.bar_chart_rounded, color: Color(0xFF4A8078)),
              ],
            ),

            SizedBox(height: 16),

            if (estatistica.isEmpty)
              Text("Sem dados disponíveis", textAlign: TextAlign.center,)
            else ... [
              _estatisticaItem("Valor mínimo", estatistica[0].toString()),
              _estatisticaItem("Valor máximo", estatistica[1].toString()),
              _estatisticaItem("Média", estatistica[2].toStringAsFixed(1)),
            ]

          ],
        ),
      ),
    );
  }

  Widget _construirEstatisticaDaDor (String titulo, List<dynamic> estatistica, List<int> contadoresDor){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Text(titulo,
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A8078)
                  ),
                ),
                Spacer(),
                //SizedBox(width: 160),
                Icon(Icons.bar_chart_rounded, color: Color(0xFF4A8078)),
              ],
            ),

            SizedBox(height: 16),

            if (estatistica.isEmpty)
              Text("Sem dados disponíveis", textAlign: TextAlign.center,)
            else ... [
              _estatisticaItem("Valor mínimo", estatistica[0].toString()),
              _estatisticaItem("Valor máximo", estatistica[1].toString()),
              _estatisticaItem("Média", estatistica[2].toStringAsFixed(1)),

              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
                height: 24,
              ),

              _construirEstatisticaLocalDaDor(contadoresDor)

            ]

          ],
        ),
      ),
    );
  }
}


