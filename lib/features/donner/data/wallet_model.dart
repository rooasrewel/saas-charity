class WalletModel {
  final double balance;
  final List<TransactionModel> transactions;

  WalletModel({
    required this.balance,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // اللارافيل يعيد balance بداخل الكائن العام أو بداخل 'data'
    final data = json['data'] ?? json;

    return WalletModel(
      balance: double.tryParse((data['balance'] ?? 0).toString()) ?? 0.0,
      transactions: (data['transactions'] as List?)
          ?.map((t) => TransactionModel.fromJson(t))
          .toList() ??
          [],
    );
  }
}

class TransactionModel {
  final int id;
  final String type; // deposit or donation
  final double amount;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'deposit',
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0.0,
      createdAt: json['created_at'] ?? '',
    );
  }
}