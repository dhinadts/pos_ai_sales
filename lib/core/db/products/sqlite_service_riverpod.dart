import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/models/product.dart';
import 'sqlite_service.dart';

final sqliteRepoProvider = Provider<ProductSqliteRepository>((ref) {
  return ProductSqliteRepository(ProductsSqfliteService());
});

class ProductSqliteRepository {
  final ProductsSqfliteService db;
  ProductSqliteRepository(this.db);

  Future<void> addProduct(Product p) async {
    await db.insertProduct(p.toSqliteMap());
  }

  Future<List<Product>> getProducts() async {
    final rows = await db.getProducts();
    // debugPrint("SQLITE rows: ${rows.length}");
    return rows.map((r) => Product.fromSqliteMap(r)).toList();
  }

  Future<Product?> getProduct(String id) async {
    final row = await db.getProductById(id);
    return row != null ? Product.fromSqliteMap(row) : null;
  }

  Future<void> updateProduct(Product p) async {
    await db.updateProduct(p.productId, p.toSqliteMap());
  }

  Future<void> deleteProduct(String id) async {
    await db.softDelete(id);
  }
}

final productListProvider = FutureProvider<List<Product>>((ref) async {
  return ref.read(sqliteRepoProvider).getProducts();
});

final productProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  return ref.read(sqliteRepoProvider).getProduct(id);
});
final addProductProvider = Provider((ref) {
  return (Product p) async {
    await ref.read(sqliteRepoProvider).addProduct(p);
  };
});

final updateProductProvider = Provider((ref) {
  return (Product p) async {
    await ref.read(sqliteRepoProvider).updateProduct(p);
  };
});

final deleteProductProvider = Provider((ref) {
  return (String id) async {
    await ref.read(sqliteRepoProvider).deleteProduct(id);
  };
});

final insertProductProvider = Provider((ref) {
  return (Map<String, dynamic> data) async {
    await ref.read(sqliteRepoProvider).db.insertProduct(data);
  };
});
