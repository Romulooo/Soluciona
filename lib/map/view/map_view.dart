import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soluciona/main.dart';
import 'package:soluciona/map/cubit/map_cubit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        actions: [
          Column(
            children: [
              Icon(Icons.person, color: darKBlue, size: 34),
              Text("Rômulo"),
            ],
          ),
          SizedBox(width: 12),
        ],
      ),

      floatingActionButton: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          if (state is MapSuccess) {
            return FloatingActionButton(
              backgroundColor: white,
              shape: CircleBorder(),
              splashColor: lightBlue,
              onPressed: () {
                context.read<MapCubit>().getCurrentLocation();
              },
              child: Icon(Icons.my_location, color: darKBlue),
            );
          } else {
            return FloatingActionButton(
              backgroundColor: white,
              shape: CircleBorder(),
              splashColor: lightBlue,
              onPressed: () {},
              child: CircularProgressIndicator(color: darKBlue),
            );
          }
        },
      ),

      body: BlocListener<MapCubit, MapState>(
        listener: (context, state) {
          if (state is MapSuccess) {
            mapController.move(state.location, 15.0);
          } else if (state is MapFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(0, 0),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/basic/{z}/{x}/{y}.jpg?key=<key>',
                  userAgentPackageName: 'com.example.soluciona',
                ),

                BlocBuilder<MapCubit, MapState>(
                  builder: (context, state) {
                    if (state is MapSuccess) {
                      return MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            rotate: true,
                            point: state.location,
                            child: Icon(
                              Icons.person_pin_circle,
                              color: mediumBlue,
                              size: 40.0,
                            ),
                          ),
                        ],
                      );
                    }

                    return const MarkerLayer(markers: []);
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 14,
              left: 14,
              child: FloatingActionButton(
                backgroundColor: white,
                shape: CircleBorder(),
                splashColor: lightBlue,
                onPressed: () {},
                child: Icon(Icons.report, color: darKBlue, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
