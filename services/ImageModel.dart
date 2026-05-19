class ImageModel {
  final String base64Data;
  final String timestamp;
  String? localPath;

  ImageModel({required this.base64Data, required this.timestamp, this.localPath});

  // Métdo para converter um Map<String,String> para um objeto ImageModel
  // O métdo recebe um Map<String, String> chamado map contendo os dados da imagem.
  factory ImageModel.fromMap(Map<String, String> map) {
    return ImageModel(base64Data: map["base64_data"] ?? "",
      timestamp: map["timestamp_taken"] ?? "Sem Data");
  }

  // Métdo para converter um objeto ImageModel para um Map<String, String>
  Map<String, String> toMap() {
    return {
      "base64_data": base64Data,
      "timestamp_taken": timestamp
    };
  }
}