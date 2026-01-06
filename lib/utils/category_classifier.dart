/// Utility class for categorizing transactions based on SMS content and merchant names
class CategoryClassifier {
  /// Determines transaction category based on SMS body and merchant name
  static String classify(String smsBody, String? merchantName) {
    final bodyLower = smsBody.toLowerCase();
    final merchantLower = merchantName?.toLowerCase() ?? '';
    
    // Food category
    if (bodyLower.contains(RegExp(r'swiggy|zomato|restaurant|food|dominos|kfc|mcdonalds|pizza|burger')) ||
        merchantLower.contains(RegExp(r'swiggy|zomato|restaurant|food|dominos|kfc|mcdonalds'))) {
      return 'Food';
    }
    
    // Shopping category
    if (bodyLower.contains(RegExp(r'amazon|flipkart|myntra|ajio|shopping|mall|snapdeal')) ||
        merchantLower.contains(RegExp(r'amazon|flipkart|myntra|ajio|shopping'))) {
      return 'Shopping';
    }
    
    // Fuel category
    if (bodyLower.contains(RegExp(r'fuel|petrol|hpcl|bpcl|iocl|diesel|gas station')) ||
        merchantLower.contains(RegExp(r'fuel|petrol|hpcl|bpcl|iocl'))) {
      return 'Fuel';
    }
    
    // Rent category
    if (bodyLower.contains('rent') || merchantLower.contains('rent')) {
      return 'Rent';
    }
    
    // Bills category
    if (bodyLower.contains(RegExp(r'bill|postpaid|prepaid|electricity|mobile|dth|recharge|airtel|jio|vodafone')) ||
        merchantLower.contains(RegExp(r'bill|electricity|mobile|dth'))) {
      return 'Bills';
    }
    
    // Default category
    return 'Other';
  }
}
