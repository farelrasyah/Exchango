class CurrencyModel {
  final String result;
  final Map<String, double> conversionRates;
  final String baseCode;
  final String lastUpdateUtc;

  CurrencyModel({
    required this.result,
    required this.conversionRates,
    required this.baseCode,
    required this.lastUpdateUtc,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    // Convert the conversion_rates map values to double
    Map<String, double> rates = {};
    (json['conversion_rates'] as Map<String, dynamic>).forEach((key, value) {
      // Handle both int and double values
      rates[key] = value is int ? value.toDouble() : value;
    });

    return CurrencyModel(
      result: json['result'],
      conversionRates: rates,
      baseCode: json['base_code'],
      lastUpdateUtc: json['time_last_update_utc'],
    );
  }
}
