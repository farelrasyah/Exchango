import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/Constant.dart';
import '../models/currencyModel.dart';

class ApiService {
  Future<CurrencyModel> getExchangeRates(String baseCurrency) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiKey}/latest/$baseCurrency'),
    );

    if (response.statusCode == 200) {
      return CurrencyModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}