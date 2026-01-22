import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorStepper extends StatelessWidget {
  final int currentStep;

  const VendorStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return EasyStepper(
      activeStep: currentStep,
      lineStyle: LineStyle(
        lineLength: 40,
        lineSpace: 0,
        lineType: LineType.normal,
        defaultLineColor: Color(0xFFD2D2D2),
        finishedLineColor: Color(0xFFDAAD0A),
        activeLineColor: Color(0xFFFACD02),
      ),
      activeStepTextColor: Color(0xFFFACD02),
      finishedStepTextColor: Color(0xFFDAAD0A),
      internalPadding: 0,
      showLoadingAnimation: false,
      stepRadius: 14,
      showStepBorder: false,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      steps: [
        EasyStep(
          customStep: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentStep >= 0 ? Color(0xFFDAAD0A) : Color(0xFFD2D2D2),
            ),
            child: currentStep >= 0
                ? Icon(Icons.check, color: Colors.white, size: 16)
                : Container(),
          ),
          title: 'user_information'.tr,
        ),
        EasyStep(
          customStep: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentStep >= 1
                  ? Color(0xFFDAAD0A)
                  : currentStep == 0
                      ? Color(0xFFFACD02)
                      : Color(0xFFD2D2D2),
              border: currentStep == 0
                  ? Border.all(color: Color(0xFFFACD02), width: 2)
                  : null,
            ),
            child: currentStep >= 1
                ? Icon(Icons.check, color: Colors.white, size: 16)
                : currentStep == 0
                    ? Container(
                        margin: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFACD02),
                        ),
                      )
                    : Container(),
          ),
          title: 'subscription'.tr,
        ),
        EasyStep(
          customStep: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentStep >= 2
                  ? Color(0xFFDAAD0A)
                  : currentStep == 1
                      ? Color(0xFFFACD02)
                      : Color(0xFFD2D2D2),
              border: currentStep == 1
                  ? Border.all(color: Color(0xFFFACD02), width: 2)
                  : null,
            ),
            child: currentStep >= 2
                ? Icon(Icons.check, color: Colors.white, size: 16)
                : currentStep == 1
                    ? Container(
                        margin: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFACD02),
                        ),
                      )
                    : Container(),
          ),
          title: 'store_information'.tr,
        ),
      ],
    );
  }
}
