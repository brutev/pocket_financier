/// Banking SMS parsing constants used across the application
class BankingConstants {
  /// List of verified bank sender IDs for SMS parsing
  static const bankSenders = {
    'HDFCBK', 'SBIINB', 'ICICIB', 'AXISBK', 'PNBSMS', 'SCBANK', 'CITIBK',
    'KOTAK', 'YESBNK', 'BOIIND', 'INDBNK', 'UNIONB', 'CANBKS', 'MAHABK',
    'FEDBK', 'IDBIBK', 'UCOBKS', 'PSBANK'
  };

  /// Keywords that indicate spam or promotional messages
  static const spamKeywords = [
    // URLs and links
    'http://', 'https://', 'bit.ly', 'tinyurl', 'www.', '.com/', '.in/', '.co/',
    // Promotional terms
    'click here', 'claim now', 'verify now', 'update kyc', 'congratulations',
    'won', 'prize', 'lottery', 'reward', 'bonus', 'welcome bonus', 'free cash',
    'loan approved', 'instant loan', 'pre-approved', 'pre approved', 
    'limited time', 'expire', 'suspended', 'blocked', 'call immediately', 
    'urgent action', 'act now', 'join today', 'sign up', 'complete kyc',
    // Wallet/App promotions
    'wallet', 'app download', 'install app', 'download now', 'get app',
    'easy payments', 'secure payments', 'extra savings', 'use it for',
    // Loan/Credit offers
    'emi from', 'ready to be credited', 'up to rs', 'just complete',
    '2-min kyc', 'finven', 'finplo',
    // Generic spam indicators
    'otp', 'dear customer'
  ];

  /// Regex patterns that indicate spam or promotional messages
  static const spamPatterns = [
    // Bonus/promotional patterns
    r'rs\.?\s*\d+\s*welcome\s*bonus',
    r'rs\.?\s*\d+\s*free\s*cash',
    r'up\s*to\s*rs\.?\s*\d+.*credited',
    r'emi\s*from\s*rs\.?\s*\d+',
    // URL patterns
    r'https?://[^\s]+',
    r'[a-z]+\.[a-z]{2,3}/[^\s]*',
    // App/wallet patterns
    r'sign\s*up\s*for.*wallet',
    r'use\s*it\s*for.*savings',
  ];

  /// Keywords that indicate credit transactions
  static const creditKeywords = ['credited', 'deposited', 'received', 'added', 'cr', 'credit'];
  
  /// Keywords that indicate debit transactions
  static const debitKeywords = ['debited', 'withdrawn', 'paid', 'deducted', 'dr', 'debit', 'spent', 'purchase'];
  
  /// Supported transaction modes
  static const transactionModes = ['NEFT', 'IMPS', 'UPI', 'RTGS', 'ATM', 'POS', 'DEBIT CARD', 'CREDIT CARD', 'NETBANKING', 'CHEQUE', 'CASH', 'MOBILE BANKING'];
}
