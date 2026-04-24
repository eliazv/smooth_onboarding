import 'dart:io';

void main() {
  final pubCache = Platform.environment['PUB_CACHE'] ?? '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';
  final dir = Directory('$pubCache\\hosted\\pub.dev');
  if (dir.existsSync()) {
    for (var d in dir.listSync()) {
      if (d.path.contains('chiclet')) {
        final srcDir = Directory('${d.path}\\lib\\src');
        if (srcDir.existsSync()) {
          print(srcDir.listSync().map((e) => e.path).join('\n'));
          return;
        }
      }
    }
  }
}
