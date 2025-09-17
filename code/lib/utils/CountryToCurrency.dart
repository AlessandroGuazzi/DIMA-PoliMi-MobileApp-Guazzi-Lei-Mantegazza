import 'package:flutter/cupertino.dart';

class CountryToCurrency {
  //Hardcoded mapping
  final Map<String, String> countryToCurrency = {
    'Afghanistan': 'AFN',  // Afghan Afghani
    'Albania': 'ALL',      // Albanian Lek
    'Algeria': 'DZD',      // Algerian Dinar
    'Andorra': 'EUR',      // Euro
    'Angola': 'AOA',       // Angolan Kwanza
    'Antigua and Barbuda': 'XCD', // East Caribbean Dollar
    'Argentina': 'ARS',    // Argentine Peso
    'Armenia': 'AMD',      // Armenian Dram
    'Australia': 'AUD',    // Australian Dollar
    'Austria': 'EUR',      // Euro
    'Azerbaijan': 'AZN',   // Azerbaijani Manat
    'Bahamas': 'BSD',      // Bahamian Dollar
    'Bahrain': 'BHD',      // Bahraini Dinar
    'Bangladesh': 'BDT',   // Bangladeshi Taka
    'Barbados': 'BBD',     // Barbadian Dollar
    'Belarus': 'BYN',      // Belarusian Ruble
    'Belgium': 'EUR',      // Euro
    'Belize': 'BZD',       // Belize Dollar
    'Benin': 'XOF',        // West African CFA Franc
    'Bhutan': 'BTN',       // Bhutanese Ngultrum
    'Bolivia': 'BOB',      // Bolivian Boliviano
    'Bosnia and Herzegovina': 'BAM', // Convertible Mark
    'Botswana': 'BWP',     // Botswana Pula
    'Brazil': 'BRL',       // Brazilian Real
    'Brunei': 'BND',       // Brunei Dollar
    'Bulgaria': 'BGN',     // Bulgarian Lev
    'Burkina Faso': 'XOF', // West African CFA Franc
    'Burundi': 'BIF',      // Burundian Franc
    'Cabo Verde': 'CVE',   // Cape Verdean Escudo
    'Cambodia': 'KHR',     // Cambodian Riel
    'Cameroon': 'XAF',     // Central African CFA Franc
    'Canada': 'CAD',       // Canadian Dollar
    'Central African Republic': 'XAF', // Central African CFA Franc
    'Chad': 'XAF',         // Central African CFA Franc
    'Chile': 'CLP',        // Chilean Peso
    'China': 'CNY',        // Chinese Yuan
    'Colombia': 'COP',     // Colombian Peso
    'Comoros': 'KMF',      // Comorian Franc
    'Congo (Congo-Brazzaville)': 'XAF', // Central African CFA Franc
    'Costa Rica': 'CRC',   // Costa Rican Colón
    'Croatia': 'HRK',      // Croatian Kuna
    'Cuba': 'CUP',         // Cuban Peso
    'Cyprus': 'EUR',       // Euro
    'Czech Republic': 'CZK', // Czech Koruna
    'Democratic Republic of the Congo': 'CDF', // Congolese Franc
    'Denmark': 'DKK',      // Danish Krone
    'Djibouti': 'DJF',     // Djiboutian Franc
    'Dominica': 'XCD',     // East Caribbean Dollar
    'Dominican Republic': 'DOP', // Dominican Peso
    'East Timor': 'USD',   // United States Dollar
    'Ecuador': 'USD',      // United States Dollar
    'Egypt': 'EGP',        // Egyptian Pound
    'El Salvador': 'USD',  // United States Dollar
    'Equatorial Guinea': 'XAF', // Central African CFA Franc
    'Eritrea': 'ERN',      // Eritrean Nakfa
    'Estonia': 'EUR',      // Euro
    'Eswatini (Swaziland)': 'SZL', // Swazi Lilangeni
    'Ethiopia': 'ETB',     // Ethiopian Birr
    'Fiji': 'FJD',         // Fijian Dollar
    'Finland': 'EUR',      // Euro
    'France': 'EUR',       // Euro
    'Gabon': 'XAF',        // Central African CFA Franc
    'Gambia': 'GMD',       // Gambian Dalasi
    'Georgia': 'GEL',      // Georgian Lari
    'Germany': 'EUR',      // Euro
    'Ghana': 'GHS',        // Ghanaian Cedi
    'Greece': 'EUR',       // Euro
    'Grenada': 'XCD',      // East Caribbean Dollar
    'Guatemala': 'GTQ',    // Guatemalan Quetzal
    'Guinea': 'GNF',       // Guinean Franc
    'Guinea-Bissau': 'XOF', // West African CFA Franc
    'Guyana': 'GYD',       // Guyanese Dollar
    'Haiti': 'HTG',        // Haitian Gourde
    'Honduras': 'HNL',     // Honduran Lempira
    'Hong Kong': 'HKD',     // Hong Kong dollar
    'Hungary': 'HUF',      // Hungarian Forint
    'Iceland': 'ISK',      // Icelandic Króna
    'India': 'INR',        // Indian Rupee
    'Indonesia': 'IDR',    // Indonesian Rupiah
    'Iran': 'IRR',         // Iranian Rial
    'Iraq': 'IQD',         // Iraqi Dinar
    'Ireland': 'EUR',      // Euro
    'Israel': 'ILS',       // Israeli New Shekel
    'Italy': 'EUR',        // Euro
    'Ivory Coast (Côte d\'Ivoire)': 'XOF', // West African CFA Franc
    'Jamaica': 'JMD',      // Jamaican Dollar
    'Japan': 'JPY',        // Japanese Yen
    'Jordan': 'JOD',       // Jordanian Dinar
    'Kazakhstan': 'KZT',   // Kazakhstani Tenge
    'Kenya': 'KES',        // Kenyan Shilling
    'Kiribati': 'AUD',     // Australian Dollar
    'Korea, North': 'KPW', // North Korean Won
    'Korea, South': 'KRW', // South Korean Won
    'Kuwait': 'KWD',       // Kuwaiti Dinar
    'Kyrgyzstan': 'KGS',   // Kyrgyzstani Som
    'Laos': 'LAK',         // Lao Kip
    'Latvia': 'EUR',       // Euro
    'Lebanon': 'LBP',      // Lebanese Pound
    'Lesotho': 'LSL',      // Lesotho Loti
    'Liberia': 'LRD',      // Liberian Dollar
    'Libya': 'LYD',        // Libyan Dinar
    'Liechtenstein': 'CHF', // Swiss Franc
    'Lithuania': 'EUR',    // Euro
    'Luxembourg': 'LUF',   // Luxembourgish Franc
    'Macau': 'MOP',        // Pataca
    'Madagascar': 'MGA',   // Malagasy Ariary
    'Malawi': 'MWK',       // Malawian Kwacha
    'Malaysia': 'MYR',     // Malaysian Ringgit
    'Maldives': 'MVR',     // Maldivian Rufiyaa
    'Mali': 'XOF',         // West African CFA Franc
    'Malta': 'EUR',        // Euro
    'Marshall Islands': 'USD', // United States Dollar
    'Mauritania': 'MRU',   // Mauritanian Ouguiya
    'Mauritius': 'MUR',    // Mauritian Rupee
    'Mexico': 'MXN',       // Mexican Peso
    'Micronesia': 'USD',   // United States Dollar
    'Moldova': 'MDL',      // Moldovan Leu
    'Monaco': 'EUR',       // Euro
    'Mongolia': 'MNT',     // Mongolian Tugrik
    'Montenegro': 'EUR',   // Euro
    'Morocco': 'MAD',      // Moroccan Dirham
    'Mozambique': 'MZN',   // Mozambican Metical
    'Myanmar': 'MMK',      // Kyat
    'Namibia': 'NAD',      // Namibian Dollar
    'Nauru': 'AUD',        // Australian Dollar
    'Nepal': 'NPR',        // Nepalese Rupee
    'Netherlands': 'EUR',  // Euro
    'New Zealand': 'NZD',  // New Zealand Dollar
    'Nicaragua': 'NIO',    // Nicaraguan Córdoba
    'Niger': 'XOF',        // West African CFA Franc
    'Nigeria': 'NGN',      // Nigerian Naira
    'North Macedonia': 'MKD', // Macedonian Denar
    'Norway': 'NOK',       // Norwegian Krone
    'Oman': 'OMR',         // Omani Rial
    'Pakistan': 'PKR',     // Pakistani Rupee
    'Palau': 'USD',        // United States Dollar
    'Panama': 'PAB',       // Panamanian Balboa
    'Papua New Guinea': 'PGK', // Kina
    'Paraguay': 'PYG',     // Paraguayan Guarani
    'Peru': 'PEN',         // Peruvian Nuevo Sol
    'Philippines': 'PHP',  // Philippine Peso
    'Poland': 'PLN',       // Polish Zloty
    'Portugal': 'EUR',     // Euro
    'Qatar': 'QAR',        // Qatari Riyal
    'Romania': 'RON',      // Romanian Leu
    'Russia': 'RUB',       // Russian Ruble
    'Rwanda': 'RWF',       // Rwandan Franc
    'Saint Kitts and Nevis': 'XCD', // East Caribbean Dollar
    'Saint Lucia': 'XCD',  // East Caribbean Dollar
    'Saint Vincent and the Grenadines': 'XCD', // East Caribbean Dollar
    'Samoa': 'WST',        // Samoan Tala
    'San Marino': 'SML',   // Sammarinese Lira
    'São Tomé and Príncipe': 'STN', // São Tomé and Príncipe Dobra
    'Saudi Arabia': 'SAR', // Saudi Riyal
    'Senegal': 'XOF',      // West African CFA Franc
    'Serbia': 'RSD',       // Serbian Dinar
    'Seychelles': 'SCR',   // Seychellois Rupee
    'Sierra Leone': 'SLL', // Sierra Leonean Leone
    'Singapore': 'SGD',    // Singapore Dollar
    'Slovakia': 'EUR',       // Euro
    'Slovenia': 'EUR',       // Euro
    'Solomon Islands': 'SBD', // Solomon Islands Dollar
    'Somalia': 'SOS',        // Somali Shilling
    'South Africa': 'ZAR',   // South African Rand
    'South Sudan': 'SSP',    // South Sudanese Pound
    'Spain': 'EUR',          // Euro
    'Sri Lanka': 'LKR',      // Sri Lankan Rupee
    'Sudan': 'SDG',          // Sudanese Pound
    'Suriname': 'SRD',       // Surinamese Dollar
    'Sweden': 'SEK',         // Swedish Krona
    'Switzerland': 'CHF',    // Swiss Franc
    'Syria': 'SYP',          // Syrian Pound
    'Taiwan': 'TWD',         // New Taiwan Dollar
    'Tajikistan': 'TJS',     // Tajikistani Somoni
    'Tanzania': 'TZS',       // Tanzanian Shilling
    'Thailand': 'THB',       // Thai Baht
    'Togo': 'XOF',           // West African CFA Franc
    'Tonga': 'TOP',          // Tongan Paʻanga
    'Trinidad and Tobago': 'TTD', // Trinidad and Tobago Dollar
    'Tunisia': 'TND',        // Tunisian Dinar
    'Turkey': 'TRY',         // Turkish Lira
    'Turkmenistan': 'TMT',   // Turkmenistani Manat
    'Tuvalu': 'AUD',         // Australian Dollar
    'Uganda': 'UGX',         // Ugandan Shilling
    'Ukraine': 'UAH',        // Ukrainian Hryvnia
    'United Arab Emirates': 'AED', // Emirati Dirham
    'United Kingdom': 'GBP', // British Pound Sterling
    'United States': 'USD',  // United States Dollar
    'Uruguay': 'UYU',        // Uruguayan Peso
    'Uzbekistan': 'UZS',     // Uzbekistani Som
    'Vanuatu': 'VUV',        // Vanuatu Vatu
    'Vatican City': 'EUR',   // Euro
    'Venezuela': 'VES',      // Venezuelan Bolívar
    'Vietnam': 'VND',        // Vietnamese Dong
    'Yemen': 'YER',          // Yemeni Rial
    'Zambia': 'ZMW',         // Zambian Kwacha
    'Zimbabwe': 'ZWD',       // Zimbabwean Dollar
  };


  String getCurrency(String country) {
    final currency = countryToCurrency[country];
    if(currency != null) {
      return currency;
    } else {
      return '';
    }
  }

  List<String> initializeCurrencies(List<Map<String, dynamic>>? countries) {
    if (countries != null && countries.isNotEmpty) {
      final countriesNames = countries
          .map((country) => country['name'] as String)
          .toList();

      Set<String> currencies = {};
      for (String country in countriesNames) {
        final currency = CountryToCurrency().getCurrency(country);
        if (currency != '') currencies.add(currency);
      }

      // Keep euros as a 'default' currency
      currencies.add('EUR');

      return currencies.toList();
    } else {
      return [];
    }
  }

  Widget formatPopularCurrencies(String currency) {
    const Map<String, String> currencySymbols = {
      'USD': '\$', // US Dollar
      'EUR': '€',  // Euro
      'GBP': '£',  // British Pound
      'JPY': '¥',  // Japanese Yen
      'INR': '₹',  // Indian Rupee
      'CNY': '¥',  // Chinese Yuan
      'RUB': '₽',  // Russian Ruble
      'KRW': '₩',  // South Korean Won
      'NGN': '₦',  // Nigerian Naira
      'THB': '฿',  // Thai Baht
      'BRL': 'R\$' // Brazilian Real
    };

    String symbol = currencySymbols[currency] ?? currency;

    return Text(
      symbol,
      style: const TextStyle(fontSize: 18),
    );
  }
}