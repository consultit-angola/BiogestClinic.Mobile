import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/index.dart';
import '../../data/models/index.dart';
import '../index.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.tryAutoLogin();
    });

    return GetBuilder<LoginController>(
      builder: (loginController) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: FormBuilder(
          key: loginController.formKey,
          child: Stack(
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
                  Obx(() {
                    return loginController.tryLogin.value
                        ? SizedBox.shrink()
                        : form();
                  }),
                ],
              ),

              doctors(),
            ],
          ),
        ),
      ),
    );
  }

  Widget form() {
    return Padding(
      padding: EdgeInsets.only(top: Get.height * 0.04),
      child: Container(
        height: Get.height * 0.57,
        width: Get.width,
        decoration: BoxDecoration(
          color: CustomColors.primaryLightColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(65),
        ),
        child: FutureBuilder(
          future: controller.getStore(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              controller.stores = asyncSnapshot.data as List<StoreDTO>;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _textFieldUser(controller),
                    _textFieldPassword(controller),
                    _dropdownField(controller),
                    _buttonLogin(controller),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _textFieldUser(LoginController loginController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.03),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.witheColor,
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: FormBuilderTextField(
          name: 'username',
          decoration: InputDecoration(
            hintText: 'Utilizador',
            labelText: 'Utilizador',
            prefixIcon: Icon(Icons.person_outlined),
            border: InputBorder.none,
          ),
          errorBuilder: (context, errorText) => SizedBox.shrink(),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
          ]),
        ),
      ),
    );
  }

  Widget _textFieldPassword(LoginController loginController) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.witheColor,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Obx(
        () => FormBuilderTextField(
          name: 'password',
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_open_outlined),
            suffixIcon: InkWell(
              onTap: () => loginController.mostrarPass.value =
                  !loginController.mostrarPass.value,
              child: Icon(
                loginController.mostrarPass.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
            border: InputBorder.none,
          ),
          obscureText: !loginController.mostrarPass.value,
          errorBuilder: (context, errorText) => SizedBox.shrink(),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
          ]),
        ),
      ),
    );
  }

  Widget _dropdownField(LoginController loginController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.03),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.witheColor,
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: FormBuilderDropdown<StoreDTO>(
          name: 'store',
          decoration: const InputDecoration(
            labelText: 'Local',
            hintText: 'Selecione um local',
            prefixIcon: Icon(Icons.local_hospital_outlined),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          errorBuilder: (context, errorText) => SizedBox.shrink(),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
          ]),
          items: loginController.stores
              .map(
                (store) => DropdownMenuItem<StoreDTO>(
                  value: store,
                  child: Text(store.name),
                ),
              )
              .toList(),
          onChanged: (value) =>
              loginController.selectedStoreID = value?.id ?? -1,
        ),
      ),
    );
  }

  Widget _buttonLogin(LoginController loginController) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(45),
      color: CustomColors.primaryLightColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(45),
        onTap: loginController.login,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Entrar',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget doctors() {
    return Stack(
      children: [
        // Dra
        Positioned(
          left: -Get.width * 0.05,
          bottom: 0,
          child: SvgPicture.asset(
            'assets/images/dra.svg',
            width: Get.width * 0.3,
            height: Get.height * 0.3,
          ),
        ),

        // Dr
        Positioned(
          right: -Get.width * 0.05,
          bottom: 0,
          child: SvgPicture.asset(
            'assets/images/dr.svg',
            width: Get.width * 0.25,
            height: Get.height * 0.25,
          ),
        ),
      ],
    );
  }
}
