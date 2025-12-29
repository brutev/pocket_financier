import '../models/transaction.dart';

class MonthlySnapshot {
  final String monthId; // "YYYY-MM"
  final double income;
  final double expense;
  final double savings;
  final double savingsRate;
  final Map<String, double> categoryBreakup;

  MonthlySnapshot({
    required this.monthId,
    required this.income,
    required this.expense,
    required this.savings,
    required this.savingsRate,
    required this.categoryBreakup,
  });

  Map<String, dynamic> toJson() {
    return {
      'monthId': monthId,
      'income': income,
      'expense': expense,
      'savings': savings,
      'savingsRate': savingsRate,
      'categoryBreakup': categoryBreakup,
    };
  }
}

class Flags {
  final String savingsFlag; // 'green', 'yellow', 'red'
  final String lifestyleFlag;
  final String debtFlag;

  Flags({
    required this.savingsFlag,
    required this.lifestyleFlag,
    required this.debtFlag,
  });

  Map<String, dynamic> toJson() {
    return {
      'savingsFlag': savingsFlag,
      'lifestyleFlag': lifestyleFlag,
      'debtFlag': debtFlag,
    };
  }
}

class StatsService {
  static Map<String, List<TransactionModel>> groupByMonth(List<TransactionModel> txs) {
    final Map<String, List<TransactionModel>> grouped = {};
    
    for (final tx in txs) {
      final monthId = '${tx.date.year.toString().padLeft(4, '0')}-${tx.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(monthId, () => []).add(tx);
    }
    
    return grouped;
  }

  static MonthlySnapshot buildSnapshotForMonth(String monthId, List<TransactionModel> txs) {
    final income = txs.where((tx) => tx.type == 'credit').fold(0.0, (sum, tx) => sum + tx.amount);
    final expense = txs.where((tx) => tx.type == 'debit').fold(0.0, (sum, tx) => sum + tx.amount);
    final savings = income - expense;
    final savingsRate = income > 0 ? (savings / income).clamp(-1.0, 1.0) : 0.0;
    
    final Map<String, double> categoryBreakup = {};
    for (final tx in txs.where((tx) => tx.type == 'debit')) {
      categoryBreakup[tx.category] = (categoryBreakup[tx.category] ?? 0) + tx.amount;
    }
    
    return MonthlySnapshot(
      monthId: monthId,
      income: income,
      expense: expense,
      savings: savings,
      savingsRate: savingsRate,
      categoryBreakup: categoryBreakup,
    );
  }

  static Flags computeFlags(MonthlySnapshot s, double approxEmi, double approxIncome) {
    // Savings flag
    String savingsFlag;
    if (s.savingsRate >= 0.3) {
      savingsFlag = 'green';
    } else if (s.savingsRate >= 0.2) {
      savingsFlag = 'yellow';
    } else {
      savingsFlag = 'red';
    }
    
    // Lifestyle flag
    final discretionary = (s.categoryBreakup['Food'] ?? 0) + 
                         (s.categoryBreakup['Shopping'] ?? 0) + 
                         (s.categoryBreakup['Travel'] ?? 0);
    String lifestyleFlag;
    final discRatio = approxIncome > 0 ? discretionary / approxIncome : 0;
    if (discRatio > 0.35) {
      lifestyleFlag = 'red';
    } else if (discRatio > 0.25) {
      lifestyleFlag = 'yellow';
    } else {
      lifestyleFlag = 'green';
    }
    
    // Debt flag
    String debtFlag;
    final emiRatio = approxIncome > 0 ? approxEmi / approxIncome : 0;
    if (emiRatio > 0.5) {
      debtFlag = 'red';
    } else if (emiRatio > 0.3) {
      debtFlag = 'yellow';
    } else {
      debtFlag = 'green';
    }
    
    return Flags(
      savingsFlag: savingsFlag,
      lifestyleFlag: lifestyleFlag,
      debtFlag: debtFlag,
    );
  }
}