class ApiErrorDetail {
  final String? field;
  final String? issue;

  ApiErrorDetail({this.field, this.issue});

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) => ApiErrorDetail(
        field: json['field'] as String?,
        issue: json['issue'] as String?,
      );
}

class ApiError {
  final String code;
  final String message;
  final List<ApiErrorDetail> details;

  ApiError({
    required this.code,
    required this.message,
    this.details = const [],
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code'] as String? ?? 'INTERNAL_ERROR',
        message: json['message'] as String? ?? 'Unknown error',
        details: (json['details'] as List<dynamic>? ?? [])
            .map((e) => ApiErrorDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final Map<String, dynamic>? meta;

  ApiEnvelope({
    required this.success,
    this.data,
    this.error,
    this.meta,
  });

  static ApiEnvelope<Map<String, dynamic>> parseMap(
    Map<String, dynamic> json,
  ) {
    final success = json['success'] == true;
    if (!success) {
      return ApiEnvelope(
        success: false,
        error: ApiError.fromJson(
          (json['error'] as Map<String, dynamic>?) ?? {},
        ),
      );
    }
    return ApiEnvelope(
      success: true,
      data: json['data'] as Map<String, dynamic>?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}
