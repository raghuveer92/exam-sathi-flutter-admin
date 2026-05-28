import 'template_downloader_stub.dart'
    if (dart.library.html) 'template_downloader_web.dart' as impl;

Future<bool> downloadTextFile({
  required String fileName,
  required String content,
}) {
  return impl.downloadTextFile(fileName: fileName, content: content);
}