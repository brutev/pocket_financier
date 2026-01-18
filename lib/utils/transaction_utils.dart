import '../models/transaction.dart';

/// Utility class for transaction calculations
class TransactionUtils {
  /// Calculates the total credit amount from a list of transactions
  static double calculateTotalCredit(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'credit')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculates the total debit amount from a list of transactions
  static double calculateTotalDebit(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'debit')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculates net savings from total credit and debit
  static double calculateNetSavings(double totalCredit, double totalDebit) {
    return totalCredit - totalDebit;
  }

  /// Calculates savings percentage from total credit and net savings
  static double calculateSavingsPercentage(double totalCredit, double netSavings) {
    return totalCredit > 0 
        ? (netSavings / totalCredit * 100).clamp(0.0, 100.0) 
        : 0.0;
  }

  /// Counts the number of credit transactions
  static int countCreditTransactions(List<TransactionModel> transactions) {
    return transactions.where((t) => t.type == 'credit').length;
  }

  /// Counts the number of debit transactions
  static int countDebitTransactions(List<TransactionModel> transactions) {
    return transactions.where((t) => t.type == 'debit').length;
  }

  /// Categorizes expenses by category
  static Map<String, double> calculateCategoryTotals(List<TransactionModel> transactions) {
    final debitTransactions = transactions.where((tx) => tx.type == 'debit').toList();
    final Map<String, double> categoryTotals = {};
    
    for (final tx in debitTransactions) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    
    return categoryTotals;
  }
}
