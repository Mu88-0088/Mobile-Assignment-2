import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';

class DetailScreen extends StatefulWidget {
  final String alpha3Code;

  const DetailScreen({super.key, required this.alpha3Code});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<Country> _countryFuture;

  @override
  void initState() {
    super.initState();
    _countryFuture = _apiService.fetchByCode(widget.alpha3Code);
  }

  void _retry() {
    setState(() {
      _countryFuture = _apiService.fetchByCode(widget.alpha3Code);
    });
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) return 'No internet connection';
    if (error is TimeoutException) return 'Request timed out. Please try again.';
    if (error is ApiException) return 'Server error ${error.statusCode}: ${error.message}';
    if (error is FormatException) return 'Unexpected data format received';
    return 'An unexpected error occurred: ${error.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Country>(
        future: _countryFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _getErrorMessage(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: No data
          if (!snapshot.hasData) {
            return const Center(child: Text('Country data not available.'));
          }

          // State 4: Data
          final country = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: country.flagImageUrl,
                      width: 200,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox(
                        width: 200,
                        height: 120,
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.flag, size: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Country name
                Center(
                  child: Text(
                    country.commonName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Center(
                  child: Text(
                    country.officialName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),

                _infoRow('Region', country.region),
                _infoRow('Subregion', country.subregion),
                _infoRow('Capital', country.capital),
                _infoRow('Population', _formatNumber(country.population)),
                _infoRow('Area', '${_formatNumber(country.area.toInt())} km²'),
                _infoRow(
                  'Languages',
                  country.languages.isNotEmpty
                      ? country.languages.join(', ')
                      : 'N/A',
                ),
                _infoRow(
                  'Currencies',
                  country.currencies.isNotEmpty
                      ? country.currencies.join(', ')
                      : 'N/A',
                ),
                _infoRow(
                  'Timezones',
                  country.timezones.isNotEmpty
                      ? country.timezones.join(', ')
                      : 'N/A',
                ),
                _infoRow('ISO Code', country.alpha3Code),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
