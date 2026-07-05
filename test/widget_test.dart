import 'package:flutter_test/flutter_test.dart' hide Description;

import 'package:crystal_genie/models/detection.dart';

void main() {
  test('Detection parses the backend /detect JSON', () {
    final det = Detection.fromJson({
      'class_id': 0,
      'class_name': 'Amethyst',
      'confidence': 0.93,
      'box': {'x1': 1.0, 'y1': 2.0, 'x2': 3.0, 'y2': 4.0},
      'description': {
        'headline': 'The stone of calm',
        'description': 'A violet quartz...',
        'star_sign': 'Pisces',
        'chakras': 'Crown',
      },
    });

    expect(det.className, 'Amethyst');
    expect(det.confidence, closeTo(0.93, 1e-9));
    expect(det.box.x2, 3.0);
    expect(det.description.headline, 'The stone of calm');
    expect(det.description.starSign, 'Pisces');
  });

  test('Description tolerates missing fields', () {
    final desc = Description.fromJson(const {});
    expect(desc.headline, '');
    expect(desc.chakras, '');
  });
}
