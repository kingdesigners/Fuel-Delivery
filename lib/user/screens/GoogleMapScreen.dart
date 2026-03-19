import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/system_utils.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/PlaceAddressModel.dart';
import '../../main/utils/Constants.dart';
import '../../main/network/RestApis.dart';
import '../../extensions/shared_pref.dart';

class GoogleMapScreen extends StatefulWidget {
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  final bool isPick;
  final bool isSaveAddress;
  final bool isAddAddress;

  GoogleMapScreen(
      {this.isPick = true,
      this.isSaveAddress = false,
      this.isAddAddress = false});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen>
    with WidgetsBindingObserver {
  PickResult? selectedPlace;
  bool showPlacePickerInContainer = false;
  bool showGoogleMapInContainer = false;
  bool saveToMyAddresses = false;
  GlobalKey<_GoogleMapScreenState> placePickerKey =
      GlobalKey<_GoogleMapScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--onResume called");
    if (state == AppLifecycleState.resumed) {
      setState(() {
        placePickerKey = GlobalKey<_GoogleMapScreenState>();
      });
    }
  }

  String buildTitle() {
    if (widget.isSaveAddress || widget.isAddAddress) {
      return language.selectLocation;
    } else if (widget.isPick) {
      return language.selectPickupLocation;
    } else {
      return language.selectDeliveryLocation;
    }
  }

  String buildButtonText() {
    print("buildButtonText() called ---------------------------");
    if (widget.isPick) {
      return language.confirmPickupLocation;
    } else if (widget.isAddAddress) {
      return language.addNewAddress;
    } else {
      return language.confirmDeliveryLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: buildTitle(),
      body: Column(
        children: [
          PlacePicker(
            key: placePickerKey,
            apiKey: googleMapAPIKey,
            hintText: language.searchAddress,
            searchingText: language.pleaseWait,
            selectText:buildButtonText(),
            outsideOfPickAreaText: language.addressNotInArea,
            initialPosition: GoogleMapScreen.kInitialPosition,
            useCurrentLocation: true,
            selectInitialPosition: true,
            usePinPointingSearch: true,
            usePlaceDetailSearch: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            automaticallyImplyAppBarLeading: false,
            autocompleteLanguage: appStore.selectedLanguage,
            onMapCreated: (GoogleMapController controller) {
              //
            },
            // resizeToAvoidBottomInset: false,
            onPlacePicked: (PickResult result) {
              setState(() {
                selectedPlace = result;
                PlaceAddressModel selectedModel = PlaceAddressModel(
                  placeId: selectedPlace!.placeId!,
                  latitude: selectedPlace!.geometry!.location.lat,
                  longitude: selectedPlace!.geometry!.location.lng,
                  placeAddress: selectedPlace!.formattedAddress,
                );
                print("===============KK${selectedModel.toJson().toString()}");
                finish(context, selectedModel);
              });
            },
            onMapTypeChanged: (MapType mapType) {
              //
            },
            selectedPlaceWidgetBuilder: (context, selectedPlace, state, isSearchBarFocused) {
              if (state == SearchingState.Searching) {
                return const Center(child: CircularProgressIndicator());
              }
              if (selectedPlace == null) return const SizedBox.shrink();

              String placeName = selectedPlace.name ?? '';
              String formattedAddress = selectedPlace.formattedAddress ?? '';
              String fullAddress = placeName;
              if (placeName.isNotEmpty && formattedAddress.isNotEmpty && !formattedAddress.startsWith(placeName)) {
                fullAddress = "$placeName, $formattedAddress";
              } else if (placeName.isEmpty) {
                fullAddress = formattedAddress;
              }

              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (placeName.isNotEmpty) ...[
                            Text(
                              placeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            formattedAddress,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: saveToMyAddresses,
                                    onChanged: (val) {
                                      setState(() {
                                        saveToMyAddresses = val ?? false;
                                      });
                                    },
                                  ),
                                  const Text("Save to My Addresses"),
                                ],
                              );
                            }
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                this.selectedPlace = selectedPlace;
                                PlaceAddressModel selectedModel = PlaceAddressModel(
                                  placeId: selectedPlace.placeId ?? '',
                                  latitude: selectedPlace.geometry?.location.lat ?? 0.0,
                                  longitude: selectedPlace.geometry?.location.lng ?? 0.0,
                                  placeAddress: fullAddress,
                                );

                                if (saveToMyAddresses) {
                                  appStore.setLoading(true);
                                  try {
                                      Map req = {
                                        "user_id": getIntAsync(USER_ID),
                                        "address": fullAddress,
                                        "latitude": selectedModel.latitude,
                                        "longitude": selectedModel.longitude,
                                        "contact_number": (await getSharedPref()).getString(USER_CONTACT_NUMBER) ?? '',
                                        "city_id": getIntAsync(CITY_ID).toString(),
                                        "country_id": getIntAsync(COUNTRY_ID).toString(),
                                        "address_type": widget.isPick ? 'Pickup' : 'Delivery'
                                      };
                                      await saveUserAddress(req);
                                  } catch (e) {
                                      print("Failed to save address: $e");
                                  } finally {
                                      appStore.setLoading(false);
                                  }
                                }

                                print("===============KK${selectedModel.toJson().toString()}");
                                finish(context, selectedModel);
                              },
                              child: Text(buildButtonText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ).expand(),
        ],
      ),
    );
  }
}
