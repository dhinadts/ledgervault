import 'dart:convert';

import 'package:file_picker/file_picker.dart';

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
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: [
      'pdf',
      'png',
      'jpg',
      'jpeg',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'csv',
    ],
    withData: true,
  );
  final file = result?.files.isNotEmpty == true ? result!.files.first : null;
  final bytes = file?.bytes;
  if (file == null || bytes == null) {
    return null;
  }

  return AuditDocumentUpload(
    fileName: file.name,
    contentType: _contentType(file.extension),
    base64Data: base64Encode(bytes),
  );
}

String _contentType(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'csv':
      return 'text/csv';
    default:
      return 'application/octet-stream';
  }
}
