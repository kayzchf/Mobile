import 'package:intl/intl.dart';

enum CurrencyType { idr, usd, gbp }

class CurrencyService {
  static final CurrencyService instance = CurrencyService._init();
  CurrencyService._init();

  // Exchange Rates relative to IDR (Base)
  // 1 USD = Rp 15,600
  // 1 GBP = Rp 19,650
  static const double rateUsdToIdr = 15600.0;
  static const double rateGbpToIdr = 19650.0;

  CurrencyType currentCurrency = CurrencyType.idr;

  void setCurrency(CurrencyType type) {
    currentCurrency = type;
  }

  String get currencyCode {
    switch (currentCurrency) {
      case CurrencyType.idr:
        return 'IDR';
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.gbp:
        return 'GBP';
    }
  }

  String get currencySymbol {
    switch (currentCurrency) {
      case CurrencyType.idr:
        return 'Rp ';
      case CurrencyType.usd:
        return '\$ ';
      case CurrencyType.gbp:
        return '£ ';
    }
  }

  // Convert an IDR amount into selected currency
  double convertFromIdr(num idrAmount) {
    switch (currentCurrency) {
      case CurrencyType.idr:
        return idrAmount.toDouble();
      case CurrencyType.usd:
        return double.parse((idrAmount / rateUsdToIdr).toStringAsFixed(2));
      case CurrencyType.gbp:
        return double.parse((idrAmount / rateGbpToIdr).toStringAsFixed(2));
    }
  }

  // Format price string nicely
  String formatPrice(num idrAmount) {
    final converted = convertFromIdr(idrAmount);
    switch (currentCurrency) {
      case CurrencyType.idr:
        final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        return formatter.format(converted);
      case CurrencyType.usd:
        return '\$ ${converted.toStringAsFixed(2)}';
      case CurrencyType.gbp:
        return '£ ${converted.toStringAsFixed(2)}';
    }
  }

  // Convert custom currency to IDR
  double convertToIdr(double amount, String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return amount * rateUsdToIdr;
      case 'GBP':
        return amount * rateGbpToIdr;
      case 'IDR':
      default:
        return amount;
    }
  }
}

