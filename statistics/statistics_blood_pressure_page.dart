import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_pe_diabetico/api/api_forms.dart';

class StatisticsBloodPressurePage extends StatefulWidget {
  const StatisticsBloodPressurePage({super.key});

  @override
  State<StatisticsBloodPressurePage> createState() => _StatisticsBloodPressurePageState();
}

class _StatisticsBloodPressurePageState extends State<StatisticsBloodPressurePage> {

  String _selectedRange = "week";
  final ApiForms _apiService = ApiForms();
  late List<Map<String,dynamic>>? _listaRelatoriosPressao;

  List<(DateTime, int)> _dadosBpm = [];
  List<(DateTime, int)> _dadosPSistolica = [];
  List<(DateTime, int)> _dadosPDiastolica = [];

  bool _loading = true;

  Future<void> _carregarDados(String range) async{
    setState(() => _loading = true);

    final dadosBpm = await _dadosGrafico(range,"bpm");
    final dadosPSistolica = await _dadosGrafico(range, "systolic_pressure");
    final dadosPDiastolica = await _dadosGrafico(range, "diastolic_pressure");

    setState(() {
      _dadosBpm = dadosBpm;
      _dadosPSistolica = dadosPSistolica;
      _dadosPDiastolica = dadosPDiastolica;
      _loading = false;
    });
  }

  Future<List<(DateTime,int)>> _dadosGrafico(String range, String campo) async{
    final currentDate = DateTime.now();
    final inicioDaSemana = currentDate.subtract(Duration(days: 7));
    final inicioDoMes = currentDate.subtract(Duration(days: 30));

    _listaRelatoriosPressao = await _apiService.getFormsInfo("blood_pressure");
    List<(DateTime,int)> listaDeValores = [];

    for (var elemento in _listaRelatoriosPressao ?? []){
      try {

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

    listaDeValores.sort((a,b) => a.$1.compareTo(b.$1));
    return listaDeValores;
  }

  List<dynamic> _dadosEstatistica(List<(DateTime,int)> listaDeValores){
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
      return [0,0,0.0];
    }

    return listaEstatistica;
  }

  Future<List<int>> _classificacaoFrequencia(String range) async {

    final currentDate = DateTime.now();
    final inicioDaSemana = currentDate.subtract(Duration(days: 7));
    final inicioDoMes = currentDate.subtract(Duration(days: 30));

    final listaRelatorios = await _apiService.getFormsInfo("blood_pressure");

    if (listaRelatorios?.isEmpty ?? true) return [0,0,0];

    int valoresNormais = 0;
    int valoresBaixos = 0;
    int valoresAltos = 0;

    for (var elemento in listaRelatorios!) {
      try {
        final measurementTime = DateTime.parse(elemento["measurement_time"]);

        final isDentroDoIntervalo = range == "week"
            ? measurementTime.isAfter(inicioDaSemana)
            : measurementTime.isAfter(inicioDoMes);

        if (!isDentroDoIntervalo) continue;

        if (int.parse(elemento["bpm"]) < 60) {
          valoresBaixos ++;
        } else if (int.parse(elemento["bpm"]) > 100) {
          valoresAltos ++;
        } else {
          valoresNormais ++;
        }
      } catch (e) {
        print("Erro ao fazer contador: $e");
      }
    }

    return [valoresBaixos, valoresNormais, valoresAltos];
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
    _listaRelatoriosPressao?.clear(); // ← OPICIONAL: se a lista for muito grande
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Estatística da Pressão Sanguínea")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Estatística da Pressão Sanguínea",
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
                fontSize: 16, fontWeight: FontWeight.w600
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

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

            _construirGrafico("Valores da Frequência Cardíaca", _dadosBpm, Color(0xFFFF6B6B)),
            //_construirEstatistica("Estatística da FC", _dadosEstatistica(_dadosBpm), cont),

            FutureBuilder<List<int>>(
              future: _classificacaoFrequencia(_selectedRange),
              builder: (context, snapshot) {
                final contadoresDor = snapshot.data ?? [0, 0, 0, 0];
                return _construirEstatisticaBpm(
                  "Estatísticas da FC",
                  _dadosEstatistica(_dadosBpm),
                  contadoresDor,
                );
              },
            ),

            SizedBox(height: 24),

            _construirGraficoDuplo("Pressão Arterial (Sistólica vs Diastólica)", _dadosPSistolica, _dadosPDiastolica)
          ],
        ),
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
                        maxY: 200,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                interval: 25,
                                reservedSize: 40,
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
                              isCurved: true,
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

  Widget _construirEstatisticaBpm (String titulo, List<dynamic> estatistica, List<int> contadores){
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
            ],

            Divider(
              color: Colors.grey.withOpacity(0.5),
              thickness: 1,
              height: 24,
            ),

            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Classificação da FC",
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
                    _estatisticaItem("Valores Muito Baixo", contadores[0].toString()),
                    _estatisticaItem("Valores Normais", contadores[1].toString()),
                    _estatisticaItem("Valores Muito Elevados", contadores[2].toString())
                  ],

                  SizedBox(height: 5),

                  Text("Nota: São considerados valores normais, valores superiores a 60bpm e inferiores a 100bpm.",
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: Color(0xFF4A8078)
                    ),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _construirGraficoDuplo(String titulo, List<(DateTime, int)> lista1, List<(DateTime, int)> lista2) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
              style: GoogleFonts.roboto(
                fontSize: 16, fontWeight: FontWeight.bold,
                color: Color(0xFF4A8078)
              ),
            ),

            SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: lista1.isEmpty || lista2.isEmpty ?
              Center(
                child: Text("Nenhum dado disponível para exibir no gráfico",
                  style: GoogleFonts.roboto(),
                ),
              ):
              LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 200,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 40,
                          reservedSize: 35,
                          getTitlesWidget: (value,meta) => Text(value.toInt().toString())
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= lista1.length) return Container();
                            final date = lista1[index].$1;
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

                  borderData: FlBorderData(show: true),

                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateData(lista1),
                      isCurved: true,
                      color: Color(0xFFFF6B6B),
                      barWidth: 3,
                      dotData: FlDotData(show: true)
                    ),

                    LineChartBarData(
                        spots: _generateData(lista2),
                        isCurved: true,
                        color: Color(0xFF6B8CFF),
                        barWidth: 3,
                        dotData: FlDotData(show: true)
                    ),
                  ]
                )
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendaCor("Sistólica", Color(0xFFFF6B6B)),
                SizedBox(width: 20),
                _legendaCor("Diastólica", Color(0xFF6B8CFF))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _legendaCor(String label, Color cor) {
    return Row(
      children: [
        Container( width: 12, height: 12, color: cor),
        SizedBox(width: 6),
        Text(label)
      ],
    );
  }
}
