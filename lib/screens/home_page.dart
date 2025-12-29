import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';
import '../services/sms_service.dart';
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
  int _currentIndex = 0;
  List<TransactionModel> _transactions = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestSmsPermissionAndImport();
    await _loadTransactions();
  }

  Future<void> _requestSmsPermissionAndImport() async {
    final hasPermission = await SmsService.requestPermission();
    if (hasPermission) {
      setState(() => _loading = true);
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
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadTransactions() async {
    final transactions = await TransactionDb.getAll();
    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _importSms() async {
    setState(() => _loading = true);
    
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
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCredit = _transactions.where((t) => t.type == 'credit').fold(0.0, (sum, t) => sum + t.amount);
    final totalDebit = _transactions.where((t) => t.type == 'debit').fold(0.0, (sum, t) => sum + t.amount);
    final netSavings = totalCredit - totalDebit;

    final pages = [
      _buildHomePage(totalCredit, totalDebit, netSavings),
      TransactionsPage(transactions: _transactions),
      DashboardPage(transactions: _transactions),
      CoachPage(transactions: _transactions),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Financier (Personal)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DebugPage()),
            ),
          ),
          IconButton(
            icon: _loading ? const CircularProgressIndicator() : const Icon(Icons.refresh),
            onPressed: _loading ? null : _importSms,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Coach'),
        ],
      ),
    );
  }

  Widget _buildHomePage(double totalCredit, double totalDebit, double netSavings) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Credit:', style: TextStyle(fontSize: 16)),
                      Text('₹${totalCredit.toStringAsFixed(2)}', 
                           style: const TextStyle(fontSize: 16, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Debit:', style: TextStyle(fontSize: 16)),
                      Text('₹${totalDebit.toStringAsFixed(2)}', 
                           style: const TextStyle(fontSize: 16, color: Colors.red)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Savings:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('₹${netSavings.toStringAsFixed(2)}', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, 
                                          color: netSavings >= 0 ? Colors.green : Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tip: Use Dashboard to see spending charts and Coach for AI-powered financial advice based on your transactions.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}