import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.tryAutoLogin(),
    );
    return GetBuilder<LoginController>(
      builder: (loginController) => Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: CustomColors.backgroundColor,
        body: FormBuilder(
          key: loginController.formKey,
          child: Obx(
            () => loginController.tryLogin.value
                ? const SizedBox.expand()
                : FutureBuilder<List<StoreDTO>>(
                    future: loginController.getStore(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        loginController.stores = snapshot.data!;
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _hero(),
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  24,
                                  22,
                                  22,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: CustomColors.borderColor,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x12000000),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Iniciar sessão',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w800,
                                        color: CustomColors.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Aceda à sua conta para continuar.',
                                      style: TextStyle(
                                        color: CustomColors.mutedTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _userField(),
                                    const SizedBox(height: 15),
                                    _passwordField(loginController),
                                    const SizedBox(height: 15),
                                    _storeField(
                                      loginController,
                                      snapshot.connectionState ==
                                          ConnectionState.waiting,
                                    ),
                                    const SizedBox(height: 8),
                                    _rememberSession(loginController),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: loginController.login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CustomColors.primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Column(
                              children: [
                                Text(
                                  '© 2026 Biogest Clinic. Todos os direitos reservados.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CustomColors.mutedTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Versão 1.0.0',
                                  style: TextStyle(
                                    color: CustomColors.mutedTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _hero() => SizedBox(
    width: double.infinity,
    height: 250,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: CustomColors.primaryDarkerColor),
        const CustomPaint(painter: _LoginHeroShapePainter()),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 54, 30, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/logo.svg', height: 76),
              const SizedBox(height: 14),
              const Text(
                'Biogest Clinic',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'myBio',
                style: TextStyle(
                  color: Color(0xff8FE0D6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 21),
        suffixIcon: suffix,
        filled: true,
        fillColor: CustomColors.witheColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CustomColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CustomColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: CustomColors.primaryColor,
            width: 1.5,
          ),
        ),
      );

  Widget _userField() => FormBuilderTextField(
    name: 'username',
    decoration: _decoration('Utilizador', Icons.person_outline),
    validator: FormBuilderValidators.required(errorText: 'Campo obrigatório'),
  );

  Widget _passwordField(LoginController loginController) => Obx(
    () => FormBuilderTextField(
      name: 'password',
      obscureText: !loginController.mostrarPass.value,
      decoration: _decoration(
        'Senha',
        Icons.lock_outline,
        suffix: IconButton(
          onPressed: () => loginController.mostrarPass.toggle(),
          icon: Icon(
            loginController.mostrarPass.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
      validator: FormBuilderValidators.required(errorText: 'Campo obrigatório'),
    ),
  );

  Widget _storeField(
    LoginController loginController,
    bool loading,
  ) => FormBuilderDropdown<StoreDTO>(
    name: 'store',
    decoration: _decoration(
      loading ? 'A carregar locais...' : 'Local',
      Icons.location_on_outlined,
    ),
    validator: FormBuilderValidators.required(errorText: 'Campo obrigatório'),
    items: loginController.stores
        .map((store) => DropdownMenuItem(value: store, child: Text(store.name)))
        .toList(),
    onChanged: (store) {
      loginController.selectedStoreID = store?.id ?? -1;
      loginController.selectedStoreName = store?.name ?? '';
    },
  );

  Widget _rememberSession(LoginController loginController) => Obx(
    () => CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: CustomColors.primaryColor,
      title: const Text(
        'Manter sessão iniciada',
        style: TextStyle(fontSize: 13, color: CustomColors.textColor),
      ),
      value: loginController.rememberSession.value,
      onChanged: (value) =>
          loginController.rememberSession.value = value ?? true,
    ),
  );
}

class _LoginHeroShapePainter extends CustomPainter {
  const _LoginHeroShapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = CustomColors.secundaryDarkerColor;
    final rightShape = Path()
      ..moveTo(size.width * 0.66, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width * 0.79, size.height * 0.52)
      ..lineTo(size.width * 0.92, size.height * 0.30)
      ..close();
    canvas.drawPath(rightShape, paint);

    final lowerShape = Path()
      ..moveTo(size.width * 0.80, size.height * 0.53)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.61, size.height)
      ..close();
    canvas.drawPath(lowerShape, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
