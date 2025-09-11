// ignore_for_file: file_names

class TextGenModel {
  final String role;
  final List<TextPartModel> parts;

  TextGenModel({required this.role, required this.parts});

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'parts': parts.map((part) => part.toMap()).toList(),
    };
  }

  factory TextGenModel.fromMap(Map<String, dynamic> map) {
    final content = map['content'];
    return TextGenModel(
      role: content['role'],
      parts: List<TextPartModel>.from(
        content['parts'].map(
          (part) => TextPartModel(text: part['text']),
        ),
      ),
    );
  }
}

class TextPartModel {
  final String text;

  TextPartModel({required this.text});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
    };
  }

  factory TextPartModel.fromMap(Map<String, dynamic> map) {
    return TextPartModel(
      text: map['text'],
    );
  }
}
