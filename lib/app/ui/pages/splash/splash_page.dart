import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../routes/index.dart';
import '../../index.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (splashController) =>
          _PremiumSplash(splashController: splashController),
    );
  }
}

class _PremiumSplash extends StatelessWidget {
  final SplashController splashController;

  const _PremiumSplash({required this.splashController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.primaryDarkerColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(children: [_buildHero(), _buildWelcomeCard(context)]);
        },
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/splash_premium_hero.png',
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
          ),
          Positioned(
            top: Get.height * 0.08,
            left: Get.width * 0.3,
            child: SvgPicture.asset('assets/images/logo.svg', height: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Positioned(
      top: Get.height * 0.5,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.08,
          vertical: Get.height * 0.07,
        ),
        decoration: const BoxDecoration(
          color: CustomColors.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
        ),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  color: CustomColors.textColor,
                  fontFamily: 'OpenSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                children: [
                  TextSpan(text: 'Bem-vindo ao '),
                  TextSpan(
                    text: 'myBio',
                    style: TextStyle(color: CustomColors.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tudo o que precisa para\nacompanhar o seu dia clínico.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomColors.textColor,
                fontFamily: 'OpenSans',
                fontSize: 17,
                height: 1.55,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () => Get.offAllNamed(Routes.login),
                style: FilledButton.styleFrom(
                  backgroundColor: CustomColors.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Começar'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(
                  value: splashController.preferences.skipSplash,
                  activeTrackColor: CustomColors.primaryColor,
                  onChanged: (value) {
                    splashController.preferences.skipSplash = value;
                    splashController.update();
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      splashController.preferences.skipSplash =
                          !splashController.preferences.skipSplash;
                      splashController.update();
                    },
                    child: const Text(
                      'Não mostrar novamente',
                      style: TextStyle(
                        color: CustomColors.mutedTextColor,
                        fontFamily: 'OpenSans',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
