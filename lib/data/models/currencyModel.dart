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
    return CurrencyModel(
      result: json['result'],
      conversionRates: Map<String, double>.from(json['conversion_rates']),
      baseCode: json['base_code'],
      lastUpdateUtc: json['time_last_update_utc'],
    );
  }
}