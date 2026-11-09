// services/upload_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class UploadService {
  Future<String?> uploadFile(
    File file, {
    String? attachedToDoctype,
    String? attachedToName,
    String? fileName,
  }) async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session expired. Please login again.");
    }

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$site/api/method/upload_file"),
    );

    request.headers.addAll({"Cookie": cookie, "Accept": "application/json"});

    request.files.add(
      await http.MultipartFile.fromPath("file", file.path, filename: fileName),
    );

    // Keep uploaded files private, same as the previous implementation.
    request.fields["is_private"] = "1";

    // Attach the uploaded file to the ERPNext document.
    if (attachedToDoctype != null && attachedToDoctype.trim().isNotEmpty) {
      request.fields["doctype"] = attachedToDoctype;
    }

    if (attachedToName != null && attachedToName.trim().isNotEmpty) {
      request.fields["docname"] = attachedToName;
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print("==================================");
    print("UPLOAD FILE");
    print("Status : ${streamedResponse.statusCode}");
    print("Body   : $responseBody");
    print("==================================");

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);

      if (data["message"] != null && data["message"]["file_url"] != null) {
        return data["message"]["file_url"];
      }
    }

    throw Exception("File upload failed.\n$responseBody");
  }
}
