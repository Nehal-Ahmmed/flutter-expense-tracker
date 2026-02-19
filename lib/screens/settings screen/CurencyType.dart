import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum CurrencyType {
  USD,
  EUR,
  GBP,
  JPY,
  CNY,
  INR,
  BDT,
  PKR,
  AED,
  SAR,
  CAD,
  AUD,
}

extension CurrencyExtension on CurrencyType {
  // কারেন্সির নাম
  String get name {
    switch (this) {
      case CurrencyType.USD:
        return 'US Dollar';
      case CurrencyType.EUR:
        return 'Euro';
      case CurrencyType.GBP:
        return 'British Pound';
      case CurrencyType.JPY:
        return 'Japanese Yen';
      case CurrencyType.CNY:
        return 'Chinese Yuan';
      case CurrencyType.INR:
        return 'Indian Rupee';
      case CurrencyType.BDT:
        return 'Bangladeshi Taka';
      case CurrencyType.PKR:
        return 'Pakistani Rupee';
      case CurrencyType.AED:
        return 'UAE Dirham';
      case CurrencyType.SAR:
        return 'Saudi Riyal';
      case CurrencyType.CAD:
        return 'Canadian Dollar';
      case CurrencyType.AUD:
        return 'Australian Dollar';
    }
  }

  // কারেন্সি সিম্বল
  String get symbol {
    switch (this) {
      case CurrencyType.USD:
        return '\$';
      case CurrencyType.EUR:
        return '€';
      case CurrencyType.GBP:
        return '£';
      case CurrencyType.JPY:
        return '¥';
      case CurrencyType.CNY:
        return '¥';
      case CurrencyType.INR:
        return '₹';
      case CurrencyType.BDT:
        return '৳';
      case CurrencyType.PKR:
        return '₨';
      case CurrencyType.AED:
        return 'د.إ';
      case CurrencyType.SAR:
        return '﷼';
      case CurrencyType.CAD:
        return 'C\$';
      case CurrencyType.AUD:
        return 'A\$';
    }
  }

  // ডিফল্ট হিসেবে কোনটা সিলেক্টেড থাকবে
  static CurrencyType get defaultCurrency => CurrencyType.USD;

  // লোকাল কারেন্সি (দেশ অনুযায়ী)
  static CurrencyType get localCurrency => CurrencyType.BDT; // বাংলাদেশের জন্য
}

// লোকাল আইকনের জন্য (যদি ফন্ট অ্যাওসাম ব্যবহার করেন)

extension CurrencyIcon on CurrencyType {
  IconData get icon {
    switch (this) {
      case CurrencyType.USD:
        return FontAwesomeIcons.dollarSign;
      case CurrencyType.EUR:
        return FontAwesomeIcons.euroSign;
      case CurrencyType.GBP:
        return FontAwesomeIcons.poundSign;
      case CurrencyType.JPY:
      case CurrencyType.CNY:
        return FontAwesomeIcons.yenSign;
      case CurrencyType.INR:
        return FontAwesomeIcons.indianRupeeSign;
      case CurrencyType.BDT:
        return FontAwesomeIcons.bangladeshiTakaSign;
      default:
        return FontAwesomeIcons.moneyBill;
    }
  }
}