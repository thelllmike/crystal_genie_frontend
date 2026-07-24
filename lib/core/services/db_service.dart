import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/cart_item.dart';
import '../../models/crystal.dart';
import '../../models/find.dart';
import '../../models/product.dart';

/// All Supabase reads/writes the app does directly (everything except
/// YOLO detection, which goes through the FastAPI backend).
class DbService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ---------- Crystal library ----------

  /// Every crystal in the library, in name order.
  ///
  /// PostgREST caps how many rows one request may return (1000 by default), so
  /// this pages until the server runs out instead of silently truncating the
  /// library once the catalog grows past the cap.
  static Future<List<Crystal>> fetchCrystals() async {
    const pageSize = 1000;
    final all = <Crystal>[];
    var from = 0;
    while (true) {
      final rows = await _client
          .from('crystals')
          .select('name, headline, description, star_sign, chakras')
          .order('name', ascending: true)
          .range(from, from + pageSize - 1);
      if (rows.isEmpty) break;
      all.addAll(rows.map(Crystal.fromJson));
      from += rows.length;
    }
    return all;
  }

  /// Full details for one crystal by name (case-insensitive). Null if missing.
  static Future<Crystal?> fetchCrystalByName(String name) async {
    final row = await _client
        .from('crystals')
        .select('name, headline, description, star_sign, chakras')
        .ilike('name', name.trim())
        .limit(1)
        .maybeSingle();
    return row == null ? null : Crystal.fromJson(row);
  }

  // ---------- Finds (detection history) ----------

  static Future<void> addFind({
    required String crystalName,
    String headline = '',
  }) async {
    await _client.from('finds').insert({
      'crystal_name': crystalName,
      'headline': headline,
    });
  }

  static Future<List<Find>> recentFinds({int limit = 20}) async {
    final rows = await _client
        .from('finds')
        .select('crystal_name, headline, created_at')
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(Find.fromJson).toList();
  }

  // ---------- Saved crystals (bookmarks) ----------

  static Future<void> saveCrystal({
    required String crystalName,
    String headline = '',
  }) async {
    await _client.from('saved_crystals').upsert(
      {
        'user_id': _client.auth.currentUser!.id,
        'crystal_name': crystalName,
        'headline': headline,
      },
      onConflict: 'user_id, crystal_name',
    );
  }

  static Future<List<Find>> savedCrystals() async {
    final rows = await _client
        .from('saved_crystals')
        .select('crystal_name, headline, created_at')
        .order('created_at', ascending: false);
    return rows.map(Find.fromJson).toList();
  }

  // ---------- Admin ----------

  static Future<bool> isAdmin() async {
    try {
      final res = await _client.rpc('is_admin');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> addProduct({
    required String name,
    required double price,
    String headline = '',
    int stock = 0,
    String? imageUrl,
  }) async {
    await _client.from('products').insert({
      'name': name,
      'headline': headline,
      'price': price,
      'stock': stock,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    });
  }

  static Future<void> deleteProduct(int productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  // ---------- Shop ----------

  static Future<List<Product>> fetchProducts() async {
    final rows = await _client
        .from('products')
        .select('id, name, headline, price, image_url, stock')
        .order('name', ascending: true);
    return rows.map(Product.fromJson).toList();
  }

  static Future<List<CartItem>> fetchCart() async {
    final rows = await _client
        .from('cart_items')
        .select('id, quantity, products(id, name, headline, price, image_url, stock)')
        .order('created_at', ascending: true);
    return rows.map(CartItem.fromJson).toList();
  }

  static Future<void> addToCart(int productId) async {
    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('product_id', productId)
        .maybeSingle();
    if (existing == null) {
      await _client
          .from('cart_items')
          .insert({'product_id': productId, 'quantity': 1});
    } else {
      await _client
          .from('cart_items')
          .update({'quantity': (existing['quantity'] as num).toInt() + 1})
          .eq('id', existing['id'] as int);
    }
  }

  static Future<void> setCartQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _client
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    }
  }

  static Future<void> removeFromCart(int cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  /// Turns the cart into an order atomically (Postgres function) and
  /// returns the new order id.
  static Future<int> placeOrder() async {
    final res = await _client.rpc('place_order');
    return (res as num).toInt();
  }
}
