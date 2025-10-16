// Comprehensive list of world currencies
class CurrencyData {
  final String code;
  final String name;
  final String symbol;
  final String country;

  const CurrencyData({
    required this.code,
    required this.name,
    required this.symbol,
    required this.country,
  });
}

const List<CurrencyData> worldCurrencies = [
  // Major currencies
  CurrencyData(
      code: 'PKR', name: 'Pakistani Rupee', symbol: '₨', country: 'Pakistan'),
  CurrencyData(
      code: 'USD', name: 'US Dollar', symbol: '\$', country: 'United States'),
  CurrencyData(
      code: 'EUR', name: 'Euro', symbol: '€', country: 'European Union'),
  CurrencyData(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      country: 'United Kingdom'),
  CurrencyData(
      code: 'JPY', name: 'Japanese Yen', symbol: '¥', country: 'Japan'),
  CurrencyData(
      code: 'CNY', name: 'Chinese Yuan', symbol: '¥', country: 'China'),
  CurrencyData(
      code: 'INR', name: 'Indian Rupee', symbol: '₹', country: 'India'),
  CurrencyData(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      country: 'Australia'),
  CurrencyData(
      code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', country: 'Canada'),
  CurrencyData(
      code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', country: 'Switzerland'),

  // Asian currencies
  CurrencyData(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
      country: 'United Arab Emirates'),
  CurrencyData(
      code: 'AFN', name: 'Afghan Afghani', symbol: '؋', country: 'Afghanistan'),
  CurrencyData(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      country: 'Bangladesh'),
  CurrencyData(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      country: 'Indonesia'),
  CurrencyData(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      country: 'South Korea'),
  CurrencyData(
      code: 'LKR',
      name: 'Sri Lankan Rupee',
      symbol: 'Rs',
      country: 'Sri Lanka'),
  CurrencyData(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      country: 'Malaysia'),
  CurrencyData(
      code: 'NPR', name: 'Nepalese Rupee', symbol: 'Rs', country: 'Nepal'),
  CurrencyData(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      country: 'Philippines'),
  CurrencyData(
      code: 'SAR', name: 'Saudi Riyal', symbol: 'SR', country: 'Saudi Arabia'),
  CurrencyData(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      country: 'Singapore'),
  CurrencyData(
      code: 'THB', name: 'Thai Baht', symbol: '฿', country: 'Thailand'),
  CurrencyData(
      code: 'TRY', name: 'Turkish Lira', symbol: '₺', country: 'Turkey'),
  CurrencyData(
      code: 'VND', name: 'Vietnamese Dong', symbol: '₫', country: 'Vietnam'),

  // Middle Eastern currencies
  CurrencyData(
      code: 'BHD', name: 'Bahraini Dinar', symbol: 'BD', country: 'Bahrain'),
  CurrencyData(
      code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', country: 'Egypt'),
  CurrencyData(
      code: 'IQD', name: 'Iraqi Dinar', symbol: 'IQD', country: 'Iraq'),
  CurrencyData(
      code: 'ILS', name: 'Israeli Shekel', symbol: '₪', country: 'Israel'),
  CurrencyData(
      code: 'JOD', name: 'Jordanian Dinar', symbol: 'JD', country: 'Jordan'),
  CurrencyData(
      code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KD', country: 'Kuwait'),
  CurrencyData(
      code: 'LBP', name: 'Lebanese Pound', symbol: 'LL', country: 'Lebanon'),
  CurrencyData(code: 'OMR', name: 'Omani Rial', symbol: 'OMR', country: 'Oman'),
  CurrencyData(
      code: 'QAR', name: 'Qatari Riyal', symbol: 'QR', country: 'Qatar'),

  // African currencies
  CurrencyData(
      code: 'DZD', name: 'Algerian Dinar', symbol: 'DZD', country: 'Algeria'),
  CurrencyData(
      code: 'MAD', name: 'Moroccan Dirham', symbol: 'MAD', country: 'Morocco'),
  CurrencyData(
      code: 'NGN', name: 'Nigerian Naira', symbol: '₦', country: 'Nigeria'),
  CurrencyData(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      country: 'South Africa'),
  CurrencyData(
      code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', country: 'Kenya'),
  CurrencyData(
      code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', country: 'Ghana'),
  CurrencyData(
      code: 'TND', name: 'Tunisian Dinar', symbol: 'TND', country: 'Tunisia'),

  // European currencies
  CurrencyData(
      code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', country: 'Bulgaria'),
  CurrencyData(
      code: 'CZK',
      name: 'Czech Koruna',
      symbol: 'Kč',
      country: 'Czech Republic'),
  CurrencyData(
      code: 'DKK', name: 'Danish Krone', symbol: 'kr', country: 'Denmark'),
  CurrencyData(
      code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', country: 'Hungary'),
  CurrencyData(
      code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', country: 'Norway'),
  CurrencyData(
      code: 'PLN', name: 'Polish Zloty', symbol: 'zł', country: 'Poland'),
  CurrencyData(
      code: 'RON', name: 'Romanian Leu', symbol: 'lei', country: 'Romania'),
  CurrencyData(
      code: 'RUB', name: 'Russian Ruble', symbol: '₽', country: 'Russia'),
  CurrencyData(
      code: 'SEK', name: 'Swedish Krona', symbol: 'kr', country: 'Sweden'),
  CurrencyData(
      code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴', country: 'Ukraine'),

  // American currencies
  CurrencyData(
      code: 'ARS', name: 'Argentine Peso', symbol: '\$', country: 'Argentina'),
  CurrencyData(
      code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', country: 'Brazil'),
  CurrencyData(
      code: 'CLP', name: 'Chilean Peso', symbol: '\$', country: 'Chile'),
  CurrencyData(
      code: 'COP', name: 'Colombian Peso', symbol: '\$', country: 'Colombia'),
  CurrencyData(
      code: 'MXN', name: 'Mexican Peso', symbol: '\$', country: 'Mexico'),
  CurrencyData(
      code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', country: 'Peru'),

  // Oceania currencies
  CurrencyData(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      country: 'New Zealand'),
  CurrencyData(
      code: 'FJD', name: 'Fijian Dollar', symbol: 'FJ\$', country: 'Fiji'),

  // Other currencies
  CurrencyData(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      country: 'Hong Kong'),
  CurrencyData(
      code: 'TWD', name: 'Taiwan Dollar', symbol: 'NT\$', country: 'Taiwan'),
  CurrencyData(
      code: 'ISK', name: 'Icelandic Króna', symbol: 'kr', country: 'Iceland'),
];

// Helper function to get currency symbol
String getCurrencySymbol(String code) {
  try {
    return worldCurrencies.firstWhere((c) => c.code == code).symbol;
  } catch (e) {
    return code;
  }
}

// Helper function to get currency name
String getCurrencyName(String code) {
  try {
    return worldCurrencies.firstWhere((c) => c.code == code).name;
  } catch (e) {
    return code;
  }
}
