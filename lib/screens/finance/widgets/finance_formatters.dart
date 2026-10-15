class FinanceFormatters {
  /// Format double into Indian Currency with Lakhs (L) and Crores (Cr)
  static String formatInr(double amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(cr >= 10 ? 1 : 2)} Cr';
    } else if (amount >= 100000) {
      final l = amount / 100000;
      return '₹${l.toStringAsFixed(l >= 10 ? 1 : 2)} L';
    } else {
      return formatFullInr(amount);
    }
  }

  /// Format double into full comma-separated Indian numbering: ₹1,84,200
  static String formatFullInr(double amount) {
    final str = amount.toStringAsFixed(0);
    return '₹${formatIndianNumber(str)}';
  }

  /// Indian number system comma separator (3 digits on right, then 2 digits)
  static String formatIndianNumber(String s) {
    if (s.length <= 3) return s;
    final lastThree = s.substring(s.length - 3);
    var remaining = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (remaining.length > 2) {
      parts.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) parts.insert(0, remaining);
    return '${parts.join(',')},$lastThree';
  }
}
