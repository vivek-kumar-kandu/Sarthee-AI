import 'package:flutter/foundation.dart';

/**
 * ApiResponse — Production Generic API Envelope Wrapper for Flutter
 *
 * Deserializes backend status, data payload, error details, and metadata
 * featuring DataProvenance, Request ID, and Trace ID.
 */
@immutable
class ApiResponse<T> {
  const ApiResponse({
    required this.status,
    required this.meta,
    this.data,
    this.message,
    this.error,
  });

  final String status;
  final T? data;
  final String? message;
  final ApiErrorDetails? error;
  final Meta meta;

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final statusStr = json['status'] as String? ?? 'success';
    final metaObj = json['meta'] is Map<String, dynamic>
        ? Meta.fromJson(json['meta'] as Map<String, dynamic>)
        : Meta.empty();

    T? parsedData;
    if (json.containsKey('data') && json['data'] != null) {
      parsedData = fromJsonT(json['data']);
    }

    ApiErrorDetails? parsedError;
    if (json['error'] is Map<String, dynamic>) {
      parsedError = ApiErrorDetails.fromJson(json['error'] as Map<String, dynamic>);
    }

    return ApiResponse<T>(
      status: statusStr,
      data: parsedData,
      message: json['message'] as String?,
      error: parsedError,
      meta: metaObj,
    );
  }
}

@immutable
class Meta {
  const Meta({
    required this.timestamp,
    this.provenance,
    this.requestId,
    this.traceId,
  });

  final DateTime timestamp;
  final Provenance? provenance;
  final String? requestId;
  final String? traceId;

  factory Meta.empty() => Meta(timestamp: DateTime.now());

  factory Meta.fromJson(Map<String, dynamic> json) {
    final rawTs = json['timestamp'] as String?;
    final parsedTs = rawTs != null ? DateTime.tryParse(rawTs) ?? DateTime.now() : DateTime.now();

    return Meta(
      timestamp: parsedTs,
      requestId: json['requestId'] as String?,
      traceId: json['traceId'] as String?,
      provenance: json['provenance'] is Map<String, dynamic>
          ? Provenance.fromJson(json['provenance'] as Map<String, dynamic>)
          : null,
    );
  }
}

@immutable
class Provenance {
  const Provenance({
    required this.provider,
    required this.live,
    required this.fallback,
    required this.confidence,
    required this.lastUpdated,
    this.providers,
    this.engine,
    this.providerVersion,
    this.latencyMs = 0,
    this.cache = false,
    this.verified = false,
    this.reason,
  });

  final String provider;
  final List<String>? providers;
  final String? engine;
  final String? providerVersion;
  final bool live;
  final bool fallback;
  final double confidence;
  final DateTime lastUpdated;
  final int latencyMs;
  final bool cache;
  final bool verified;
  final String? reason;

  factory Provenance.fromJson(Map<String, dynamic> json) {
    final rawUpdated = json['lastUpdated'] as String?;
    final parsedUpdated = rawUpdated != null ? DateTime.tryParse(rawUpdated) ?? DateTime.now() : DateTime.now();

    List<String>? providersList;
    if (json['providers'] is List) {
      providersList = (json['providers'] as List).map((e) => e.toString()).toList();
    }

    return Provenance(
      provider: json['provider'] as String? ?? 'Sarthee Engine',
      providers: providersList,
      engine: json['engine'] as String?,
      providerVersion: json['providerVersion'] as String?,
      live: json['live'] as bool? ?? true,
      fallback: json['fallback'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      lastUpdated: parsedUpdated,
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
      cache: json['cache'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }
}

@immutable
class ApiErrorDetails {
  const ApiErrorDetails({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final dynamic details;

  factory ApiErrorDetails.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetails(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An error occurred',
      details: json['details'],
    );
  }
}
