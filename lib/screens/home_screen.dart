import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';
import 'search_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<List<Country>> _countriesFuture;

  static const int _pageSize = 20;
  int _currentPage = 1;
  List<Country> _displayedCountries = [];
  List<Country> _allCountries = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _loadCountries();
  }

  Future<List<Country>> _loadCountries() async {
    final countries = await _apiService.fetchAllCountries();
    if (mounted) {
      setState(() {
        _allCountries = countries;
        _displayedCountries = countries.take(_pageSize).toList();
        _currentPage = 1;
      });
    }
    return countries;
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final nextItems = _allCountries.take(nextPage * _pageSize).toList();
    if (mounted) {
      setState(() {
        _displayedCountries = nextItems;
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _countriesFuture = _loadCountries();
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
        title: const Text('Country Explorer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_apiService.hasCachedData)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                  'Cached',
                  style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => CountryExplorerApp.of(context)?.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Country>>(
        future: _countriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
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
                      style: const TextStyle(fontSize: 16),
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No countries found.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _displayedCountries.length,
                  itemBuilder: (context, index) {
                    final country = _displayedCountries[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          country.flagImageUrl,
                          width: 48,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flag, size: 32),
                        ),
                      ),
                      title: Text(country.commonName),
                      subtitle: Text(country.region),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailScreen(alpha3Code: country.alpha3Code),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_displayedCountries.length < _allCountries.length)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isLoadingMore
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _loadMore,
                          icon: const Icon(Icons.expand_more),
                          label: Text(
                            'Load More (${_allCountries.length - _displayedCountries.length} remaining)',
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
