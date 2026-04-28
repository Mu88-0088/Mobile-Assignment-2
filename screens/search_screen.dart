import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CountryApiService _apiService = CountryApiService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  List<Country> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Debounce — 400ms delay (bonus)
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });

    setState(() => _isLoading = true);
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await _apiService.searchByName(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No internet connection';
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Request timed out. Please try again.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Server error ${e.statusCode}: ${e.message}';
        _isLoading = false;
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unexpected data format received';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Countries'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by country name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _performSearch(_controller.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return const Center(
        child: Text('Type a country name to search'),
      );
    }

    if (!_isLoading && _results.isEmpty) {
      return const Center(child: Text('No countries found.'));
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final country = _results[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: country.flagImageUrl,
              width: 48,
              height: 32,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(width: 48, height: 32),
              errorWidget: (_, __, ___) => const Icon(Icons.flag, size: 32),
            ),
          ),
          title: Text(country.commonName),
          subtitle: Text(country.region),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(alpha3Code: country.alpha3Code),
            ),
          ),
        );
      },
    );
  }
}
