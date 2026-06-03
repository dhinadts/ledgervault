// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

class AuditDocumentUpload {
  final String fileName;
  final String contentType;
  final String base64Data;

  const AuditDocumentUpload({
    required this.fileName,
    required this.contentType,
    required this.base64Data,
  });
}

Future<AuditDocumentUpload?> pickAuditDocument() async {
  final input = html.FileUploadInputElement()
    ..accept = '.pdf,.png,.jpg,.jpeg,.doc,.docx,.xls,.xlsx,.csv'
    ..click();

  await input.onChange.first;
  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) {
    return null;
  }

  final reader = html.FileReader();
  final completer = Completer<String>();
  reader.onLoad.first.then((_) {
    final result = reader.result?.toString() ?? '';
    completer.complete(result.split(',').last);
  });
  reader.onError.first.then((_) {
    completer.completeError('Unable to read selected file.');
  });
  reader.readAsDataUrl(file);

  return AuditDocumentUpload(
    fileName: file.name,
    contentType: file.type.isEmpty ? 'application/octet-stream' : file.type,
    base64Data: await completer.future,
  );
}
