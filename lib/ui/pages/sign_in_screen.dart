import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geo_attendance_system/controllers/sign_in_controller.dart';
import 'package:geo_attendance_system/res/strings.dart';
import 'package:geo_attendance_system/utils/assets.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';
import 'package:geo_attendance_system/utils/ui_helper.dart';
import 'package:geo_attendance_system/utils/validator/validator.dart';
import 'package:geo_attendance_system/utils/widget/app_primary_button.dart';
import 'package:geo_attendance_system/utils/widget/app_text_field.dart';
import 'package:get/get.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({Key key}) : super(key: key);

  final _signInController = Get.put(SignInController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
              padding: EdgeInsets.symmetric(horizontal: Sizes.s16),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Assets.techAi,
                          height: Sizes.s100, width: Sizes.s100),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTextField(
                            isBoarder: true,
                            controller:
                                _signInController.usernameTextController,
                            labelText: Strings.email,
                            labelStyle: TextStyles.labelStyle,
                            validator: Validator.validateEmail,
                          ),
                          C16(),
                          GetBuilder<SignInController>(builder: (controller) {
                            return AppTextField(
                                isBoarder: true,
                                controller:
                                    _signInController.passwordTextController,
                                labelStyle: TextStyles.labelStyle,
                                labelText: Strings.password,
                                passwordVisible:
                                    _signInController.passwordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _signInController.passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: _signInController.toggleVisible,
                                ),
                                validator: Validator.validatePassword);
                          }),
                          C7(),
                          Visibility(
                            visible: false,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                  // onTap: () => Get.to(() =>
                                  //
                                  //     ForgotPassword()
                                  // ),
                                  child: Text(
                                Strings.forgotPassword,
                                style: TextStyles.url
                                    .copyWith(fontSize: FontSizes.s13),
                              )),
                            ),
                          ),
                          C30(),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: Sizes.s30),
                            width: double.infinity,
                            child: AppPrimaryButton(
                              text: Strings.signIn,
                              onPressed: () => _login(),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Obx(
                            () => Text(
                              Strings.version +
                                  "${_signInController.projectVersion.value}",
                              style: TextStyles.defaultRegular
                                  .copyWith(fontSize: FontSizes.s11),
                            ),
                          ),
                          Text(
                            Strings.poweredByTechneAi,
                            style: TextStyles.defaultRegular
                                .copyWith(fontSize: FontSizes.s9),
                          ),
                          C16(),
                        ],
                      )
                    ],
                  )))),
    );
  }

  _login() async {
    if (!isFormValid(_formKey)) return;
    _signInController.userLogin();
  }
}
