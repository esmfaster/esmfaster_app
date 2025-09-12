import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final List<Order> _orders = [
    Order(
      id: '#12345',
      status: OrderStatus.delivered,
      items: ['Wireless Headphones', 'Phone Case'],
      total: 119.98,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Order(
      id: '#12344',
      status: OrderStatus.inTransit,
      items: ['Smart Watch'],
      total: 199.99,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Order(
      id: '#12343',
      status: OrderStatus.processing,
      items: ['Cotton T-Shirt', 'Jeans'],
      total: 49.98,
      orderDate: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Order(
      id: '#12342',
      status: OrderStatus.cancelled,
      items: ['Running Shoes'],
      total: 79.99,
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.orders),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          _buildStatusFilter(),
          
          // Orders List
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['All', 'Processing', 'In Transit', 'Delivered', 'Cancelled'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: FilterChip(
              label: Text(statuses[index]),
              selected: isSelected,
              onSelected: (selected) {
                // Handle status filter
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primaryGreen.withOpacity(0.1),
              checkmarkColor: AppColors.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: AppDimensions.iconExtraLarge,
              color: AppColors.grey500,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'No orders yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'Start shopping to see your orders here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () => _viewOrderDetail(order),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingSmall / 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Order Items
              Text(
                '${order.items.length} item(s): ${order.items.join(", ")}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Order Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    _formatDate(order.orderDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Action Buttons
              Row(
                children: [
                  if (order.status == OrderStatus.delivered)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _reorderItems(order),
                        child: const Text('Reorder'),
                      ),
                    ),
                  if (order.status == OrderStatus.inTransit) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _trackOrder(order),
                        child: const Text('Track Order'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return AppColors.warning;
      case OrderStatus.inTransit:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _viewOrderDetail(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getStatusText(order.status)}'),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text('Items:'),
            ...order.items.map((item) => Text('• $item')),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            Text('Date: ${_formatDate(order.orderDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _trackOrder(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking order ${order.id}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _reorderItems(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reordering items from ${order.id}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

enum OrderStatus {
  processing,
  inTransit,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final OrderStatus status;
  final List<String> items;
  final double total;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.orderDate,
  });
}