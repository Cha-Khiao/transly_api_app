import 'package:intl/intl.dart';

class Transaction {
  final String? uuid;
  final String name;
  final String? desc;
  final double amount;
  final int type;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.uuid,
    required this.name,
    this.desc,
    required this.amount,
    required this.type,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.empty() {
    return Transaction(
      uuid: null,
      name: 'ไม่พบข้อมูล',
      amount: 0,
      type: -1,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  String get typeText => type == 1 ? 'รายรับ' : 'รายจ่าย';

  String get amountText {
    final formatCurrency = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    String formattedAmount = formatCurrency.format(amount);
    return type == 1 ? '+ $formattedAmount' : '- $formattedAmount';
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      uuid: json['uuid'],
      name: json['name'] ?? '',
      desc: json['desc'],
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'type': type,
      if (desc != null) 'desc': desc,
      if (date != null) 'date': date?.toIso8601String(),
    };
  }
}
