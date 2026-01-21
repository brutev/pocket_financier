import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';
import '../services/sms_service.dart';
import '../utils/transaction_utils.dart';
import 'transactions_page.dart';
import 'dashboard_page.dart';
import 'coach_page.dart';
import 'debug_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<TransactionModel>> _transactionsNotifier = ValueNotifier<List<TransactionModel>>([]);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);

  DateTime? _startDate;
  DateTime? _endDate;
  List<TransactionModel> get _filteredTransactions {
    if (_startDate == null && _endDate == null) return _transactionsNotifier.value;
    return _transactionsNotifier.value.where((tx) {
      final date = tx.effectiveDate;
      if (_startDate != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date.isAfter(_endDate!)) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _transactionsNotifier.dispose();
    _loadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _requestSmsPermissionAndImport();
    await _loadTransactions();
  }

  Future<void> _requestSmsPermissionAndImport() async {
    final hasPermission = await SmsService.requestPermission();
    if (hasPermission) {
      _loadingNotifier.value = true;
      try {
        await SmsService.importSms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SMS transactions imported successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error importing SMS: $e')),
          );
        }
      } finally {
        _loadingNotifier.value = false;
      }
    }
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _startDate != null
                            ? 'From: ${_startDate!.toLocal().toString().split(' ')[0]}'
                            : 'From',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _endDate != null
                          ? 'To: ${_endDate!.toLocal().toString().split(' ')[0]}'
                          : 'To',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_startDate != null || _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              tooltip: 'Clear filter',
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Future<void> _loadTransactions() async {
    final transactions = await TransactionDb.getAll();
    // Log transactions to console
    for (final tx in transactions) {
      // ignore: avoid_print
      print('[Transaction] id: [32m${tx.id}[0m, date: ${tx.date}, amount: ${tx.amount}, type: ${tx.type}, category: ${tx.category}, desc: ${tx.description}');
    }
    _transactionsNotifier.value = transactions;
  }

  Future<void> _importSms() async {
    _loadingNotifier.value = true;
    
    try {
      final hasPermission = await SmsService.requestPermission();
      if (hasPermission) {
        await SmsService.importSms();
        await _loadTransactions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SMS imported successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SMS permission denied')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing SMS: $e')),
        );
      }
    } finally {
      _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return ValueListenableBuilder<List<TransactionModel>>(
          valueListenable: _transactionsNotifier,
          builder: (context, transactions, _) {
                        // Log transactions on every update
                        // ignore: avoid_print
                        print('[HomePage] Transactions updated. Count: [34m${transactions.length}[0m');
            // Calculate totals efficiently using utility functions
            final totalCredit = TransactionUtils.calculateTotalCredit(transactions);
            final totalDebit = TransactionUtils.calculateTotalDebit(transactions);
            final netSavings = TransactionUtils.calculateNetSavings(totalCredit, totalDebit);
            final savingsPercentage = TransactionUtils.calculateSavingsPercentage(totalCredit, netSavings);

            // Reference _filteredTransactions to avoid unused warning
            final filtered = _filteredTransactions;

            final pages = <Widget>[
              Column(
                children: [
                  _buildDateFilter(),
                  Expanded(child: _buildHomePage(totalCredit, totalDebit, netSavings, savingsPercentage, filtered)),
                ],
              ),
              TransactionsPage(transactions: filtered),
              DashboardPage(transactions: filtered),
              CoachPage(transactions: filtered),
            ];

            return Scaffold(
              extendBodyBehindAppBar: false,
              appBar: AppBar(
                elevation: 0,
                title: const Text(
                  'Pocket Financier',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bug_report),
                    tooltip: 'Debug',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DebugPage()),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _loadingNotifier,
                    builder: (context, loading, _) {
                      return IconButton(
                        icon: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        tooltip: 'Refresh',
                        onPressed: loading ? null : _importSms,
                      );
                    },
                  ),
                ],
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: pages[currentIndex],
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: currentIndex,
                  onTap: (index) => _currentIndexNotifier.value = index,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Colors.grey,
                  selectedFontSize: 12,
                  unselectedFontSize: 11,
                  iconSize: 24,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_rounded),
                      activeIcon: Icon(Icons.receipt_long_rounded),
                      label: 'Transactions',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_rounded),
                      activeIcon: Icon(Icons.dashboard_rounded),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.psychology_rounded),
                      activeIcon: Icon(Icons.psychology_rounded),
                      label: 'Coach',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomePage(double totalCredit, double totalDebit, double netSavings, double savingsPercentage, List<TransactionModel> transactions) {
    final isPositive = netSavings >= 0;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Net Savings Hero Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPositive
                      ? [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ]
                      : [
                          Colors.red.shade400,
                          Colors.red.shade600,
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Savings',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${netSavings.abs().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (totalCredit > 0) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Savings Rate',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: savingsPercentage / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${savingsPercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Financial Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.arrow_downward_rounded,
                    label: 'Total Credit',
                    amount: totalCredit,
                    color: Colors.green,
                    iconColor: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.arrow_upward_rounded,
                    label: 'Total Debit',
                    amount: totalDebit,
                    color: Colors.red,
                    iconColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Transaction Count Card
            _buildTransactionCountCard(context, transactions),
            const SizedBox(height: 24),
            // Tip Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Tip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use Dashboard to see spending charts and Coach for AI-powered financial advice based on your transactions.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: iconColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCountCard(BuildContext context, List<TransactionModel> transactions) {
    final transactionCount = transactions.length;
    final creditCount = TransactionUtils.countCreditTransactions(transactions);
    final debitCount = TransactionUtils.countDebitTransactions(transactions);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondaryContainer,
            Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Transactions',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$transactionCount',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniStat('Credits', creditCount, Colors.green),
              const SizedBox(height: 8),
              _buildMiniStat('Debits', debitCount, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}