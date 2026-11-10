import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/services/db_service.dart';
import '../../models/admin.dart';
import '../../models/crystal.dart';
import '../../models/product.dart';
import '../widgets/cg.dart';
import '../widgets/page_transitions.dart';

/// Admin-only dashboard: edit crystals and shop items, see orders (with
/// shipping addresses) and subscribers. Reached from the profile screen.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const _tabs = ['Orders', 'Subscribers', 'Shop', 'Crystals'];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glow: CG.mint,
      glowTop: -360,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const CGBack(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ADMIN DASHBOARD', style: CG.eyebrow()),
                        const SizedBox(height: 2),
                        Text(_tabs[_tab], style: CG.display(30).copyWith(height: 1.1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => CGChip(
                  _tabs[i],
                  selected: i == _tab,
                  onTap: () => setState(() => _tab = i),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  _OrdersTab(),
                  _SubscribersTab(),
                  _ShopTab(),
                  _CrystalsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

void _snack(BuildContext context, String message) => CG.snack(context, message);

String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

String _dateTime(DateTime d) =>
    '${_date(d)} ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

const _listPadding = EdgeInsets.fromLTRB(20, 2, 20, 110);

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
          return const CGLoading();
        }
        if (snap.hasError) {
          return RefreshIndicator(
            color: CG.brand,
            onRefresh: onRefresh,
            child: ListView(
              padding: _listPadding,
              children: [
                CGEmpty(
                  title: 'Could not load',
                  message: '${snap.error}\n\n'
                      'If this mentions admin_orders / admin_subscribers, run '
                      'backend/admin_dashboard.sql in the Supabase SQL editor.',
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: CG.brand,
          onRefresh: onRefresh,
          child: builder(snap.data as T),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final List<(String, String, Color)> stats;
  const _StatRow(this.stats);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, s) in stats.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: CGCard(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(s.$2, style: CG.display(26, color: s.$3).copyWith(height: 1.1)),
                  ),
                  Text(s.$1, style: CG.sub(12)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Fab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _Fab({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => Positioned(
        right: 20,
        bottom: 0,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Color(0x595ED3CB), blurRadius: 28, offset: Offset(0, 8)),
              ],
            ),
            child: Material(
              color: CG.brand,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(HugeIcons.strokeRoundedPlusSign, color: CG.onBrand, size: 22),
                        const SizedBox(width: 8),
                        Text(label, style: CG.body(16, color: CG.onBrand, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

Widget _sectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text.toUpperCase(), style: CG.eyebrow(color: CG.tx3).copyWith(fontSize: 10.5)),
    );

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
    setState(() { _orders = next; });
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _listPadding,
          children: [
            _StatRow([
              ('Orders', '${orders.length}', CG.tx),
              ('To ship', '$toShip', CG.warn),
              ('Revenue', '\$${revenue.toStringAsFixed(2)}', CG.brand),
            ]),
            const SizedBox(height: 14),
            if (orders.isEmpty)
              const CGEmpty(title: 'No orders yet', message: 'New shop orders will show up here.'),
            for (final o in orders) ...[
              _OrderCard(order: o, onSetStatus: (s) => _setStatus(o, s)),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatefulWidget {
  final AdminOrder order;
  final ValueChanged<String> onSetStatus;

  const _OrderCard({required this.order, required this.onSetStatus});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  late bool _open = widget.order.status == 'pending';

  AdminOrder get order => widget.order;

  String get _address => [
        order.shipName,
        order.shipAddress,
        [order.shipCity, order.shipPostal].where((s) => s.isNotEmpty).join(' '),
        order.shipPhone,
      ].where((s) => s.trim().isNotEmpty).join('\n');

  @override
  Widget build(BuildContext context) {
    final shipped = order.status == 'shipped';
    return CGCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('#${order.id}', style: CG.display(20)),
                            const SizedBox(width: 10),
                            CGStatus(
                              shipped ? 'Shipped' : 'Pending',
                              color: shipped ? CG.ok : CG.warn,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.shipName.isNotEmpty ? order.shipName : order.email}'
                          ' · ${_dateTime(order.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CG.sub(13),
                        ),
                      ],
                    ),
                  ),
                  Text('\$${order.total.toStringAsFixed(2)}',
                      style: CG.body(17, weight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _open ? .5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(HugeIcons.strokeRoundedArrowDown01, size: 18, color: CG.tx3),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CGLine(),
                        const SizedBox(height: 14),
                        _sectionLabel('Items'),
                        for (final i in order.items)
                          Text.rich(
                            TextSpan(
                              text: '${i.quantity} × ${i.name} ',
                              style: CG.body(14),
                              children: [
                                TextSpan(
                                  text: '(\$${(i.unitPrice * i.quantity).toStringAsFixed(2)})',
                                  style: CG.mute(14),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionLabel('Customer'),
                                  SelectableText(
                                    order.email.isEmpty ? '(no email)' : order.email,
                                    style: CG.body(13.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionLabel('Ship to'),
                                  SelectableText(
                                    _address.isEmpty ? '(no address given)' : _address,
                                    style: CG.body(13.5, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CGButton.ghost(
                                label: 'Copy address',
                                icon: HugeIcons.strokeRoundedCopy01,
                                small: true,
                                onPressed: _address.isEmpty
                                    ? null
                                    : () {
                                        Clipboard.setData(ClipboardData(text: _address));
                                        _snack(context, 'Address copied');
                                      },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CGButton(
                                label: shipped ? 'Mark pending' : 'Mark shipped',
                                small: true,
                                onPressed: () =>
                                    widget.onSetStatus(shipped ? 'pending' : 'shipped'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
    setState(() { _subs = next; });
    await next.catchError((_) => <AdminSubscriber>[]);
  }

  bool _matches(AdminSubscriber s) => switch (_filter) {
        _SubFilter.all => true,
        _SubFilter.paying => s.isPaying,
        _SubFilter.trial => s.isTrialActive,
        _SubFilter.expired => !s.isPaying && !s.isTrialActive,
      };

  static String _label(_SubFilter f) => switch (f) {
        _SubFilter.all => 'All',
        _SubFilter.paying => 'Paying',
        _SubFilter.trial => 'Trial',
        _SubFilter.expired => 'Ended',
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _listPadding,
          children: [
            _StatRow([
              ('Users', '${subs.length}', CG.tx),
              ('Paying', '$paying', CG.ok),
              ('On trial', '$trial', CG.info),
            ]),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in _SubFilter.values)
                  CGChip(
                    _label(f),
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (shown.isEmpty)
              const CGEmpty(title: 'Nobody here yet', message: 'Try another filter.'),
            for (final s in shown) ...[
              _SubscriberTile(sub: s),
              const SizedBox(height: 10),
            ],
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
      color = sub.status == 'past_due' ? CG.warn : CG.ok;
      final end = sub.currentPeriodEnd;
      detail = end == null ? '' : '${sub.cancelAtPeriodEnd ? 'Ends' : 'Renews'} ${_date(end)}';
    } else if (sub.isTrialActive) {
      label = 'Trial';
      color = CG.info;
      detail = 'Trial ends ${_date(sub.trialEndsAt!)}';
    } else {
      label = sub.status == 'canceled' ? 'Canceled' : 'Expired';
      color = CG.off;
      detail = '';
    }
    return CGCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  sub.email.isEmpty ? '(no email)' : sub.email,
                  style: CG.body(15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ['Joined ${_date(sub.signedUpAt)}', if (detail.isNotEmpty) detail].join(' · '),
                  style: CG.sub(12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CGStatus(label, color: color),
        ],
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
    setState(() { _products = next; });
    await next.catchError((_) => <Product>[]);
  }

  Future<void> _edit([Product? product]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x6B14262A),
      builder: (_) => _ProductDialog(product: product),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _Loader<List<Product>>(
            future: _products,
            onRefresh: _reload,
            builder: (products) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: _listPadding,
              children: [
                if (products.isEmpty)
                  const CGEmpty(title: 'No products yet', message: 'Add the first shop item.'),
                for (final p in products) ...[
                  CGCard(
                    onTap: () => _edit(p),
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                    child: Row(
                      children: [
                        CrystalThumb(
                          name: p.name,
                          imageUrl: p.imageUrl,
                          width: 52,
                          height: 52,
                          radius: 14,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: CG.display(18).copyWith(height: 1.15)),
                              Text(
                                '\$${p.price.toStringAsFixed(2)} · ${p.stock} in stock',
                                style: CG.sub(12.5).copyWith(color: p.stock <= 0 ? CG.danger : null),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(HugeIcons.strokeRoundedEdit02, size: 18, color: CG.tx2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        _Fab(label: 'Add item', onPressed: () => _edit()),
      ],
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
  late final _price = TextEditingController(text: widget.product?.price.toStringAsFixed(2));
  late final _stock = TextEditingController(text: '${widget.product?.stock ?? 10}');
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
    final confirmed = await showCGConfirm(
      context,
      title: 'Delete ${p.name}?',
      message: 'This removes the product from the shop and from all carts.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: HugeIcons.strokeRoundedDelete02,
    );
    if (!confirmed || !mounted) return;
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
    return CGDialog(
      title: _isNew ? 'Add shop item' : 'Edit shop item',
      body: Column(
        children: [
          CGField(label: 'Name', controller: _name, small: true),
          const SizedBox(height: 12),
          CGField(label: 'Headline (optional)', controller: _headline, small: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CGField(
                  label: 'Price (\$)',
                  controller: _price,
                  small: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CGField(
                  label: 'Stock',
                  controller: _stock,
                  small: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CGField(label: 'Image URL (optional)', controller: _imageUrl, small: true),
        ],
      ),
      actions: [
        CGButton(label: _isNew ? 'Add' : 'Save', loading: _busy, onPressed: _save),
        CGButton.ghost(
          label: 'Cancel',
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
        if (!_isNew)
          CGButton(
            label: 'Delete item',
            kind: CGButtonKind.danger,
            onPressed: _busy ? null : _delete,
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
    setState(() { _crystals = next; });
    await next.catchError((_) => <Crystal>[]);
  }

  Future<void> _edit([Crystal? crystal]) async {
    final saved = await Navigator.of(context).push<bool>(
      SmoothPageRoute(
        transition: SmoothTransition.slide,
        builder: (_) => _CrystalEditor(crystal: crystal),
      ),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                child: CGSearch(
                  hint: 'Search crystals',
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
                        : crystals.where((c) => c.name.toLowerCase().contains(_query)).toList();
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: _listPadding,
                      itemCount: shown.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final c = shown[i];
                        return CGCard(
                          onTap: () => _edit(c),
                          padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                          child: Row(
                            children: [
                              GemTile(
                                color: CG.crystalColor(c.name),
                                width: 52,
                                height: 52,
                                radius: 14,
                                gemWidth: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: CG.display(18).copyWith(height: 1.15)),
                                    Text(
                                      c.headline.isEmpty ? 'No headline yet' : c.headline,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: c.headline.isEmpty
                                          ? CG.body(12.5, color: CG.warn)
                                          : CG.sub(12.5),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(HugeIcons.strokeRoundedEdit02, size: 18, color: CG.tx2),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        _Fab(label: 'Add crystal', onPressed: () => _edit()),
      ],
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
  late final _description = TextEditingController(text: widget.crystal?.description);
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
    final confirmed = await showCGConfirm(
      context,
      title: 'Delete $name?',
      message: 'Scans that detect this crystal will no longer show its details.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: HugeIcons.strokeRoundedDelete02,
    );
    if (!confirmed || !mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final title = _isNew ? 'Add crystal' : widget.crystal!.name;
    return CGPage(
      glow: _isNew ? CG.mint : CG.crystalColor(title),
      glowTop: -340,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const CGBack(),
                  const Spacer(),
                  if (!_isNew)
                    CGIconButton(
                      icon: HugeIcons.strokeRoundedDelete02,
                      tooltip: 'Delete',
                      foreground: CG.danger,
                      onTap: _busy ? null : _delete,
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  CGHeading(eyebrow: 'Admin · Crystals', title: title, size: 32),
                  const SizedBox(height: 22),
                  // The name is how scans find the crystal, so it's fixed once created.
                  CGField(
                    label: 'Name',
                    controller: _name,
                    enabled: _isNew,
                    helper: _isNew ? "Must match the scanner's class name for scans to find it." : null,
                  ),
                  const SizedBox(height: 16),
                  CGField(label: 'Headline', controller: _headline),
                  const SizedBox(height: 16),
                  CGField(label: 'Description', controller: _description, maxLines: 20),
                  const SizedBox(height: 16),
                  CGField(label: 'Star sign', controller: _starSign),
                  const SizedBox(height: 16),
                  CGField(label: 'Chakras', controller: _chakras, hint: 'e.g. Crown, Third Eye'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CGButton(label: 'Save', loading: _busy, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}
