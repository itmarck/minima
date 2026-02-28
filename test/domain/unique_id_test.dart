import 'package:flutter_test/flutter_test.dart';
import 'package:minima/domain/unique_id.dart';

void main() {
  test('create generates unique ids', () {
    final a = UniqueId.create();
    final b = UniqueId.create();
    expect(a, isNot(equals(b)));
  });

  test('equality is based on value', () {
    const id1 = UniqueId('abc-123');
    const id2 = UniqueId('abc-123');
    const id3 = UniqueId('def-456');

    expect(id1, equals(id2));
    expect(id1, isNot(equals(id3)));
  });

  test('toString returns the value', () {
    const id = UniqueId('abc-123');
    expect(id.toString(), 'abc-123');
  });
}
