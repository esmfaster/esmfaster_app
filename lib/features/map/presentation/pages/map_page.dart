import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<StoreLocation> _stores = [
    StoreLocation(
      id: '1',
      name: 'ESMFaster Store Downtown',
      address: '123 Main Street, City Center',
      distance: 0.5,
      isOpen: true,
      phone: '+1 234-567-8900',
    ),
    StoreLocation(
      id: '2',
      name: 'ESMFaster Store Mall',
      address: '456 Shopping Mall, North District',
      distance: 1.2,
      isOpen: true,
      phone: '+1 234-567-8901',
    ),
    StoreLocation(
      id: '3',
      name: 'ESMFaster Store Outlet',
      address: '789 Outlet Plaza, West Side',
      distance: 2.8,
      isOpen: false,
      phone: '+1 234-567-8902',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.map),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Handle current location
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map View Placeholder
          Expanded(
            flex: 2,
            child: _buildMapView(),
          ),
          
          // Store List
          Expanded(
            flex: 1,
            child: _buildStoreList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.my_location, color: AppColors.white),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.grey200,
      ),
      child: Stack(
        children: [
          // Map placeholder
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: AppColors.grey500,
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Google Maps integration would go here',
                  style: TextStyle(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Positioned(
            top: AppDimensions.paddingMedium,
            left: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey300.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for stores nearby...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.grey500),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: AppColors.grey500,
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Store List Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Stores (${_stores.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _sortStores,
                  child: const Text('Sort by distance'),
                ),
              ],
            ),
          ),
          
          // Store List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
              itemCount: _stores.length,
              itemBuilder: (context, index) {
                return _buildStoreCard(_stores[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(StoreLocation store) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () => _selectStore(store),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              // Store Icon
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: store.isOpen 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.store,
                  color: store.isOpen ? AppColors.success : AppColors.error,
                  size: AppDimensions.iconMedium,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Store Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall / 2),
                    Text(
                      store.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: AppDimensions.iconSmall,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${store.distance.toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall / 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: store.isOpen 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                          ),
                          child: Text(
                            store.isOpen ? 'Open' : 'Closed',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: store.isOpen ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.directions, color: AppColors.primaryGreen),
                    onPressed: () => _getDirections(store),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.secondaryOrange),
                    onPressed: () => _callStore(store),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Getting current location...'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Stores'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Open Now'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Within 5 km'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _sortStores() {
    setState(() {
      _stores.sort((a, b) => a.distance.compareTo(b.distance));
    });
  }

  void _selectStore(StoreLocation store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(store.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${store.address}'),
            Text('Distance: ${store.distance.toStringAsFixed(1)} km'),
            Text('Phone: ${store.phone}'),
            Text('Status: ${store.isOpen ? "Open" : "Closed"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _getDirections(store);
            },
            child: const Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  void _getDirections(StoreLocation store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Getting directions to ${store.name}'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _callStore(StoreLocation store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${store.name}'),
        backgroundColor: AppColors.secondaryOrange,
      ),
    );
  }
}

class StoreLocation {
  final String id;
  final String name;
  final String address;
  final double distance;
  final bool isOpen;
  final String phone;

  StoreLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.isOpen,
    required this.phone,
  });
}