import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

Map<String, dynamic> decodeApiResponse(http.Response response) {
  final dynamic body;
  try {
    body = jsonDecode(response.body);
  } on FormatException {
    throw ApiException(
      'Server memberikan respons yang tidak valid.',
      statusCode: response.statusCode,
    );
  }
  if (body is! Map<String, dynamic>) {
    throw ApiException(
      'Format respons server tidak valid.',
      statusCode: response.statusCode,
    );
  }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException(
      body['message']?.toString() ?? 'Permintaan gagal (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }
  return body;
}
