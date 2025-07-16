import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';

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
        lineLength: 50,
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
      stepRadius: 16,
      showStepBorder: false,
      steps: [
        EasyStep(
          customStep: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentStep >= 0 ? Color(0xFFDAAD0A) : Color(0xFFD2D2D2),
            ),
            child: currentStep >= 0
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : Container(),
          ),
          title: 'User information',

          // titleStyle: TextStyle(
          //   fontFamily: 'Lato',
          //   fontWeight: FontWeight.w600,
          //   fontSize: 12,
          //   color: currentStep >= 0 ? Color(0xFFDAAD0A) : Color(0xFFD2D2D2),
          // ),
        ),
        EasyStep(
          customStep: Container(
            width: 32,
            height: 32,
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
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : currentStep == 0
                    ? Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFACD02),
                        ),
                      )
                    : Container(),
          ),
          title: 'Subscription',
          // titleStyle: TextStyle(
          //   fontFamily: 'Lato',
          //   fontWeight: FontWeight.w600,
          //   fontSize: 12,
          //   color: currentStep >= 1 ? Color(0xFFDAAD0A) :
          //          currentStep == 0 ? Color(0xFFFACD02) : Color(0xFFD2D2D2),
          // ),
        ),
        EasyStep(
          customStep: Container(
            width: 32,
            height: 32,
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
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : currentStep == 1
                    ? Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFACD02),
                        ),
                      )
                    : Container(),
          ),
          title: 'Store information',
          // titleStyle: TextStyle(
          //   fontFamily: 'Lato',
          //   fontWeight: FontWeight.w600,
          //   fontSize: 12,
          //   color: currentStep >= 2 ? Color(0xFFDAAD0A) :
          //          currentStep == 1 ? Color(0xFFFACD02) : Color(0xFFD2D2D2),
          // ),
        ),
      ],
    );
  }
}
