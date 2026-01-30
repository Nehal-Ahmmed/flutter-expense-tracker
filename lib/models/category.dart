import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum CategoryType {
  food,
  transport,
  shopping,
  entertainment,
  health,
  salary,
  freelance,
  bills,
  other,
}

extension CategoryExtension on CategoryType {
  String get name {
    switch (this) {
      case CategoryType.food:
        return 'Food & Dining';
      case CategoryType.transport:
        return 'Transport';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.health:
        return 'Health & Fitness';
      case CategoryType.salary:
        return 'Salary';
      case CategoryType.freelance:
        return 'Freelance';
      case CategoryType.bills:
        return 'Bills & Utilities';
      case CategoryType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.food:
        return FontAwesomeIcons.burger;
      case CategoryType.transport:
        return FontAwesomeIcons.bus;
      case CategoryType.shopping:
        return FontAwesomeIcons.bagShopping;
      case CategoryType.entertainment:
        return FontAwesomeIcons.film;
      case CategoryType.health:
        return FontAwesomeIcons.heartPulse;
      case CategoryType.salary:
        return FontAwesomeIcons.moneyBill;
      case CategoryType.freelance:
        return FontAwesomeIcons.laptopCode;
      case CategoryType.bills:
        return FontAwesomeIcons.fileInvoiceDollar;
      case CategoryType.other:
        return FontAwesomeIcons.boxOpen;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.food:
        return Colors.orange;
      case CategoryType.transport:
        return Colors.blue;
      case CategoryType.shopping:
        return Colors.pink;
      case CategoryType.entertainment:
        return Colors.purple;
      case CategoryType.health:
        return Colors.red;
      case CategoryType.salary:
        return Colors.green;
      case CategoryType.freelance:
        return Colors.teal;
      case CategoryType.bills:
        return Colors.indigo;
      case CategoryType.other:
        return Colors.grey;
    }
  }
}
