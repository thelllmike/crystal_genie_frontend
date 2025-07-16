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
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  Box({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
    );
  }
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

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      headline: json['Headline'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      // note: JSON key has a trailing space
      starSign: json['Star sign '] as String? ?? '',
      chakras: json['Chakras'] as String? ?? '',
      unnamed5: json['Unnamed: 5'] as String?,
    );
  }
}