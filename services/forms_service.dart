import 'package:app_pe_diabetico/api/api_forms.dart';

class FormsService {
  final ApiForms _apiService = ApiForms();
  late List<Map<String,dynamic>>? _listaRelatoriosGlicose;
  late List<Map<String,dynamic>>? _listaRelatoriosBPM;
  late List<Map<String,dynamic>>? _listaRelatoriosWellBeing;

  Future<List<dynamic>> getLastReportsGlicose() async {
    _listaRelatoriosGlicose = await _apiService.getFormsInfo("glicose");

    if (_listaRelatoriosGlicose == null || _listaRelatoriosGlicose!.length <2){
      return ["-", "-"];
    }

    Map<String,dynamic> ultimoRelatorioGlicose = _listaRelatoriosGlicose!.last;
    String ultimaMedicaoGlicose = ultimoRelatorioGlicose["glicose_value"];
    Map<String,dynamic> penultimoRelatorioGlicose = _listaRelatoriosGlicose![_listaRelatoriosGlicose!.length-2];
    String penultimaMedicaoGlicose = penultimoRelatorioGlicose["glicose_value"];

    return [ultimaMedicaoGlicose, penultimaMedicaoGlicose];
  }

  Future<List<dynamic>> getLastReportsBPM() async {
    _listaRelatoriosBPM = await _apiService.getFormsInfo("blood_pressure");

    if (_listaRelatoriosBPM == null || _listaRelatoriosBPM!.length <2){
      return ["-", "-", "-", "-"];
    }

    Map<String,dynamic> ultimoRelatorioBPM = _listaRelatoriosBPM!.last;
    String ultimaMedicaoPSistolica = ultimoRelatorioBPM["systolic_pressure"];
    String ultimaMedicaoPDiastolica = ultimoRelatorioBPM["diastolic_pressure"];

    Map<String,dynamic> penultimoRelatorioBPM = _listaRelatoriosBPM![_listaRelatoriosBPM!.length-2];
    String penultimaMedicaoPSistolica = penultimoRelatorioBPM["systolic_pressure"];
    String penultimaMedicaoPDiastolica = penultimoRelatorioBPM["diastolic_pressure"];

    return [ultimaMedicaoPSistolica, ultimaMedicaoPDiastolica, penultimaMedicaoPSistolica, penultimaMedicaoPDiastolica];
  }

  Future<List<dynamic>> getLastReportsWellBeing() async {
    _listaRelatoriosWellBeing = await _apiService.getFormsInfo("well_being");

    if (_listaRelatoriosWellBeing == null || _listaRelatoriosWellBeing!.length <2){
      return ["-", "-"];
    }

    Map<String,dynamic> ultimoRelatorioWellBeing = _listaRelatoriosWellBeing!.last;
    String ultimaMedicaoWellBeing = ultimoRelatorioWellBeing["pain_level"];

    Map<String,dynamic> penultimoRelatorioWellBeing = _listaRelatoriosWellBeing![_listaRelatoriosWellBeing!.length-2];
    String penultimaMedicaoWellBeing = penultimoRelatorioWellBeing["pain_level"];

    return [ultimaMedicaoWellBeing, penultimaMedicaoWellBeing];
  }
}