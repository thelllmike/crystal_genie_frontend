// Read-only rows for the admin dashboard (from the `admin_orders` and
// `admin_subscribers` Postgres functions).

class AdminOrderItem {
  final String name;
  final int quantity;
  final double unitPrice;

  AdminOrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> j) => AdminOrderItem(
        name: j['name'] as String? ?? '',
        quantity: (j['quantity'] as num?)?.toInt() ?? 0,
        unitPrice: (j['unit_price'] as num?)?.toDouble() ?? 0,
      );
}

class AdminOrder {
  final int id;
  final DateTime createdAt;
  final double total;
  final String status;
  final String email;
  final String shipName;
  final String shipPhone;
  final String shipAddress;
  final String shipCity;
  final String shipPostal;
  final List<AdminOrderItem> items;

  AdminOrder({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.status,
    required this.email,
    required this.shipName,
    required this.shipPhone,
    required this.shipAddress,
    required this.shipCity,
    required this.shipPostal,
    required this.items,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> j) => AdminOrder(
        id: (j['id'] as num).toInt(),
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        total: (j['total'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'pending',
        email: j['email'] as String? ?? '',
        shipName: j['ship_name'] as String? ?? '',
        shipPhone: j['ship_phone'] as String? ?? '',
        shipAddress: j['ship_address'] as String? ?? '',
        shipCity: j['ship_city'] as String? ?? '',
        shipPostal: j['ship_postal'] as String? ?? '',
        items: ((j['items'] as List?) ?? [])
            .map((e) => AdminOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AdminSubscriber {
  final String email;
  final DateTime signedUpAt;

  /// trialing | active | past_due | canceled
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  AdminSubscriber({
    required this.email,
    required this.signedUpAt,
    required this.status,
    required this.trialEndsAt,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
  });

  bool get isPaying => status == 'active' || status == 'past_due';

  bool get isTrialActive =>
      status == 'trialing' &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  factory AdminSubscriber.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) =>
        v is String ? DateTime.tryParse(v)?.toLocal() : null;
    return AdminSubscriber(
      email: j['email'] as String? ?? '',
      signedUpAt: parse(j['signed_up_at']) ?? DateTime.now(),
      status: j['status'] as String? ?? 'trialing',
      trialEndsAt: parse(j['trial_ends_at']),
      currentPeriodEnd: parse(j['current_period_end']),
      cancelAtPeriodEnd: j['cancel_at_period_end'] as bool? ?? false,
    );
  }
}
