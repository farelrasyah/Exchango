import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/Constant.dart';
import '../models/currencyModel.dart';

class ApiService {
  Future<CurrencyModel> getExchangeRates(String baseCurrency) async {
    try {
      final url =
          '${AppConstants.baseUrl}/${AppConstants.apiKey}/latest/$baseCurrency';
      print('Fetching exchange rates from: $url');

      final response = await http
          .get(
        Uri.parse(url),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
              'Request timed out. Please check your internet connection.');
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['result'] == 'success') {
            return CurrencyModel.fromJson(data);
          } else {
            throw Exception(
                data['error-type'] ?? 'API Error: ${data['error-type']}');
          }
        } catch (e) {
          print('Error parsing response: $e');
          throw Exception('Failed to parse exchange rates data');
        }
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid API key. Please check your API configuration.');
      } else if (response.statusCode == 404) {
        throw Exception('Currency not found. Please try another currency.');
      } else {
        throw Exception(
            'Server error (${response.statusCode}). Please try again later.');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');

      // Return default rates if API fails
      return CurrencyModel(
        result: 'success',
        conversionRates: {
          'USD': 0.000064,
          'EUR': 0.000059,
          'GBP': 0.000051,
          'JPY': 0.009657,
          'IDR': 1.0,
        },
        baseCode: baseCurrency,
        lastUpdateUtc: DateTime.now().toUtc().toString(),
      );
    }
  }
}
