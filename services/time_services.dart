import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';

mixin TimeService {

  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2026),
      locale: const Locale('pt', 'PT'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.focusedBorderGreen),
          ),
          child: child!,
        );
      },
    );
    return picked; // Retorna a data escolhida, sem modificar nada na UI
  }

  Future<TimeOfDay?> selectTime(BuildContext context) async {
    final now = DateTime.now();


    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input,
        hourLabelText: "Hora",
        minuteLabelText: "Minutos",
        cancelText: "Cancelar",
        helpText: "Insira as horas",
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: AppColors.subtitlesText
                  )),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: true),
                child: child!,
              ));
        }
    );

    if (timeOfDay == null) return null;

    final selectedDateTime = DateTime(now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute);

    if (selectedDateTime.isAfter(now)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Hora inválida"),
          content: const Text("Não pode selecionar uma hora futura. Por favor, escolha uma hora válida."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Color(0xFF008597))),
            )
          ],
        ),
      );
      return null;
    }
    return timeOfDay;
  }
}
