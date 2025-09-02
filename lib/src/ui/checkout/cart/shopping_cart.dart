import 'package:app/src/models/cart/cart_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app/src/functions.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/models/errors/error.dart';
import 'package:app/src/resources/api_provider.dart';
import 'package:app/src/ui/accounts/login/login.dart';

class ShoppingCart with ChangeNotifier {
  ShoppingCart() {
    getCartWithCookies();
  }

  CartModel cart = CartModel.fromJson({});
  AppStateModel appStateModel = AppStateModel();
  int count = 0;
  bool isCartLoading = false;
  final ApiProvider apiProvider = ApiProvider();

  /// Adds a product to the cart.
  Future<bool> addToCart(BuildContext context, {
    int? productId,
    int? variationId,
    int? groupedProductId,
  }) async {
    final Map<String, dynamic> data = {};

    if (variationId != null) {
      data['variation_id'] = variationId.toString();
    }
    if (groupedProductId != null) {
      data['quantity[$groupedProductId]'] = '1';
    } else {
      data['quantity'] = '1';
    }

    if (productId != null) {
      data['product_id'] = productId.toString();
    }

    if (appStateModel.blocks.settings.loginBeforeAddToCart && (appStateModel.user.id == 0)) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
      return false;
    } else {
      final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=build-app-online-add_product_to_cart',
        data,
      );

      if (response.statusCode == 200) {
        cart = CartModel.fromJson(json.decode(response.body));
        updateCartCount();
        return true;
      } else {
        Notice notice = noticeFromJson(response.body);
        showSnackBarError(context, parseHtmlString(notice.data[0].notice));
        return false;
      }
    }
  }

  /// Retrieves the cart using cookies.
  Future<void> getCartWithCookies() async {
    final response = await apiProvider.postWithCookies(
      '/wp-admin/admin-ajax.php?action=build-app-online-cart',
      {},
    );
    isCartLoading = false;
    notifyListeners();
    if (response.statusCode == 200) {
      cart = CartModel.fromJson(json.decode(response.body));
      updateCartCount();
    } else {
      throw Exception('Failed to load cart');
    }
  }

  /// Retrieves the cart without using cookies.
  Future<void> getCart() async {
    final response = await apiProvider.post(
      '/wp-admin/admin-ajax.php?action=build-app-online-cart',
      {},
    );
    isCartLoading = false;
    notifyListeners();
    if (response.statusCode == 200) {
      cart = CartModel.fromJson(json.decode(response.body));
      updateCartCount();
    } else {
      throw Exception('Failed to load cart');
    }
  }

  /// Updates the total count of items in the cart.
  void updateCartCount() {
    count = cart.cartContents.fold(0, (sum, item) => sum + item.quantity);
    isCartLoading = false;
    notifyListeners();
  }

  /// Applies a coupon code to the cart.
  Future<void> applyCoupon(String couponCode, BuildContext context) async {
    final response = await apiProvider.post(
      '/wp-admin/admin-ajax.php?action=build-app-online-apply_coupon',
      {"coupon_code": couponCode},
    );

    if (response.statusCode == 200) {
      await getCart();
      showSnackBarSuccess(context, parseHtmlString(jsonDecode(response.body)));
    } else if (response.statusCode == 400) {
      showSnackBarError(context, parseHtmlString(jsonDecode(response.body)));
    } else {
      throw Exception('Failed to apply coupon');
    }
  }

  /// Redeems reward points for a discount.
  Future<void> redeemRewardPoints(BuildContext context) async {
    final response = await apiProvider.post(
      '/cart/',
      {
        "wc_points_rewards_apply_discount_amount": '',
        'wc_points_rewards_apply_discount': 'Apply Discount'
      },
    );

    if (response.statusCode == 200) {
      await getCart();
      showSnackBarSuccess(context, 'Discount Applied Successfully');
    } else {
      throw Exception('Failed to redeem reward points');
    }
  }

  /// Increases the quantity of a specific product in the cart.
  Future<bool> increaseQty(BuildContext context, int productId, {int? variationId}) async {
    CartContent? cartContent = _findCartContent(productId, variationId);
    if (cartContent != null) {
      if (cartContent.managingStock && cartContent.stockQuantity <= cartContent.quantity) {
        showSnackBarError(
          context,
          'You cannot add that amount to the cart — we have ${cartContent.stockQuantity} in stock and you already have ${cartContent.quantity} in your cart.',
        );
      } else {
        final Map<String, String> formData = {
          'cart[${cartContent.key}][qty]': (cartContent.quantity + 1).toString(),
          'quantity': (cartContent.quantity + 1).toString(),
          'key': cartContent.key,
          '_wpnonce': cart.cartNonce,
        };

        final response = await apiProvider.post(
          '/wp-admin/admin-ajax.php?action=build-app-online-update-cart-item-qty',
          formData,
        );

        if (response.statusCode == 200) {
          cart = CartModel.fromJson(json.decode(response.body));
          updateCartCount();
        } else {
          throw Exception('Failed to update cart quantity');
        }
      }
    }
    return true;
  }

  /// Decreases the quantity of a specific product in the cart.
  Future<bool> decreaseQty(BuildContext context, int productId, {int? variationId}) async {
    CartContent? cartContent = _findCartContent(productId, variationId);
    if (cartContent != null) {
      int newQty = cartContent.quantity - 1;
      if (newQty <= 0) {
        await removeItemFromCart(cartContent.key);
      } else {
        final Map<String, String> formData = {
          'cart[${cartContent.key}][qty]': newQty.toString(),
          'quantity': newQty.toString(),
          'key': cartContent.key,
          '_wpnonce': cart.cartNonce,
        };

        final response = await apiProvider.post(
          '/wp-admin/admin-ajax.php?action=build-app-online-update-cart-item-qty',
          formData,
        );

        if (response.statusCode == 200) {
          cart = CartModel.fromJson(json.decode(response.body));
          updateCartCount();
        } else {
          throw Exception('Failed to update cart quantity');
        }
      }
    }
    return true;
  }

  /// Updates the quantity of a specific product in the cart.
  Future<bool> updateCartQty(
      BuildContext context,
      int qty, {
        CartContent? cartContent,
        int? productId,
        int? variationId,
      }) async {
    if (cart.cartContents.isEmpty) return false;

    cartContent ??= _findCartContent(productId!, variationId);
    if (cartContent == null) return false;

    if (qty <= 0) {
      await removeItemFromCart(cartContent.key);
    } else {
      final Map<String, String> formData = {
        'cart[${cartContent.key}][qty]': qty.toString(),
        'quantity': qty.toString(),
        'key': cartContent.key,
        '_wpnonce': cart.cartNonce,
      };

      final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=build-app-online-update-cart-item-qty',
        formData,
      );

      if (response.statusCode == 200) {
        cart = CartModel.fromJson(json.decode(response.body));
        updateCartCount();
      } else {
        throw Exception('Failed to update cart quantity');
      }
    }

    return true;
  }

  /// Removes a specific item from the cart.
  Future<bool> removeItemFromCart(String key) async {
    cart.cartContents.removeWhere((item) => item.key == key);
    notifyListeners();

    final response = await apiProvider.post(
      '/wp-admin/admin-ajax.php?action=build-app-online-remove_cart_item&item_key=$key',
      {},
    );

    if (response.statusCode == 200) {
      cart = CartModel.fromJson(json.decode(response.body));
      updateCartCount();
    } else {
      throw Exception('Failed to remove item from cart');
    }

    return true;
  }

  /// Removes a coupon from the cart.
  Future<void> removeCoupon(String code) async {
    final Map<String, String> data = {'coupon': code};
    cart.coupons.removeWhere((element) => element.code == code);
    notifyListeners();
    await apiProvider.post(
      '/wp-admin/admin-ajax.php?action=build-app-online-remove_coupon',
      data,
    );
    await getCart();
  }

  /// Clears the entire cart.
  Future<void> clearCart() async {
    cart = CartModel.fromJson({});
    notifyListeners();
    final response = await apiProvider.get(
      '/wp-admin/admin-ajax.php?action=build-app-online-emptyCart',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }

  /// Adds a product to the cart with custom data.
  Future<bool> addToCartWithData(Map<String, dynamic> data, BuildContext context) async {
    if (appStateModel.blocks.settings.loginBeforeAddToCart && (appStateModel.user.id == 0)) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
      return false;
    } else {
      final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=build-app-online-add_product_to_cart',
        data,
      );

      if (response.statusCode == 200) {
        cart = CartModel.fromJson(json.decode(response.body));
        updateCartCount();
        return true;
      } else {
        Notice notice = noticeFromJson(response.body);
        showSnackBarError(context, parseHtmlString(notice.data[0].notice));
        return false;
      }
    }
  }

  /// Retrieves the cart after adding a balance to the cart.
  Future<bool> getCartAfterAddingBalanceToCart() async {
    final response = await apiProvider.post(
      '/wp-admin/admin-ajax.php?action=build-app-online-cart',
      {},
    );
    notifyListeners();
    if (response.statusCode == 200) {
      cart = CartModel.fromJson(json.decode(response.body));
      updateCartCount();
      return true;
    } else {
      throw Exception('Failed to load cart');
    }
  }

  /// Gets the current quantity of a specific product (and variation) in the cart.
  int getQuantity(int productId, int? variationId) {
    if (cart.cartContents.isEmpty) return 0;

    if (variationId != null) {
      return cart.cartContents
          .where((item) => item.productId == productId && item.variationId == variationId)
          .fold(0, (sum, item) => sum + item.quantity);
    } else {
      return cart.cartContents
          .where((item) => item.productId == productId)
          .fold(0, (sum, item) => sum + item.quantity);
    }
  }

  /// Finds a cart content based on product and variation IDs.
  CartContent? _findCartContent(int productId, int? variationId) {
    if (cart.cartContents.isEmpty) return null;

    Iterable<CartContent> filteredContents;

    if (variationId != null) {
      filteredContents = cart.cartContents.where(
            (item) => item.productId == productId && item.variationId == variationId,
      );
    } else {
      filteredContents = cart.cartContents.where(
            (item) => item.productId == productId,
      );
    }

    return filteredContents.isNotEmpty ? filteredContents.first : null;
  }

}
