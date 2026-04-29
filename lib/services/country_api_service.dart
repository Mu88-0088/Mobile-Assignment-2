import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Cache layer (bonus)
  List<Country>? _cachedCountries;
  DateTime? _cacheTime;
  final Duration _cacheTTL = const Duration(minutes: 5);

  bool get _isCacheValid =>
      _cachedCountries != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheTTL;

  bool get hasCachedData => _isCacheValid;

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Server error: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }

  Future<List<Country>> fetchAllCountries() async {
    // Return cache if valid (bonus)
    if (_isCacheValid) return _cachedCountries!;

    try {
      final uri = Uri.https(
        _baseUrl,
        '/v3.1/all',
        {'fields': 'name,flags,region,subregion,population,capital,cca3'},
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      final countries = jsonList
          .map((json) => Country.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort alphabetically
      countries.sort((a, b) => a.commonName.compareTo(b.commonName));

      // Store cache (bonus)
      _cachedCountries = countries;
      _cacheTime = DateTime.now();

      return countries;
    } on SocketException {
      throw const SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } on FormatException {
      throw const FormatException('Unexpected data format received');
    }
  }

  Future<List<Country>> searchByName(String name) async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/name/$name');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 404) return [];

      _checkResponse(response);

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Country.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } on FormatException {
      throw const FormatException('Unexpected data format received');
    }
  }

  Future<Country> fetchByCode(String code) async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/alpha/$code');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return Country.fromJson(jsonList.first as Map<String, dynamic>);
    } on SocketException {
      throw const SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } on FormatException {
      throw const FormatException('Unexpected data format received');
    }
  }
}
