# 01 Onboarding

OnBoarding:

Widget code:

import '/components/button/button_widget.dart';
import '/components/onboarding_slide/onboarding_slide_widget.dart';
import '/components/step_indicator/step_indicator_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'onboarding_model.dart';
export 'onboarding_model.dart';

class OnboardingWidget extends StatefulWidget {
const OnboardingWidget({super.key});

static String routeName = 'Onboarding';
static String routePath = '/onboarding';

@override
State<OnboardingWidget> createState() => \_OnboardingWidgetState();
}

class \_OnboardingWidgetState extends State<OnboardingWidget> {
late OnboardingModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => OnboardingModel());
}

@override
void dispose() {
\_model.dispose();

    super.dispose();

}

@override
Widget build(BuildContext context) {
return GestureDetector(
onTap: () {
FocusScope.of(context).unfocus();
FocusManager.instance.primaryFocus?.unfocus();
},
child: Scaffold(
key: scaffoldKey,
backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
body: Column(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primaryBackground,
shape: BoxShape.rectangle,
),
child: Padding(
padding: EdgeInsetsDirectional.fromSTEB(16, 24, 16, 24),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.end,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.buttonModel1,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Skip',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
],
),
),
),
),
Expanded(
flex: 1,
child: Padding(
padding: EdgeInsets.all(32),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Container(
decoration: BoxDecoration(),
child: wrapWithModel(
model: _model.onboardingSlideModel1,
updateCallback: () => safeSetState(() {}),
child: OnboardingSlideWidget(
description:
'Craft professional, high-impact resumes in minutes using our advanced AI engine trained on winning profiles.',
isActive: true,
lottieDesc:
'https://dimg.dreamflow.cloud/v1/lottie/AI+robot+writing+a+document+with+sparkles',
title: 'AI-Powered Resume Builder',
),
),
),
wrapWithModel(
model: _model.onboardingSlideModel2,
updateCallback: () => safeSetState(() {}),
child: OnboardingSlideWidget(
description:
'Our intelligent analyzer ensures your resume is 100% ATS-friendly, targeting the exact keywords recruiters look for.',
isActive: false,
lottieDesc:
'https://dimg.dreamflow.cloud/v1/lottie/Magnifying+glass+scanning+a+resume+with+green+checkmarks',
title: 'Beat the Bots',
),
),
wrapWithModel(
model: _model.onboardingSlideModel3,
updateCallback: () => safeSetState(() {}),
child: OnboardingSlideWidget(
description:
'Directly apply to top companies like Google and Meta with tailored cover letters generated specifically for each role.',
isActive: false,
lottieDesc:
'https://dimg.dreamflow.cloud/v1/lottie/Person+climbing+a+career+ladder+towards+a+trophy',
title: 'Land Your Dream Role',
),
),
],
),
),
),
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primaryBackground,
shape: BoxShape.rectangle,
),
child: Padding(
padding: EdgeInsets.all(32),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.stepIndicatorModel1,
updateCallback: () => safeSetState(() {}),
child: StepIndicatorWidget(
active: true,
),
),
wrapWithModel(
model: _model.stepIndicatorModel2,
updateCallback: () => safeSetState(() {}),
child: StepIndicatorWidget(
active: false,
),
),
wrapWithModel(
model: _model.stepIndicatorModel3,
updateCallback: () => safeSetState(() {}),
child: StepIndicatorWidget(
active: false,
),
),
].divide(SizedBox(width: 4)),
),
wrapWithModel(
model: \_model.buttonModel2,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEnd: Icon(
Icons.arrow_forward_rounded,
color: FlutterFlowTheme.of(context).primaryText,
size: 24,
),
iconEndPresent: true,
content: 'Next Step',
variant: 'primary',
size: 'large',
fullWidth: true,
loading: false,
disabled: false,
),
),
].divide(SizedBox(height: 32)),
),
),
),
),
Container(
height: 120,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).secondary5,
shape: BoxShape.rectangle,
),
child: Stack(
alignment: AlignmentDirectional(-1, -1),
children: [
Opacity(
opacity: 0.1,
child: Align(
alignment: AlignmentDirectional(-1, 1),
child: Container(
width: 100,
height: 100,
child: Icon(
Icons.architecture_rounded,
color: FlutterFlowTheme.of(context).primary,
size: 120,
),
),
),
),
Opacity(
opacity: 0.1,
child: Align(
alignment: AlignmentDirectional(1, 1),
child: Container(
width: 100,
height: 100,
child: Icon(
Icons.diamond_rounded,
color: FlutterFlowTheme.of(context).primary,
size: 120,
),
),
),
),
],
),
),
],
),
),
);
}
}
