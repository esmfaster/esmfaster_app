import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app/src/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:place_picker_google/place_picker_google.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart';
import '../../models/app_state_model.dart';
import '../../config.dart';

/// A Place Picker screen that uses `google_maps_flutter` to display a map
/// and lets users pick a location. It also integrates with Google Places
/// and reverse geocoding to provide addresses.
class PlacePickerHome extends StatefulWidget {
  /// Callback to run (e.g., start shopping) after the user confirms a location
  final VoidCallback? onPressStartShopping;

  const PlacePickerHome({Key? key, this.onPressStartShopping}) : super(key: key);

  @override
  State<PlacePickerHome> createState() => PlacePickerHomeState();
}

class PlacePickerHomeState extends State<PlacePickerHome> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();

  /// Marker indicating the user-selected location on the map
  final Set<Marker> markers = {};

  /// Contains the geocoded data of the selected location
  LocationResult? locationResult;

  /// Holds nearby place information
  final List<NearbyPlace> nearbyPlaces = [];

  /// Overlay for autocomplete suggestions (if you ever implement them)
  OverlayEntry? overlayEntry;

  final GlobalKey appBarKey = GlobalKey();
  final Config config = Config();
  final AppStateModel appStateModel = AppStateModel();

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _getUserLocation();
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  /// Utility method to build a more detailed address string from a `Placemark`
  String _buildAddressString(Placemark placemark) {
    final name = (placemark.name?.trim().isNotEmpty ?? false) ? placemark.name : null;
    final street = (placemark.street?.trim().isNotEmpty ?? false) ? placemark.street : null;

    // Only add `name` if it's not the same as `street`.
    final addressParts = <String?>[
      if (name != null && name != street) name,
      street,
      placemark.subLocality,        // neighborhood or area
      placemark.locality,           // city
      placemark.administrativeArea, // state or province
      placemark.postalCode,         // postal code
      placemark.country,            // country
    ];

    return addressParts
        .where((part) => part != null && part.isNotEmpty)
        .join(', ');
  }

  /// Initializes the marker from saved user location or a fallback location
  void _initializeMarkers() {
    try {
      markers.add(
        Marker(
          markerId: const MarkerId("selected-location"),
          position: LatLng(
            double.parse(appStateModel.customerLocation['latitude']),
            double.parse(appStateModel.customerLocation['longitude']),
          ),
        ),
      );
    } catch (_) {
      // Fallback marker if stored location is unavailable
      markers.add(
        const Marker(
          markerId: MarkerId("selected-location"),
          position: LatLng(26.1826, 28.0040),
        ),
      );
    }
  }

  /// Called when the map is created. Sets up the map controller.
  Future<void> onMapCreated(GoogleMapController controller) async {
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
    }
    await _moveToCurrentUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// Google Map
          Expanded(
            flex: 8,
            child: ScopedModelDescendant<AppStateModel>(
              builder: (context, child, model) {
                final hasLocation = model.customerLocation.containsKey('latitude') &&
                    isNumeric(model.customerLocation['latitude']);
                final initialPosition = hasLocation
                    ? LatLng(
                  double.parse(model.customerLocation['latitude']),
                  double.parse(model.customerLocation['longitude']),
                )
                    : const LatLng(30.5595, 22.9375);

                return GoogleMap(
                  initialCameraPosition: CameraPosition(target: initialPosition, zoom: 8),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: onMapCreated,
                  onTap: (latLng) async {
                    _clearOverlay();
                    await _moveToLocation(latLng);
                    await _getUserAddress(latLng);
                  },
                  markers: markers,
                );
              },
            ),
          ),

          /// Bottom controls: address search, use current location, confirm
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScopedModelDescendant<AppStateModel>(
                  builder: (context, child, model) {
                    return Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          // Launch the Google Place Picker plugin
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                apiKey: Platform.isAndroid ? config.mapApiKey : config.mapApiKey,
                                initialLocation: const LatLng(29.378586, 47.990341),
                                searchInputConfig: const SearchInputConfig(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  autofocus: false,
                                  textDirection: TextDirection.ltr,
                                ),
                                searchInputDecorationConfig: const SearchInputDecorationConfig(
                                  hintText: "Search for a building, street or ...",
                                ),
                                onPlacePicked: (LocationResult result) async {
                                  // Debug/log the picked place
                                  debugPrint("Place picked: ${result.formattedAddress}");

                                  // Create a map of the picked location
                                  final pickedLocation = <String, dynamic>{
                                    'address': result.formattedAddress,
                                    'latitude': result.latLng?.latitude.toString(),
                                    'longitude': result.latLng?.longitude.toString(),
                                    // Optionally add city, postalCode, etc., if available
                                  };

                                  // Store in app state
                                  appStateModel.setPickedLocation(pickedLocation);

                                  // Animate map to the new location
                                  final controller = await _mapControllerCompleter.future; // or mapController.future
                                  await controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: result.latLng!,
                                        zoom: 15.0, // Adjust zoom level to taste
                                      ),
                                    ),
                                  );

                                  // Update marker
                                  setState(() {
                                    markers
                                      ..clear()
                                      ..add(
                                        Marker(
                                          markerId: const MarkerId("selected-location"),
                                          position: result.latLng!,
                                        ),
                                      );
                                  });

                                },
                              ),
                            ),
                          );


                          // After place picker returns, move map to updated location if any
                          if (model.customerLocation.containsKey('latitude')) {
                            final latStr = model.customerLocation['latitude'];
                            final lngStr = model.customerLocation['longitude'];
                            if (isNumeric(latStr) && isNumeric(lngStr)) {
                              final lat = double.parse(latStr);
                              final lng = double.parse(lngStr);
                              final controller = await _mapControllerCompleter.future;
                              await controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(target: LatLng(lat, lng), zoom: 8),
                                ),
                              );
                              setState(() {
                                markers
                                  ..clear()
                                  ..add(
                                    Marker(
                                      markerId: const MarkerId("selected-location"),
                                      position: LatLng(lat, lng),
                                    ),
                                  );
                              });
                            }
                          }
                        },
                        child: TextField(
                          showCursor: false,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: model.customerLocation['address'] ?? 'Search your place',
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            filled: true,
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor,
                                width: 0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(6),
                            prefixIcon: Icon(
                              FlutterRemix.search_2_line,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton(
                    onPressed: _getUserLocation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_searching, color: Colors.orange),
                        const SizedBox(width: 10),
                        Text(
                          'Use current location',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Confirm Your Location'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Removes autocomplete overlay if open
  void _clearOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  /// Asynchronously move map camera to a given location, set marker, fetch address & nearby places
  Future<void> _moveToLocation(LatLng latLng) async {
    try {
      final controller = await _mapControllerCompleter.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 15)),
      );
      _setMarker(latLng);
      await _reverseGeocodeLatLng(latLng);
      await _getNearbyPlaces(latLng);
    } catch (e) {
      debugPrint("Map controller not available or error: $e");
    }
  }

  /// Set the selected-location marker on the map
  void _setMarker(LatLng latLng) {
    setState(() {
      markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId("selected-location"),
            position: latLng,
          ),
        );
    });
  }

  /// Use Google Places Nearby Search to get places near latLng
  Future<void> _getNearbyPlaces(LatLng latLng) async {
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
            "key=${config.mapApiKey}"
            "&location=${latLng.latitude},${latLng.longitude}&radius=150",
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final responseJson = jsonDecode(response.body);
      if (responseJson['results'] == null) return;

      nearbyPlaces.clear();
      for (final item in responseJson['results']) {
        final nearbyPlace = NearbyPlace()
          ..name = item['name']
          ..icon = item['icon']
          ..latLng = LatLng(
            item['geometry']['location']['lat'],
            item['geometry']['location']['lng'],
          );
        nearbyPlaces.add(nearbyPlace);
      }

      setState(() {
        // Trigger UI update if needed
      });
    } catch (e) {
      debugPrint("Error fetching nearby places: $e");
    }
  }

  /// Reverse geocode to get a human-readable address for latLng
  Future<void> _reverseGeocodeLatLng(LatLng latLng) async {
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?"
            "latlng=${latLng.latitude},${latLng.longitude}"
            "&key=${config.mapApiKey}",
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final responseJson = jsonDecode(response.body);
      if (responseJson['results'] == null || responseJson['results'].isEmpty) return;

      final result = responseJson['results'][0];
      setState(() {
        locationResult = LocationResult()
          ..name = result['address_components'][0]['short_name']
          ..locality = result['address_components'][1]['short_name']
          ..latLng = latLng
          ..formattedAddress = result['formatted_address']
          ..placeId = result['place_id']
          ..postalCode = result['address_components'][5]['short_name']
          ..country = AddressComponent.fromJson(result['address_components'][4])
          ..administrativeAreaLevel1 =
          AddressComponent.fromJson(result['address_components'][5])
          ..administrativeAreaLevel2 =
          AddressComponent.fromJson(result['address_components'][4])
          ..locality = AddressComponent.fromJson(result['address_components'][3])
          ..subLocalityLevel1 =
          AddressComponent.fromJson(result['address_components'][2])
          ..subLocalityLevel2 =
          AddressComponent.fromJson(result['address_components'][1]);
      });

      // Save location info to the app state
      final newLocation = <String, dynamic>{};
      if (locationResult != null) {
        newLocation['address'] = locationResult!.formattedAddress ??
            locationResult!.name ??
            locationResult!.locality;
      }
      if (locationResult?.postalCode != null) {
        newLocation['postalCode'] = locationResult!.postalCode;
      }
      if (locationResult?.locality != null) {
        newLocation['city'] = locationResult!.locality;
      }
      newLocation['latitude'] = latLng.latitude.toString();
      newLocation['longitude'] = latLng.longitude.toString();
      appStateModel.setPickedLocation(newLocation);
    } catch (e) {
      debugPrint("Error in reverse geocoding: $e");
    }
  }

  /// Animate camera to user’s current location if granted
  Future<void> _moveToCurrentUserLocation() async {
    try {
      final locationData = await Location().getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;
      if (lat != null && lng != null) {
        await _moveToLocation(LatLng(lat, lng));
      }
    } catch (e) {
      debugPrint("Couldn't move to current user location: $e");
    }
  }

  /// Gets the current location, places a marker, and saves it to the app state
  Future<void> _getUserLocation() async {
    final Location locationService = Location();
    LocationData? locationData;

    try {
      locationData = await locationService.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED' || e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        // Show a snackbar for a better user experience
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission denied. Please enable it in settings.'),
            ),
          );
        }
      }
      locationData = null;
    }

    final lat = locationData?.latitude;
    final lng = locationData?.longitude;

    if (lat != null && lng != null) {
      // Use geocoding to get address from lat/long
      try {
        final placeMarks = await placemarkFromCoordinates(lat, lng);

        if (placeMarks.isNotEmpty) {
          final placemark = placeMarks.first;

          // Move camera and add marker
          final controller = await _mapControllerCompleter.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lng),
                zoom: 8,
              ),
            ),
          );
          setState(() {
            markers
              ..clear()
              ..add(
                Marker(
                  markerId: const MarkerId("selected-location"),
                  position: LatLng(lat, lng),
                ),
              );
          });

          // Build a more detailed address string
          final fullAddress = _buildAddressString(placemark);

          // Update app state
          final pickedLocation = <String, dynamic>{
            'address': fullAddress,
            'city': placemark.locality,
            'latitude': lat.toString(),
            'longitude': lng.toString(),
          };

          // If the reverseGeocode (locationResult) has a postal code, set it
          if (locationResult?.postalCode != null) {
            pickedLocation['postalCode'] = locationResult!.postalCode;
          } else if (placemark.postalCode != null) {
            pickedLocation['postalCode'] = placemark.postalCode;
          }

          appStateModel.setPickedLocation(pickedLocation);
        }
      } catch (e) {
        debugPrint("Error during geocoding: $e");
      }
    }
  }

  /// Gets user address from a tapped LatLng and updates the marker & app state
  Future<void> _getUserAddress(LatLng latLng) async {
    try {
      final placeMarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placeMarks.isNotEmpty) {
        final placemark = placeMarks.first;

        // Move camera and add marker
        final controller = await _mapControllerCompleter.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 8),
          ),
        );

        setState(() {
          markers
            ..clear()
            ..add(
              Marker(
                markerId: const MarkerId("selected-location"),
                position: latLng,
              ),
            );
        });

        final fullAddress = _buildAddressString(placemark);

        final pickedLocation = <String, dynamic>{
          'address': fullAddress,
          'city': placemark.locality,
          'latitude': latLng.latitude.toString(),
          'longitude': latLng.longitude.toString(),
        };

        if (placemark.postalCode != null) {
          pickedLocation['postalCode'] = placemark.postalCode;
        }

        appStateModel.setPickedLocation(pickedLocation);
      }
    } catch (e) {
      debugPrint("Error during tapped address retrieval: $e");
    }
  }
}
