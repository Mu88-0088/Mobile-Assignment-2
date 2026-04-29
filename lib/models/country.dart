import 'package:flutter/foundation.dart';

class Country {
  final String commonName;
  final String officialName;
  final String flagEmoji;
  final String region;
  final String subregion;
  final String capital;
  final int population;
  final double area;
  final List<String> currencies;
  final List<String> languages;
  final List<String> timezones;
  final String alpha3Code;
  final String flagImageUrl;

  const Country({
    required this.commonName,
    required this.officialName,
    required this.flagEmoji,
    required this.region,
    required this.subregion,
    required this.capital,
    required this.population,
    required this.area,
    required this.currencies,
    required this.languages,
    required this.timezones,
    required this.alpha3Code,
    required this.flagImageUrl,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Parse currencies — dynamic key map
    final currenciesMap = json['currencies'] as Map<String, dynamic>?;
    final currencies = currenciesMap?.entries
            .map((e) {
              final data = e.value as Map<String, dynamic>?;
              final name = data?['name'] as String? ?? '';
              final symbol = data?['symbol'] as String? ?? '';
              return '$name ($symbol)';
            })
            .toList() ??
        [];

    // Parse languages — dynamic key map
    final languagesMap = json['languages'] as Map<String, dynamic>?;
    final languages =
        languagesMap?.values.map((v) => v as String).toList() ?? [];

    // Parse capital
    final capitalList = json['capital'] as List<dynamic>?;
    final capital =
        capitalList != null && capitalList.isNotEmpty
            ? capitalList.first as String
            : 'N/A';

    // Parse timezones
    final timezoneList = json['timezones'] as List<dynamic>?;
    final timezones =
        timezoneList?.map((t) => t as String).toList() ?? [];

    return Country(
      commonName:
          (json['name'] as Map<String, dynamic>?)?['common'] as String? ??
              'Unknown',
      officialName:
          (json['name'] as Map<String, dynamic>?)?['official'] as String? ??
              'Unknown',
      flagEmoji:
          (json['flags'] as Map<String, dynamic>?)?['png'] as String? ?? '',
      flagImageUrl:
          (json['flags'] as Map<String, dynamic>?)?['png'] as String? ?? '',
      region: json['region'] as String? ?? 'Unknown',
      subregion: json['subregion'] as String? ?? 'Unknown',
      capital: capital,
      population: json['population'] as int? ?? 0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      currencies: currencies,
      languages: languages,
      timezones: timezones,
      alpha3Code: json['cca3'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': {'common': commonName, 'official': officialName},
        'flags': {'png': flagImageUrl},
        'region': region,
        'subregion': subregion,
        'capital': [capital],
        'population': population,
        'area': area,
        'currencies': {},
        'languages': {},
        'timezones': timezones,
        'cca3': alpha3Code,
      };

  Country copyWith({
    String? commonName,
    String? officialName,
    String? flagEmoji,
    String? region,
    String? subregion,
    String? capital,
    int? population,
    double? area,
    List<String>? currencies,
    List<String>? languages,
    List<String>? timezones,
    String? alpha3Code,
    String? flagImageUrl,
  }) {
    return Country(
      commonName: commonName ?? this.commonName,
      officialName: officialName ?? this.officialName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      area: area ?? this.area,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
      flagImageUrl: flagImageUrl ?? this.flagImageUrl,
    );
  }
}
