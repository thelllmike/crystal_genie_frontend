// lib/models/detection.dart

class Detection {
  final int classId;
  final String className;
  final double confidence;
  final Box box;
  final Description description;

  Detection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.box,
    required this.description,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      classId: json['class_id'] as int,
      className: json['class_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      box: Box.fromJson(json['box'] as Map<String, dynamic>),
      description: Description.fromJson(json['description'] as Map<String, dynamic>),
    );
  }
}

class Box {
  final double x1, y1, x2, y2;
  Box({required this.x1, required this.y1, required this.x2, required this.y2});
  factory Box.fromJson(Map<String, dynamic> j) => Box(
    x1: (j['x1'] as num).toDouble(),
    y1: (j['y1'] as num).toDouble(),
    x2: (j['x2'] as num).toDouble(),
    y2: (j['y2'] as num).toDouble(),
  );
}

class Description {
  final String headline;
  final String description;
  final String starSign;
  final String chakras;
  final String? unnamed5;

  Description({
    required this.headline,
    required this.description,
    required this.starSign,
    required this.chakras,
    this.unnamed5,
  });

  factory Description.fromJson(Map<String, dynamic> j) => Description(
    headline: j['Headline'] as String? ?? '',
    description: j['Description'] as String? ?? '',
    starSign: j['Star sign '] as String? ?? '',
    chakras: j['Chakras'] as String? ?? '',
    unnamed5: j['Unnamed: 5'] as String?,
  );
}