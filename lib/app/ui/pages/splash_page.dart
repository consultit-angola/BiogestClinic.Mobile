import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (splashController) =>
          MySplashPage(splashController: splashController),
    );
  }
}

class MySplashPage extends StatefulWidget {
  final SplashController splashController;
  const MySplashPage({super.key, required this.splashController});

  @override
  State<MySplashPage> createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage>
    with TickerProviderStateMixin {
  late AnimationController _doctorLeftController;
  late AnimationController _doctorRightController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  late Animation<Offset> _doctorLeftOffset;
  late Animation<Offset> _doctorRightOffset;
  late Animation<Offset> _textOffset;
  late Animation<Offset> _buttonOffset;

  @override
  void initState() {
    super.initState();

    // Controllers
    _doctorLeftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _doctorRightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Animations
    _doctorLeftOffset =
        Tween<Offset>(begin: const Offset(-1.2, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _doctorLeftController,
            curve: Curves.easeOutBack,
          ),
        );

    _doctorRightOffset =
        Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _doctorRightController,
            curve: Curves.easeOutBack,
          ),
        );

    _textOffset = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _buttonOffset = Tween<Offset>(begin: const Offset(0, 2.0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
        );

    // Start animations after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _doctorLeftController.forward();
      _doctorRightController.forward();
      Future.delayed(const Duration(seconds: 2), () {
        _textController.forward();
        _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _doctorLeftController.dispose();
    _doctorRightController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            width: Get.width,
            height: Get.height,
            fit: BoxFit.fill,
          ),
          Column(
            children: [
              customAppbar(),
              Expanded(child: content(widget.splashController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget content(SplashController splashController) {
    return Stack(
      children: [
        // Dra
        Positioned(
          left: -Get.width * 0.2,
          bottom: Get.height * 0.35,
          child: SlideTransition(
            position: _doctorLeftOffset,
            child: SvgPicture.asset(
              'assets/images/dra.svg',
              width: Get.width * 0.4,
              height: Get.height * 0.4,
            ),
          ),
        ),

        // Dr
        Positioned(
          right: -Get.width * 0.18,
          bottom: Get.height * 0.35,
          child: SlideTransition(
            position: _doctorRightOffset,
            child: SvgPicture.asset(
              'assets/images/dr.svg',
              width: Get.width * 0.32,
              height: Get.height * 0.32,
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: -Get.width * 0.06,
          child: Container(
            height: Get.height * 0.35,
            width: Get.width * 1.15,
            decoration: BoxDecoration(
              color: CustomColors.primaryLightColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(80),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.23,
                    vertical: Get.height * 0.03,
                  ),
                  child: FadeTransition(
                    opacity: _textController,
                    child: SlideTransition(
                      position: _textOffset,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Bem vindo ao ',
                          style: Get.textTheme.headlineMedium!.copyWith(
                            color: CustomColors.witheColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: 'myBio',
                              style: Get.textTheme.headlineMedium!.copyWith(
                                color: CustomColors.witheColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' o aplicativo que vai facilitar a interação com os seus colegas e controlo das suas actividades hospitalares',
                              style: Get.textTheme.headlineMedium!.copyWith(
                                color: CustomColors.witheColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Button
                SlideTransition(
                  position: _buttonOffset,
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(45),
                    color: CustomColors.secondaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(45),
                      onTap: () => Get.offAllNamed(Routes.login),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Text(
                          'SEGUINTE',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.08,
                    right: Get.width * 0.08,
                    top: Get.width * 0.04,
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'Não mostrar esta tela novamente',
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: CustomColors.witheColor,
                        fontSize: 14,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: CustomColors.primaryDarkerColor,
                    value: splashController.preferences.skipSplash,
                    onChanged: (value) {
                      setState(
                        () => splashController.preferences.skipSplash =
                            value ?? false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Logos
        Positioned(
          bottom: 0,
          child: Container(
            height: Get.height * 0.06,
            width: Get.width,
            color: CustomColors.witheColor,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: Get.width * 0.05),
                    child: SvgPicture.asset('assets/images/consultit_logo.svg'),
                  ),
                ),
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: Get.width * 0.05),
                    child: Image.asset('assets/images/biogest_logo.jpg'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
