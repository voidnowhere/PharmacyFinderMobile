import 'package:flutter/material.dart';
import 'package:pharmacies/services/api_service.dart';
import 'package:pharmacies/widgets/custom_snackbar.dart';
import 'package:pharmacies/models/city.dart';
import 'package:pharmacies/models/pharmacy.dart';
import 'package:pharmacies/models/zone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pharmacy> _pharmacies = [];
  List<City> _cities = [];
  City? _selectedCity;
  List<Zone> _zones = [];
  Zone? _selectedZone;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getCities();
    });
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return null;
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return null;
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return null;
      // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _getCities() {
    ApiService.getInstance().get('api/v1/cities').then((response) {
      final responseData = response.data;
      setState(() {
        _cities = (responseData != null)
            ? (responseData as List).map((json) => City.fromJson(json)).toList()
            : [];
      });
    }).catchError((error) {
      CustomSnackbar.get('Service unavailbale!', 17);
    });
  }

  void _getZones() {
    setState(() {
      _selectedZone = null;
      _pharmacies = [];
    });
    ApiService.getInstance()
        .get('api/v1/cities/${_selectedCity?.id}/zones')
        .then((response) {
      final responseData = response.data;
      setState(() {
        _zones = (responseData != null)
            ? (responseData as List).map((json) => Zone.fromJson(json)).toList()
            : [];
      });
    }).catchError((error) {
      CustomSnackbar.get('Service unavailbale!', 17);
    });
  }

  void _getPharmacies() async {
    Position? position = await _determinePosition();

    if (position != null) {
      ApiService.getInstance().post(
        'api/v1/zones/${_selectedZone?.id}/pharmacies/closest',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      ).then((response) {
        final responseData = response.data;
        setState(() {
          _pharmacies = (responseData != null)
              ? (responseData as List)
                  .map((json) => Pharmacy.fromJson(json))
                  .toList()
              : [];
        });
      }).catchError((error) {
        CustomSnackbar.get('Service unavailbale!', 17);
      });
    } else {
      ApiService.getInstance()
          .get('api/v1/zones/${_selectedZone?.id}/pharmacies')
          .then((response) {
        final responseData = response.data;
        setState(() {
          _pharmacies = (responseData != null)
              ? (responseData as List)
                  .map((json) => Pharmacy.fromJson(json))
                  .toList()
              : [];
        });
      }).catchError((error) {
        CustomSnackbar.get('Service unavailbale!', 17);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("City"),
              const SizedBox(width: 15),
              DropdownButton(
                value: _selectedCity,
                items: _cities
                    .map((city) => DropdownMenuItem<City>(
                          value: city,
                          child: Text(city.name),
                        ))
                    .toList(),
                onChanged: (City? city) => {
                  setState(() {
                    _selectedCity = city;
                  }),
                  _getZones()
                },
              ),
              const SizedBox(width: 20),
              const Text("Zone"),
              const SizedBox(width: 15),
              DropdownButton(
                value: _selectedZone,
                items: _zones
                    .map((zone) => DropdownMenuItem<Zone>(
                          value: zone,
                          child: Text(zone.name),
                        ))
                    .toList(),
                onChanged: (Zone? zone) => {
                  setState(() {
                    _selectedZone = zone;
                  }),
                  _getPharmacies()
                },
              ),
            ],
          ),
          if (_pharmacies.isNotEmpty)
            IconButton(
              iconSize: 35,
              onPressed: () async {
                Position? position = await _determinePosition();
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: {
                      'pharmacies': _pharmacies,
                      'position': position,
                    },
                  );
                }
              },
              icon: const Icon(Icons.map),
            ),
          Column(
            children: _pharmacies
                .map((pharmacy) => ListTile(
                      leading: Image.asset('assets/pharmacy.png', height: 50),
                      trailing: IconButton(
                        iconSize: 35,
                        onPressed: () async {
                          Position? position = await _determinePosition();
                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              '/map',
                              arguments: {
                                'pharmacies': [pharmacy],
                                'position': position,
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.place),
                      ),
                      title: Text(pharmacy.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await launchUrl(
                                  Uri.parse('tel:${pharmacy.phoneNumber}'));
                            },
                            child: Text(pharmacy.phoneNumber),
                          ),
                          Text(pharmacy.address),
                        ],
                      ),
                      isThreeLine: true,
                    ))
                .toList(),
          )
        ]),
      ),
    );
  }
}
