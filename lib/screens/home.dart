// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:connection_notifier/connection_notifier.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sih/models/district_info.dart';
import 'package:sih/screens/excel_upload.dart';
import 'package:sih/screens/result.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? stateIndex;
  String? district;
  List<String> districts = [];
  dynamic stateDistrict;
  Position? position;
  List<Placemark>? places;
  dynamic result;
  bool isLoading = false;

  Future<void> readStateDistrictList() async {
    String json =
        await rootBundle.loadString('assets/data/state_district_list.json');
    setState(() {
      stateDistrict = jsonDecode(json);
    });
  }

  Future<void> readResult() async {
    String json = await rootBundle.loadString('assets/data/farm.json');
    dynamic data = jsonDecode(json);
    if (data.containsKey(district?.toLowerCase())) {
      setState(() {
        result = data[district!.toLowerCase()];
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future getPlaces() async {
    if (stateDistrict == null) {
      await readStateDistrictList();
    }
    if (position == null) {
      try {
        position = await _determinePosition();
        places = await placemarkFromCoordinates(
            position!.latitude, position!.longitude);
        setState(() {
          for (int i = 0; i < stateDistrict["states"].length; i++) {
            if (stateDistrict["states"][i]["state"] ==
                places![0].administrativeArea) {
              stateIndex = i;
              break;
            }
          }
          stateDistrict["states"][stateIndex]["districts"].forEach((district) {
            districts.add(district);
          });
          for (String dist in districts) {
            if (dist == places![0].subAdministrativeArea) {
              setState(() {
                district = dist;
              });
              break;
            }
          }
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(178, 219, 146, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 10),
              const Text(
                "Welcome Onboard!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xbf000000),
                  fontSize: 21,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.08,
                ),
              ),
              const SizedBox(height: 30),
              FutureBuilder(
                future: getPlaces(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        const Text(
                          "Please enter your state and district",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xbc000000),
                            fontSize: 18,
                            letterSpacing: 0.78,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownSearch<int>(
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "State",
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                baseStyle: TextStyle(
                                  color: Color(0xb2000000),
                                  fontSize: 15,
                                  letterSpacing: 0.78,
                                ),
                              ),
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                              ),
                              onSaved: (newValue) {
                                setState(() {
                                  stateIndex = newValue;
                                  district = null;
                                  districts.clear();
                                  stateDistrict["states"][stateIndex]
                                          ["districts"]
                                      .forEach((district) {
                                    districts.add(district);
                                  });
                                });
                              },
                              selectedItem: stateIndex,
                              items: List<int>.generate(
                                stateDistrict["states"].length,
                                (index) => index,
                              ),
                              itemAsString: (index) =>
                                  stateDistrict["states"][index]["state"],
                              onChanged: (int? value) {
                                setState(() {
                                  stateIndex = value;
                                  district = null;
                                  districts.clear();
                                  stateDistrict["states"][stateIndex]
                                          ["districts"]
                                      .forEach((district) {
                                    districts.add(district);
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: DropdownSearch<String>(
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "District",
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              baseStyle: TextStyle(
                                color: Color(0xb2000000),
                                fontSize: 15,
                                letterSpacing: 0.78,
                              ),
                            ),
                            popupProps: const PopupProps.dialog(
                              showSearchBox: true,
                            ),
                            selectedItem: district,
                            items: districts,
                            onChanged: (String? value) {
                              setState(() {
                                district = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        isLoading
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                onTap: () async {
                                  if (district == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Select a district to continue'),
                                      ),
                                    );
                                  } else {
                                    await readResult();
                                    if (result != null) {
                                      bool? isConnected =
                                          ConnectionNotifierManager.isConnected(
                                              context);
                                      if (isConnected == null ||
                                          isConnected == false) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration:
                                                const Duration(seconds: 10),
                                            content: Text(
                                                'Not connected to the internet. The data found for $district may be old. Please connect to the internet to get the latest data or dial the number given above to get the latest data'),
                                          ),
                                        );
                                      }
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Result(
                                                district: district!,
                                                info: DistrictInfo.fromMap(
                                                    result)),
                                          ));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'No data found for $district'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  color: const Color(0xff268c43),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 100,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Get Forecast",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.08,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              const SizedBox(height: 90),
              const Text(
                "Troubled by the network problems?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff268c43),
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.84,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Toll-Free Number:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff268c43),
                      fontSize: 14,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.84,
                    ),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse("tel:+447897032693")),
                    child: const Text(
                      "+447897032693",
                      style: TextStyle(
                        color: Color(0xff268c43),
                        fontSize: 14,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        letterSpacing: 0.84,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "About Internet Voice Response",
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          "You can call this number to get the related information through a phone call without internet access in 3 easy steps.\n1. Call +447897032693.\n2. Enter your pin code.\n3. Choose the information you want to know.",
                          textAlign: TextAlign.justify,
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              launchUrl(Uri.parse("tel:+447897032693"));
                            },
                            child: const Text(
                              "Call",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.84,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.84,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  "Click Here to Know More",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 38, 96, 140),
                    fontSize: 14,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    letterSpacing: 0.84,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExcelUpload(),
                  ),
                ),
                child: const Text(
                  "Click Here to Upload Excel File",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 38, 96, 140),
                    fontSize: 14,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    letterSpacing: 0.84,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
