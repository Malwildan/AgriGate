import 'package:agri_core/agri_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns failure when Railway base URL is empty', () async {
    final repository = RailwayCropRepository(baseUrl: '');
    final result = await repository.getRecommendation(
      ph: 6.5,
      moisture: 50,
      latitude: -7.5,
      longitude: 110.2,
    );

    expect(result.isLeft, isTrue);
    expect(result.left.message, contains('RAILWAY_API_URL'));
  });
}
