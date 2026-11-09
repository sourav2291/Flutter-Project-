// services/download_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

import 'session_service.dart';

class DownloadService {
  static Future<void> downloadFile({
    required String url,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      final session = SessionService();
      final cookie = await session.getCookie();

      final tempDir = await getTemporaryDirectory();

      final tempFile = "${tempDir.path}/$fileName";

      final dio = Dio();

      await dio.download(
        url,
        tempFile,
        options: Options(
          headers: {"Cookie": ?cookie, "Accept": "application/pdf"},
        ),
      );

      final params = SaveFileDialogParams(
        sourceFilePath: tempFile,
        fileName: fileName,
      );

      final savedPath = await FlutterFileDialog.saveFile(params: params);

      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Quotation downloaded successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Download cancelled.")));
      }
    } catch (e) {
      debugPrint("DOWNLOAD ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
