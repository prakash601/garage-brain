import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _makesAssetPath = 'assets/makes.csv';

Future<List<String>> loadMakes() async {
  final csv = await rootBundle.loadString(_makesAssetPath);
  return csv
      .split('\n')
      .skip(1)
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

final makesProvider = FutureProvider<List<String>>((ref) => loadMakes());
