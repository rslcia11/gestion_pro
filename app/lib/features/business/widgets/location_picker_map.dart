// lib/features/business/widgets/location_picker_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';

class LocationPickerMap extends StatefulWidget {
  final Function(double latitude, double longitude, String address)
  onLocationSelected;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const LocationPickerMap({
    super.key,
    required this.onLocationSelected,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String _address = '';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      setState(() {
        _selectedLocation = LatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        );
        _address = widget.initialAddress ?? '';
        _searchController.text = _address;
      });
    } else {
      // Ubicación por defecto (Quito) sin pedir permisos
      final defaultLocation = const LatLng(-0.1807, -78.4678);
      setState(() {
        _selectedLocation = defaultLocation;
        _address = 'Quito, Ecuador';
        _searchController.text = _address;
      });
      // Importante: No llamamos a _getCurrentLocation() aquí para no asustar al usuario.
      // Se llamará solo cuando presione "UBICARME".
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          final turnOn = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
              title: Text('GPS Desactivado', style: AppTypography.titleBold),
              content: Text('Para poder ubicarte automáticamente, necesitas encender el GPS. ¿Deseas abrir la configuración?', style: AppTypography.bodyRegular),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(ctx, false)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(label: 'Configuración', onPressed: () => Navigator.pop(ctx, true)),
                    ),
                  ],
                ),
              ],
            ),
          );

          if (turnOn == true) {
            await Geolocator.openLocationSettings();
            // Esperar un momento a que el usuario active y regrese
            await Future.delayed(const Duration(seconds: 3));
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
               throw Exception('El GPS sigue desactivado');
            }
          } else {
             throw Exception('Servicios de ubicación desactivados por el usuario');
          }
        } else {
          throw Exception('Servicios de ubicación desactivados');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación fueron denegados permanentemente en el sistema. Debes habilitarlos en la configuración de la app.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
      });

      _mapController.move(newLocation, 15.0);
      await _updateAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lon) async {
    setState(() => _isLoading = true);
    String? newAddress;

    try {
      // Intento 1: Geocoding Nativo
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> parts = [];
        if (place.street?.isNotEmpty ?? false) parts.add(place.street!);
        if (place.subLocality?.isNotEmpty ?? false) {
          parts.add(place.subLocality!);
        } else if (place.locality?.isNotEmpty ?? false) {
          parts.add(place.locality!);
        }
        if (place.subAdministrativeArea?.isNotEmpty ?? false) {
          parts.add(place.subAdministrativeArea!);
        }
        
        if (parts.isNotEmpty) {
          newAddress = parts.join(', ');
        }
      }
    } catch (e) {
      debugPrint('Error geocoding nativo: $e');
    }

    // Intento 2: Nominatim (OpenStreetMap) de respaldo si el nativo falla o es incompleto
    if (newAddress == null || newAddress.length < 5) {
      try {
        
        
        final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1');
        final response = await http.get(uri, headers: {
          'User-Agent': 'DondeSiempreApp/1.0 (soporte@dondesiempre.app)',
          'Accept-Language': 'es-ES,es;q=0.9',
        });
        
        if (response.statusCode == 200) {
          final content = utf8.decode(response.bodyBytes);
          final data = json.decode(content);
          
          final addressData = data['address'];
          if (addressData != null) {
            final road = addressData['road'] ?? addressData['pedestrian'] ?? '';
            final neighborhood = addressData['neighborhood'] ?? addressData['suburb'] ?? addressData['residential'] ?? '';
            final city = addressData['city'] ?? addressData['town'] ?? addressData['village'] ?? '';
            
            final parts = [road, neighborhood, city].where((s) => s.toString().isNotEmpty).toList();
            if (parts.isNotEmpty) {
              newAddress = parts.join(', ');
            } else {
              newAddress = data['display_name'];
            }
          } else {
            newAddress = data['display_name'];
          }
          
          // Limpiar si es demasiado largo
          if (newAddress != null && newAddress.length > 100) {
            newAddress = newAddress.split(',').take(3).join(', ').trim();
          }
        }
      } catch (e) {
        debugPrint('Error geocoding Nominatim: $e');
      }
    }

    setState(() {
      _address = newAddress ?? 'Ubicación: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      _searchController.text = _address;
      _isLoading = false;
    });

    widget.onLocationSelected(lat, lon, _address);
  }

  Future<Iterable<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.length < 3) return const Iterable.empty();

    final completer = Completer<Iterable<Map<String, dynamic>>>();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        
        
        final uri = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&addressdetails=1&countrycodes=ec&limit=5');
        final response = await http.get(uri, headers: {
          'User-Agent': 'DondeSiempreApp/1.0',
        });
        
        if (response.statusCode == 200) {
          final content = utf8.decode(response.bodyBytes);
          final List data = json.decode(content);
          completer.complete(data.cast<Map<String, dynamic>>());
        } else {
          completer.complete(const Iterable.empty());
        }
      } catch (e) {
        completer.complete(const Iterable.empty());
      }
    });

    return completer.future;
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    LatLng? newLocation;
    String? newAddress;

    try {
      // Intento 1: Geocoding Nativo
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        newLocation = LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint('Error búsqueda nativa: $e');
    }

    // Intento 2: Nominatim Search de respaldo
    if (newLocation == null) {
      try {
        
        
        final uri = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1&addressdetails=1');
        final response = await http.get(uri, headers: {
          'User-Agent': 'DondeSiempreApp/1.0',
        });
        
        if (response.statusCode == 200) {
          final content = utf8.decode(response.bodyBytes);
          final data = json.decode(content);
          if (data is List && data.isNotEmpty) {
            final firstMatch = data[0];
            newLocation = LatLng(
              double.parse(firstMatch['lat']),
              double.parse(firstMatch['lon']),
            );
            
            final addressData = firstMatch['address'];
            if (addressData != null) {
              final road = addressData['road'] ?? addressData['pedestrian'] ?? '';
              final neighborhood = addressData['neighborhood'] ?? addressData['suburb'] ?? addressData['residential'] ?? '';
              final city = addressData['city'] ?? addressData['town'] ?? addressData['village'] ?? '';
              final parts = [road, neighborhood, city].where((s) => s.toString().isNotEmpty).toList();
              newAddress = parts.isNotEmpty ? parts.join(', ') : firstMatch['display_name'];
            } else {
              newAddress = firstMatch['display_name'];
            }
          }
        }
      } catch (e) {
        debugPrint('Error búsqueda Nominatim: $e');
      }
    }

    if (newLocation != null) {
      if (mounted) {
        setState(() {
          _selectedLocation = newLocation;
          _mapController.move(newLocation!, 15.0);
        });
      }
      
      if (newAddress != null) {
        if (mounted) {
          setState(() {
            _address = newAddress!;
            _searchController.text = _address;
          });
        }
        widget.onLocationSelected(newLocation.latitude, newLocation.longitude, _address);
      } else {
        await _updateAddressFromCoordinates(newLocation.latitude, newLocation.longitude);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la dirección')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _onMapTapped(TapPosition tap, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _updateAddressFromCoordinates(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(8),
            color: AppColors.surfaceCard,
            child: RawAutocomplete<Map<String, dynamic>>(
              textEditingController: _searchController,
              focusNode: _searchFocusNode,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return _getSuggestions(textEditingValue.text);
              },
              displayStringForOption: (option) => option['display_name'] ?? '',
              onSelected: (selection) {
                final lat = double.tryParse(selection['lat'].toString()) ?? 0.0;
                final lon = double.tryParse(selection['lon'].toString()) ?? 0.0;
                final newLocation = LatLng(lat, lon);

                setState(() {
                  _selectedLocation = newLocation;
                  _address = selection['display_name'] ?? '';
                  _mapController.move(newLocation, 16.0);
                });

                _searchFocusNode.unfocus();
                widget.onLocationSelected(lat, lon, _address);
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: AppTypography.bodyRegular,
                  decoration: InputDecoration(
                    hintText: 'Buscar ciudad, calle, local...',
                    prefixIcon: Icon(LucideIcons.search, size: 20, color: AppColors.textSecondary),
                    suffixIcon: textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(LucideIcons.x, size: 18, color: AppColors.textSecondary),
                            onPressed: () {
                              textEditingController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    onFieldSubmitted();
                    _searchAddress(value);
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Material(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        clipBehavior: Clip.antiAlias,
                        color: AppColors.surfaceCard,
                        child: Container(
                          width: constraints.maxWidth,
                          constraints: const BoxConstraints(maxHeight: 280),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.card),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border),
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              final address = option['address'] ?? {};
                              final road = address['road'] ?? address['pedestrian'] ?? '';
                              final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
                              final name = option['name'] ?? '';

                              final title = name.isNotEmpty ? name : (road.isNotEmpty ? road : city);

                              return ListTile(
                                dense: true,
                                leading: Icon(LucideIcons.mapPin, color: AppColors.primary, size: 20),
                                title: Text(
                                  title.isNotEmpty ? title : 'Ubicación',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.subtitleBold.copyWith(fontSize: 14),
                                ),
                                subtitle: Text(
                                  option['display_name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption,
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Mapa
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _selectedLocation ?? const LatLng(-0.1807, -78.4678),
                    initialZoom: 15.0,
                    onTap: _onMapTapped,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.dondesiempre.app',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: _selectedLocation!,
                            child: Icon(
                              LucideIcons.mapPin,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Botón flotante "Ubicarme" sobre el mapa
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    color: AppColors.surfaceCard,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      onTap: _getCurrentLocation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.locate, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Ubicarme',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (_isLoading)
                  Container(
                    color: Colors.black26,
                    child: Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)),
                    ),
                  ),
              ],
            ),
          ),

          // Dirección seleccionada
          if (_address.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadii.badge),
                  bottomRight: Radius.circular(AppRadii.badge),
                ),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 16, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_address, style: AppTypography.caption, overflow: TextOverflow.ellipsis, maxLines: 2),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}



