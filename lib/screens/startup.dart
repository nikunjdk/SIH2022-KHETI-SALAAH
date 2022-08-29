// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sih/screens/home.dart';

class Startup extends StatefulWidget {
  const Startup({Key? key}) : super(key: key);

  @override
  State<Startup> createState() => _StartupState();
}

class _StartupState extends State<Startup> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late bool connectionStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/flag.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0, top: 15.0),
                child: Text(
                  "KHETI SALAAH",
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(color: const Color(0xffe1ded7)),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                bottom: 1,
                right: 100,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Lottie.asset(
                    'assets/lottie/startup.json',
                    controller: _controller,
                    onLoaded: (composition) {
                      _controller.addStatusListener(
                        (status) async {
                          if (status == AnimationStatus.completed) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Home(),
                              ),
                            );
                            // connectionStatus =
                            //     await InternetConnectionChecker().hasConnection;
                            // if (connectionStatus) {
                            //   Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const Home(),
                            //     ),
                            //   );
                            // } else {
                            //   Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const IVR(),
                            //     ),
                            //   );
                            // }
                          }
                        },
                      );
                      _controller
                        ..duration = composition.duration
                        ..forward();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
