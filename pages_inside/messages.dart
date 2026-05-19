import 'package:flutter/material.dart';
import 'package:app_pe_diabetico/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pe_diabetico/services/Message.dart';
import 'package:app_pe_diabetico/api/api_messages.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'package:app_pe_diabetico/api/api_practitioner.dart';

class MessagesPage extends StatefulWidget {

  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  final ApiMessages apiMessages = ApiMessages();
  final ApiPractitioner apiService = ApiPractitioner();
  Map<String, List<Message>> groupedMessages = {};
  bool isLoading = true;
  bool hasConnection = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _verifyUserLink();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _verifyUserLink() async {
    Map<String,dynamic>? linkInformation = await apiService.getAssociation(); // Verifica se o utilizador está ligado

    if (linkInformation != null && linkInformation.containsKey("message")) {
      // Nao tem associacao
      if (linkInformation['message'] == "user has no associated practitioner") {

        print("nao tem conexão");

        setState(() {
          isLoading = false;
        });
      } else {

        setState(() {
          hasConnection = true;
        });

        loadMessages(linkInformation["result"]["practitioner_id"]);
      }

    } else {
      print("O mapa e vazio ou nao tem a chave correspondente");
    }
  }

  Future<void> loadMessages(String code) async {
    final messages = await apiMessages.getMessages(practitioner_id: code);

    if (messages != null) {
      final Map<String, List<Message>> groups = {};

      for (var message in messages) {
        final date = DateFormat("dd/MM/yyyy").format(message.sentAt);
        groups.putIfAbsent(date, () => []).add(message);
      }

      setState(() {
        groupedMessages = groups;
        isLoading = false;
      });

      // Aguarda um frame para garantir que a lista foi construida
      WidgetsBinding.instance.addPostFrameCallback((_){
        if (_scrollController.hasClients) {
          // vai ate ao fim da lista (mensagens mais recentes)
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading){
      return Scaffold(
        backgroundColor: Color(0xFFE3E6DF),
        body: Center(child: CircularProgressIndicator())
      );
    }

    if (groupedMessages.isEmpty && hasConnection) {
      return Scaffold(
          backgroundColor: Color(0xFFE3E6DF),
          body: Center(child: Text("Sem mensagens.",
            style: TextStyle(
              color: Color(0xFF4A5D4E),
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ))
      );
    }

    if (hasConnection == false ) {
      return Scaffold(
          backgroundColor: Color(0xFFE3E6DF),
          body: Center(child: Text("Ainda não tem médico associado."))
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFE3E6DF),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFE3E6DF),
        title: Text("Mensagens",
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A5D4E)
          )
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Color(0xFF4A5D4E),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.only(bottom: 60),

              children: groupedMessages.entries.map((entry) {
                final date = entry.key;
                final messages = entry.value;

                // para cada dia é retornada uma coluna com a data por cima
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // primeiro mete a data por cima
                    Padding(
                      padding: EdgeInsets.symmetric( horizontal: 16, vertical: 12),
                      child: Bubble(
                        alignment: Alignment.center,
                        color: Color.fromRGBO(212, 234, 244, 1.0),
                        child: Text(
                          date,
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey
                          ),
                        ),
                      ),
                    ),

                    ...messages.map((message) {
                      return Bubble(
                        padding: BubbleEdges.only(right: 40, top: 10),
                        margin: BubbleEdges.only(top: 10, left: 8, right: 40),
                        alignment: Alignment.topLeft,
                        nip: BubbleNip.leftTop,
                        color: AppColors.MessagesBrown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.subject,
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            ),

                            Text(
                              message.body,
                              style: GoogleFonts.quicksand(
                                  fontSize: 13
                              ),
                            ),

                            Text(
                              DateFormat("HH:mm").format(message.sentAt),
                              textAlign: TextAlign.end,
                              style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  color: Colors.white
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList()
                  ],
                );
              }).toList()
            ),
          )
        ],
      ),
    );

  }
}
