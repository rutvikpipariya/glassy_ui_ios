import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

void main() {
  group('NativeComponentConfig.toMap', () {
    test('omits unset fields and always includes enabled and style', () {
      final map = const NativeComponentConfig().toMap();
      expect(map.keys, unorderedEquals(['enabled', 'style']));
      expect(map['enabled'], isTrue);
    });

    test('encodes text, image, items, range and extra', () {
      final map = const NativeComponentConfig(
        title: 'Title',
        placeholder: 'Search',
        image: NativeImage.symbol('star.fill'),
        items: [NativeItem.symbol('Home', 'house', badge: '3')],
        value: 0.5,
        min: 0,
        max: 1,
        step: 0.1,
        extra: {
          'detents': ['medium', 'large']
        },
      ).toMap();

      expect(map['title'], 'Title');
      expect(map['placeholder'], 'Search');
      expect(map['image'], {'type': 'symbol', 'value': 'star.fill'});
      expect(map['items'], [
        {
          'title': 'Home',
          'image': {'type': 'symbol', 'value': 'house'},
          'badge': '3'
        },
      ]);
      expect([map['value'], map['min'], map['max'], map['step']],
          [0.5, 0, 1, 0.1]);
      expect(map['extra'], {
        'detents': ['medium', 'large']
      });
    });

    test('encodes DateTime as UTC ISO-8601 and Color as ARGB', () {
      final date = DateTime.utc(2026, 1, 2, 3, 4);
      expect(NativeComponentConfig(value: date).toMap()['value'],
          '2026-01-02T03:04:00.000Z');
      expect(
          const NativeComponentConfig(value: Color(0xFF112233))
              .toMap()['value'],
          0xFF112233);
    });

    test('copyWith keeps unspecified values', () {
      const config = NativeComponentConfig(title: 'A', subtitle: 'B');
      final copy = config.copyWith(title: 'C');
      expect(copy.title, 'C');
      expect(copy.subtitle, 'B');
    });
  });

  group('NativeItem.toMap', () {
    test('encodes role, state and children', () {
      final map = const NativeItem(
        id: 'export',
        title: 'Export',
        role: NativeItemRole.destructive,
        selected: true,
        enabled: false,
        children: [NativeItem(title: 'PDF')],
      ).toMap();
      expect(map, {
        'id': 'export',
        'title': 'Export',
        'role': 'destructive',
        'selected': true,
        'enabled': false,
        'children': [
          {'title': 'PDF'},
        ],
      });
    });

    test('image takes precedence over symbol', () {
      final map = const NativeItem(
              title: 'A',
              symbol: 'house',
              image: NativeImage.asset('assets/a.png'))
          .toMap();
      expect(map['image'], {'type': 'asset', 'value': 'assets/a.png'});
    });
  });

  group('NativeStyle.toMap', () {
    test('encodes colors, enums and defaults', () {
      final map = const NativeStyle(
        tintColor: Color(0xFFFF0000),
        backgroundGradient: [Color(0xFF000000), Color(0xFFFFFFFF)],
        cornerRadius: 12,
        glass: NativeGlass.clear,
        fontWeight: NativeFontWeight.bold,
        fontDesign: NativeFontDesign.standard,
        colorScheme: NativeColorScheme.dark,
        controlSize: NativeControlSize.large,
      ).toMap();
      expect(map['tintColor'], 0xFFFF0000);
      expect(map['backgroundGradient'], [0xFF000000, 0xFFFFFFFF]);
      expect(map['cornerRadius'], 12);
      expect(map['glass'], 'clear');
      expect(map['fontWeight'], 'bold');
      expect(map['fontDesign'], 'default');
      expect(map['colorScheme'], 'dark');
      expect(map['controlSize'], 'large');
      expect(map['showBackdrop'], isTrue);
      expect(map['interactive'], isTrue);
    });
  });

  test('NativeImage.bytes encodes raw data', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    expect(NativeImage.bytes(bytes).toMap(), {'type': 'bytes', 'value': bytes});
  });

  group('NativeComponentType', () {
    test('has 90 unique ids', () {
      final ids = NativeComponentType.values.map((t) => t.id).toSet();
      expect(NativeComponentType.values, hasLength(90));
      expect(ids, hasLength(90));
    });

    test('byId finds types', () {
      expect(NativeComponentType.byId('glass-button'),
          NativeComponentType.glassButton);
      expect(NativeComponentType.byId('missing'), isNull);
    });
  });
}
