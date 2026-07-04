# 04 Resume Wizard

Resume Wizard:

Widget code:

import '/components/button/button_widget.dart';
import '/components/selection_card/selection_card_widget.dart';
import '/components/step_indicator2/step_indicator2_widget.dart';
import '/components/template_tile/template_tile_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'resume_wizard_model.dart';
export 'resume_wizard_model.dart';

class ResumeWizardWidget extends StatefulWidget {
const ResumeWizardWidget({super.key});

static String routeName = 'ResumeWizard';
static String routePath = '/resumeWizard';

@override
State<ResumeWizardWidget> createState() => \_ResumeWizardWidgetState();
}

class \_ResumeWizardWidgetState extends State<ResumeWizardWidget> {
late ResumeWizardModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => ResumeWizardModel());
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
color: FlutterFlowTheme.of(context).secondaryBackground,
shape: BoxShape.rectangle,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Padding(
padding: EdgeInsetsDirectional.fromSTEB(24, 16, 24, 16),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
FlutterFlowIconButton(
borderRadius: 8,
buttonSize: 40,
fillColor: Colors.transparent,
icon: Icon(
Icons.arrow_back_rounded,
color: FlutterFlowTheme.of(context).primaryText,
size: 24,
),
onPressed: () {
print('IconButton pressed ...');
},
),
Text(
'Create New Resume',
style: FlutterFlowTheme.of(context)
.titleMedium
.override(
font: GoogleFonts.lora(
fontWeight: FontWeight.bold,
fontStyle: FlutterFlowTheme.of(context)
.titleMedium
.fontStyle,
),
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle: FlutterFlowTheme.of(context)
.titleMedium
.fontStyle,
lineHeight: 1.4,
),
),
Text(
'Cancel',
style: FlutterFlowTheme.of(context)
.labelLarge
.override(
font: GoogleFonts.josefinSans(
fontWeight: FlutterFlowTheme.of(context)
.labelLarge
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
),
color: FlutterFlowTheme.of(context).error,
letterSpacing: 0.0,
fontWeight: FlutterFlowTheme.of(context)
.labelLarge
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
],
),
),
),
Container(
height: 1,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).alternate,
shape: BoxShape.rectangle,
),
),
],
),
),
Container(
child: Padding(
padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
child: Container(
child: wrapWithModel(
model: \_model.stepIndicatorModel,
updateCallback: () => safeSetState(() {}),
child: StepIndicator2Widget(
total: '4',
current: '1',
),
),
),
),
),
Expanded(
flex: 1,
child: Container(
child: SingleChildScrollView(
primary: false,
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Padding(
padding: EdgeInsets.all(24),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'What\'s your career stage?',
style: FlutterFlowTheme.of(context)
.headlineSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.headlineSmall
.fontStyle,
),
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.headlineSmall
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'We\'ll tailor the AI suggestions based on your experience level.',
style: FlutterFlowTheme.of(context)
.bodyMedium
.override(
font: GoogleFonts.lora(
fontWeight:
FlutterFlowTheme.of(context)
.bodyMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.bodyMedium
.fontStyle,
),
color:
FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.bodyMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.bodyMedium
.fontStyle,
lineHeight: 1.5,
),
),
].divide(SizedBox(height: 4)),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.selectionCardModel1,
updateCallback: () =>
safeSetState(() {}),
child: SelectionCardWidget(
icon: Icon(
Icons.business_center_rounded,
color: FlutterFlowTheme.of(context)
.onPrimary,
size: 24,
),
subtitle: '3+ years of work history',
title: 'Experienced Professional',
selected: true,
),
),
wrapWithModel(
model: _model.selectionCardModel2,
updateCallback: () =>
safeSetState(() {}),
child: SelectionCardWidget(
icon: Icon(
Icons.school_rounded,
color: FlutterFlowTheme.of(context)
.onPrimary,
size: 24,
),
subtitle:
'Recent graduate or new to workforce',
title: 'Fresher / Entry Level',
selected: true,
),
),
wrapWithModel(
model: _model.selectionCardModel3,
updateCallback: () =>
safeSetState(() {}),
child: SelectionCardWidget(
icon: Icon(
Icons.swap_horiz_rounded,
color: FlutterFlowTheme.of(context)
.onPrimary,
size: 24,
),
subtitle: 'Moving to a new industry',
title: 'Career Switcher',
selected: true,
),
),
wrapWithModel(
model: _model.selectionCardModel4,
updateCallback: () =>
safeSetState(() {}),
child: SelectionCardWidget(
icon: Icon(
Icons.person_search_rounded,
color: FlutterFlowTheme.of(context)
.onPrimary,
size: 24,
),
subtitle:
'Student seeking practical experience',
title: 'Internship',
selected: true,
),
),
].divide(SizedBox(height: 16)),
),
Padding(
padding: EdgeInsetsDirectional.fromSTEB(
16, 0, 16, 0),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.textFieldModel1,
updateCallback: () =>
safeSetState(() {}),
child: TextFieldWidget(
label: 'Target Job Title',
labelPresent: true,
helper: '',
helperPresent: false,
leadingIcon: Icon(
Icons.badge_rounded,
color:
FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
leadingIconPresent: true,
trailingIconPresent: false,
hint:
'e.g. Senior Product Designer',
value: '',
onChange: '',
onSubmit: '',
variant: 'outlined',
error: false,
),
),
wrapWithModel(
model: _model.textFieldModel2,
updateCallback: () =>
safeSetState(() {}),
child: TextFieldWidget(
label: 'Industry',
labelPresent: true,
helper: '',
helperPresent: false,
leadingIcon: Icon(
Icons.domain_rounded,
color:
FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
leadingIconPresent: true,
trailingIconPresent: false,
hint: 'e.g. Technology, Healthcare',
value: '',
onChange: '',
onSubmit: '',
variant: 'outlined',
error: false,
),
),
].divide(SizedBox(height: 16)),
),
),
].divide(SizedBox(height: 24)),
),
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
border: Border.all(
color:
FlutterFlowTheme.of(context).alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(24),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Icon(
Icons.description_rounded,
color:
FlutterFlowTheme.of(context)
.secondaryText,
size: 24,
),
Text(
'Job Description (Optional)',
style: FlutterFlowTheme.of(
context)
.labelLarge
.override(
font:
GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.labelLarge
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelLarge
.fontStyle,
),
color: FlutterFlowTheme.of(
context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.labelLarge
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
].divide(SizedBox(width: 8)),
),
wrapWithModel(
model: \_model.textFieldModel3,
updateCallback: () =>
safeSetState(() {}),
child: TextFieldWidget(
label: '',
labelPresent: false,
helper: '',
helperPresent: false,
leadingIconPresent: false,
trailingIconPresent: false,
hint:
'Paste the job description here for real-time ATS optimization...',
value: '',
onChange: '',
onSubmit: '',
variant: 'outlined',
error: false,
),
),
].divide(SizedBox(height: 16)),
),
),
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Select a Template',
style: FlutterFlowTheme.of(context)
.labelLarge
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.primaryText,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
GridView(
padding: EdgeInsets.zero,
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 16,
mainAxisSpacing: 0,
childAspectRatio: 1,
),
primary: false,
shrinkWrap: true,
scrollDirection: Axis.vertical,
children: [
wrapWithModel(
model: _model.templateTileModel1,
updateCallback: () =>
safeSetState(() {}),
child: TemplateTileWidget(
name: 'ATS Modern',
tag: 'BEST FOR TECH',
active: true,
),
),
wrapWithModel(
model: _model.templateTileModel2,
updateCallback: () =>
safeSetState(() {}),
child: TemplateTileWidget(
name: 'Executive',
tag: 'BEST FOR LEADERSHIP',
active: true,
),
),
],
),
].divide(SizedBox(height: 16)),
),
].divide(SizedBox(height: 32)),
),
),
),
],
),
),
),
),
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).secondaryBackground,
shape: BoxShape.rectangle,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Container(
height: 1,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).alternate,
shape: BoxShape.rectangle,
),
),
Padding(
padding: EdgeInsets.all(24),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.buttonModel,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEnd: Icon(
Icons.arrow_forward_rounded,
color:
FlutterFlowTheme.of(context).primaryText,
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
),
].divide(SizedBox(width: 16)),
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
