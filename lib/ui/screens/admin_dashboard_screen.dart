import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/colors.dart';
import '../../core/services/db_service.dart';
import '../../models/admin.dart';
import '../../models/crystal.dart';
import '../../models/product.dart';

/// Admin-only dashboard: edit crystals and shop items, see orders (with
/// shipping addresses) and subscribers. Reached from the profile screen.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.neutral20,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Admin dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xCCFFFFFF),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Orders'),
              Tab(text: 'Subscribers'),
              Tab(text: 'Shop'),
              Tab(text: 'Crystals'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrdersTab(),
            _SubscribersTab(),
            _ShopTab(),
            _CrystalsTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

String _date(DateTime d) =>
    '${d.day}/${d.month}/${d.year}';

String _dateTime(DateTime d) =>
    '${_date(d)} ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

/// FutureBuilder with loading / error / pull-to-refresh handled.
class _Loader<T> extends StatelessWidget {
  final Future<T> future;
  final Future<void> Function() onRefresh;
  final Widget Function(T data) builder;

  const _Loader({
    required this.future,
    required this.onRefresh,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Could not load:\n${snap.error}\n\n'
                  'If this mentions admin_orders / admin_subscribers, run '
                  'backend/admin_dashboard.sql in the Supabase SQL editor.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: builder(snap.data as T),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary40,
                ),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.neutral60)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Orders
// ---------------------------------------------------------------------------

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  late Future<List<AdminOrder>> _orders = DbService.adminOrders();

  Future<void> _reload() async {
    final next = DbService.adminOrders();
    setState(() => _orders = next);
    await next.catchError((_) => <AdminOrder>[]);
  }

  Future<void> _setStatus(AdminOrder order, String status) async {
    try {
      await DbService.setOrderStatus(order.id, status);
      if (!mounted) return;
      _snack(context, 'Order #${order.id} marked $status');
      _reload();
    } catch (e) {
      if (mounted) _snack(context, 'Could not update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Loader<List<AdminOrder>>(
      future: _orders,
      onRefresh: _reload,
      builder: (orders) {
        final revenue = orders.fold<double>(0, (sum, o) => sum + o.total);
        final toShip = orders.where((o) => o.status == 'pending').length;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                _StatBox('Orders', '${orders.length}'),
                _StatBox('To ship', '$toShip'),
                _StatBox('Revenue', '\$${revenue.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No orders yet')),
              ),
            for (final o in orders)
              _OrderCard(order: o, onSetStatus: (s) => _setStatus(o, s)),
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AdminOrder order;
  final ValueChanged<String> onSetStatus;

  const _OrderCard({required this.order, required this.onSetStatus});

  String get _address => [
        order.shipName,
        order.shipAddress,
        [order.shipCity, order.shipPostal].where((s) => s.isNotEmpty).join(' '),
        order.shipPhone,
      ].where((s) => s.trim().isNotEmpty).join('\n');

  @override
  Widget build(BuildContext context) {
    final shipped = order.status == 'shipped';
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        shape: const Border(),
        title: Row(
          children: [
            Text('#${order.id}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            _Pill(order.status,
                shipped ? AppColors.success20 : AppColors.warning20),
            const Spacer(),
            Text('\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.primary40)),
          ],
        ),
        subtitle: Text(
          '${order.shipName.isNotEmpty ? order.shipName : order.email}'
          ' · ${_dateTime(order.createdAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          for (final i in order.items)
            Text('${i.quantity} × ${i.name}  '
                '(\$${(i.unitPrice * i.quantity).toStringAsFixed(2)})'),
          const SizedBox(height: 12),
          const Text('Customer', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          SelectableText(order.email.isEmpty ? '(no email)' : order.email),
          const SizedBox(height: 12),
          const Text('Ship to', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          SelectableText(_address.isEmpty ? '(no address given)' : _address),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _address.isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: _address));
                        _snack(context, 'Address copied');
                      },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy address'),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: () => onSetStatus(shipped ? 'pending' : 'shipped'),
                child: Text(shipped ? 'Mark pending' : 'Mark shipped'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subscribers
// ---------------------------------------------------------------------------

enum _SubFilter { all, paying, trial, expired }

class _SubscribersTab extends StatefulWidget {
  const _SubscribersTab();

  @override
  State<_SubscribersTab> createState() => _SubscribersTabState();
}

class _SubscribersTabState extends State<_SubscribersTab> {
  late Future<List<AdminSubscriber>> _subs = DbService.adminSubscribers();
  _SubFilter _filter = _SubFilter.paying;

  Future<void> _reload() async {
    final next = DbService.adminSubscribers();
    setState(() => _subs = next);
    await next.catchError((_) => <AdminSubscriber>[]);
  }

  bool _matches(AdminSubscriber s) => switch (_filter) {
        _SubFilter.all => true,
        _SubFilter.paying => s.isPaying,
        _SubFilter.trial => s.isTrialActive,
        _SubFilter.expired => !s.isPaying && !s.isTrialActive,
      };

  @override
  Widget build(BuildContext context) {
    return _Loader<List<AdminSubscriber>>(
      future: _subs,
      onRefresh: _reload,
      builder: (subs) {
        final paying = subs.where((s) => s.isPaying).length;
        final trial = subs.where((s) => s.isTrialActive).length;
        final shown = subs.where(_matches).toList();
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                _StatBox('Users', '${subs.length}'),
                _StatBox('Paying', '$paying'),
                _StatBox('On trial', '$trial'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final f in _SubFilter.values)
                  ChoiceChip(
                    label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (shown.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Nobody here yet')),
              ),
            for (final s in shown) _SubscriberTile(sub: s),
          ],
        );
      },
    );
  }
}

class _SubscriberTile extends StatelessWidget {
  final AdminSubscriber sub;

  const _SubscriberTile({required this.sub});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    final String detail;
    if (sub.isPaying) {
      label = sub.status == 'past_due' ? 'Past due' : 'Paying';
      color = sub.status == 'past_due' ? AppColors.warning20 : AppColors.success20;
      final end = sub.currentPeriodEnd;
      detail = end == null
          ? ''
          : '${sub.cancelAtPeriodEnd ? 'Ends' : 'Renews'} ${_date(end)}';
    } else if (sub.isTrialActive) {
      label = 'Trial';
      color = AppColors.info20;
      detail = 'Trial ends ${_date(sub.trialEndsAt!)}';
    } else {
      label = sub.status == 'canceled' ? 'Canceled' : 'Expired';
      color = AppColors.neutral60;
      detail = '';
    }
    return Card(
      color: Colors.white,
      child: ListTile(
        title: SelectableText(sub.email.isEmpty ? '(no email)' : sub.email),
        subtitle: Text([
          'Joined ${_date(sub.signedUpAt)}',
          if (detail.isNotEmpty) detail,
        ].join(' · ')),
        trailing: _Pill(label, color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shop
// ---------------------------------------------------------------------------

class _ShopTab extends StatefulWidget {
  const _ShopTab();

  @override
  State<_ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<_ShopTab> {
  late Future<List<Product>> _products = DbService.fetchProducts();

  Future<void> _reload() async {
    final next = DbService.fetchProducts();
    setState(() => _products = next);
    await next.catchError((_) => <Product>[]);
  }

  Future<void> _edit([Product? product]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ProductDialog(product: product),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: _Loader<List<Product>>(
        future: _products,
        onRefresh: _reload,
        builder: (products) => ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          children: [
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No products yet')),
              ),
            for (final p in products)
              Card(
                color: Colors.white,
                child: ListTile(
                  onTap: () => _edit(p),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                          ? Image.network(p.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/item.png',
                                  fit: BoxFit.cover))
                          : Image.asset('assets/images/item.png',
                              fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(p.name),
                  subtitle: Text(
                      '\$${p.price.toStringAsFixed(2)} · ${p.stock} in stock'),
                  trailing: const Icon(Icons.edit_outlined),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;

  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final _name = TextEditingController(text: widget.product?.name);
  late final _headline = TextEditingController(text: widget.product?.headline);
  late final _price = TextEditingController(
      text: widget.product?.price.toStringAsFixed(2));
  late final _stock =
      TextEditingController(text: '${widget.product?.stock ?? 10}');
  late final _imageUrl = TextEditingController(text: widget.product?.imageUrl);
  bool _busy = false;

  bool get _isNew => widget.product == null;

  Future<void> _save() async {
    final price = double.tryParse(_price.text.trim());
    if (_name.text.trim().isEmpty || price == null) {
      _snack(context, 'Name and a valid price are required');
      return;
    }
    setState(() => _busy = true);
    try {
      if (_isNew) {
        await DbService.addProduct(
          name: _name.text.trim(),
          headline: _headline.text.trim(),
          price: price,
          stock: int.tryParse(_stock.text.trim()) ?? 0,
          imageUrl: _imageUrl.text.trim(),
        );
      } else {
        await DbService.updateProduct(
          widget.product!.id,
          name: _name.text.trim(),
          headline: _headline.text.trim(),
          price: price,
          stock: int.tryParse(_stock.text.trim()) ?? 0,
          imageUrl: _imageUrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(context, 'Could not save: $e');
      }
    }
  }

  Future<void> _delete() async {
    final p = widget.product!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${p.name}?'),
        content: const Text(
            'This removes the product from the shop and from all carts.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await DbService.deleteProduct(p.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(context, 'Could not delete: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isNew ? 'Add shop item' : 'Edit shop item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: _headline,
                decoration:
                    const InputDecoration(labelText: 'Headline (optional)')),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price (\$)'),
            ),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock'),
            ),
            TextField(
                controller: _imageUrl,
                decoration:
                    const InputDecoration(labelText: 'Image URL (optional)')),
          ],
        ),
      ),
      actions: [
        if (!_isNew)
          TextButton(
            onPressed: _busy ? null : _delete,
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _save,
          child: Text(_isNew ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Crystals
// ---------------------------------------------------------------------------

class _CrystalsTab extends StatefulWidget {
  const _CrystalsTab();

  @override
  State<_CrystalsTab> createState() => _CrystalsTabState();
}

class _CrystalsTabState extends State<_CrystalsTab> {
  late Future<List<Crystal>> _crystals = DbService.fetchCrystals();
  String _query = '';

  Future<void> _reload() async {
    final next = DbService.fetchCrystals();
    setState(() => _crystals = next);
    await next.catchError((_) => <Crystal>[]);
  }

  Future<void> _edit([Crystal? crystal]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _CrystalEditor(crystal: crystal),
      ),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Add crystal'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search crystals',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: _Loader<List<Crystal>>(
              future: _crystals,
              onRefresh: _reload,
              builder: (crystals) {
                final shown = _query.isEmpty
                    ? crystals
                    : crystals
                        .where((c) => c.name.toLowerCase().contains(_query))
                        .toList();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final c = shown[i];
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        onTap: () => _edit(c),
                        title: Text(c.name),
                        subtitle: Text(
                          c.headline.isEmpty ? '(no headline)' : c.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.edit_outlined),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CrystalEditor extends StatefulWidget {
  final Crystal? crystal;

  const _CrystalEditor({this.crystal});

  @override
  State<_CrystalEditor> createState() => _CrystalEditorState();
}

class _CrystalEditorState extends State<_CrystalEditor> {
  late final _name = TextEditingController(text: widget.crystal?.name);
  late final _headline = TextEditingController(text: widget.crystal?.headline);
  late final _description =
      TextEditingController(text: widget.crystal?.description);
  late final _starSign = TextEditingController(text: widget.crystal?.starSign);
  late final _chakras = TextEditingController(text: widget.crystal?.chakras);
  bool _busy = false;

  bool get _isNew => widget.crystal == null;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _snack(context, 'Name is required');
      return;
    }
    setState(() => _busy = true);
    try {
      await DbService.saveCrystalInfo(Crystal(
        name: _name.text.trim(),
        headline: _headline.text.trim(),
        description: _description.text.trim(),
        starSign: _starSign.text.trim(),
        chakras: _chakras.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(context, 'Could not save: $e');
      }
    }
  }

  Future<void> _delete() async {
    final name = widget.crystal!.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $name?'),
        content: const Text(
            'Scans that detect this crystal will no longer show its details.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await DbService.deleteCrystal(name);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(context, 'Could not delete: $e');
      }
    }
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, bool enabled = true, String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        enabled: enabled,
        minLines: maxLines > 1 ? 4 : 1,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral20,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_isNew ? 'Add crystal' : widget.crystal!.name),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Delete',
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            onPressed: _busy ? null : _save,
            child: const Text('Save',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // The name is how scans find the crystal, so it's fixed once created.
          _field(_name, 'Name',
              enabled: _isNew,
              helper: _isNew
                  ? 'Must match the scanner\'s class name for scans to find it.'
                  : null),
          _field(_headline, 'Headline'),
          _field(_description, 'Description', maxLines: 20),
          _field(_starSign, 'Star sign'),
          _field(_chakras, 'Chakras'),
        ],
      ),
    );
  }
}
