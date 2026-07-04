# 07 Company Apply Hub

CompanyApplyHub:

Widget code:

import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child3/bottom_nav_child3_widget.dart';
import '/components/button/button_widget.dart';
import '/components/company_card/company_card_widget.dart';
import '/components/gap_item/gap_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'company_apply_hub_model.dart';
export 'company_apply_hub_model.dart';

class CompanyApplyHubWidget extends StatefulWidget {
const CompanyApplyHubWidget({super.key});

static String routeName = 'CompanyApplyHub';
static String routePath = '/companyApplyHub';

@override
State<CompanyApplyHubWidget> createState() => \_CompanyApplyHubWidgetState();
}

class \_CompanyApplyHubWidgetState extends State<CompanyApplyHubWidget> {
late CompanyApplyHubModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => CompanyApplyHubModel());
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
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Company Apply Hub',
style: FlutterFlowTheme.of(context)
.titleLarge
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.bold,
fontStyle: FlutterFlowTheme.of(context)
.titleLarge
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.primaryText,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle: FlutterFlowTheme.of(context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'Tailor your application for top-tier roles',
style: FlutterFlowTheme.of(context)
.bodySmall
.override(
font: GoogleFonts.lora(
fontWeight: FlutterFlowTheme.of(context)
.bodySmall
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.bodySmall
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight: FlutterFlowTheme.of(context)
.bodySmall
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.bodySmall
.fontStyle,
lineHeight: 1.4,
),
),
].divide(SizedBox(height: 4)),
),
FlutterFlowIconButton(
borderRadius: 8,
buttonSize: 40,
fillColor: Colors.transparent,
icon: Icon(
Icons.search_rounded,
color: FlutterFlowTheme.of(context).primaryText,
size: 24,
),
onPressed: () {
print('IconButton pressed ...');
},
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
Text(
'Target Companies',
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
.onBackground,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
wrapWithModel(
model: _model.companyCardModel1,
updateCallback: () => safeSetState(() {}),
child: CompanyCardWidget(
industry: 'Software & Cloud',
logoSlug:
'https://cdn.simpleicons.org/google/d4af37.svg',
name: 'Google',
selected: true,
),
),
wrapWithModel(
model: _model.companyCardModel2,
updateCallback: () => safeSetState(() {}),
child: CompanyCardWidget(
industry: 'Enterprise Software',
logoSlug:
'https://cdn.simpleicons.org/microsoft/d4af37.svg',
name: 'Microsoft',
selected: true,
),
),
wrapWithModel(
model: _model.companyCardModel3,
updateCallback: () => safeSetState(() {}),
child: CompanyCardWidget(
industry: 'E-commerce & AWS',
logoSlug:
'https://cdn.simpleicons.org/amazon/d4af37.svg',
name: 'Amazon',
selected: true,
),
),
].divide(SizedBox(height: 16)),
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
MainAxisAlignment.spaceBetween,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'Profile Gap Analysis',
style:
FlutterFlowTheme.of(context)
.titleMedium
.override(
font: GoogleFonts.lora(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleMedium
.fontStyle,
),
letterSpacing: 0.0,
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleMedium
.fontStyle,
lineHeight: 1.4,
),
),
],
),
Text(
'Comparing your profile with Google\'s Senior AI Strategist requirements:',
style: FlutterFlowTheme.of(context)
.bodySmall
.override(
font: GoogleFonts.lora(
fontWeight:
FlutterFlowTheme.of(
context)
.bodySmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.bodySmall
.fontStyle,
),
color:
FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.bodySmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.bodySmall
.fontStyle,
lineHeight: 1.4,
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.gapItemModel1,
updateCallback: () =>
safeSetState(() {}),
child: GapItemWidget(
label:
'10+ years Architecture Experience',
met: true,
),
),
wrapWithModel(
model: _model.gapItemModel2,
updateCallback: () =>
safeSetState(() {}),
child: GapItemWidget(
label:
'Neural Network Orchestration',
met: true,
),
),
wrapWithModel(
model: _model.gapItemModel3,
updateCallback: () =>
safeSetState(() {}),
child: GapItemWidget(
label:
'Leadership of 10+ person teams',
met: true,
),
),
wrapWithModel(
model: _model.gapItemModel4,
updateCallback: () =>
safeSetState(() {}),
child: GapItemWidget(
label:
'Google Cloud Platform Certification',
met: false,
),
),
].divide(SizedBox(height: 8)),
),
Padding(
padding:
EdgeInsetsDirectional.fromSTEB(
8, 0, 8, 0),
child: Container(
child: Container(
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context)
.info10,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
),
child: Padding(
padding: EdgeInsets.all(16),
child: Container(
child: Row(
mainAxisSize:
MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment
.center,
children: [
Icon(
Icons.lightbulb_rounded,
color:
FlutterFlowTheme.of(
context)
.onInfo,
size: 20,
),
Expanded(
flex: 1,
child: Text(
'AI Suggestion: Mention your \'Urban Restoration\' project to bridge the infrastructure gap.',
style: FlutterFlowTheme
.of(context)
.bodySmall
.override(
font:
GoogleFonts
.lora(
fontWeight: FlutterFlowTheme.of(
context)
.bodySmall
.fontWeight,
fontStyle: FlutterFlowTheme.of(
context)
.bodySmall
.fontStyle,
),
color: FlutterFlowTheme.of(
context)
.onInfo,
letterSpacing:
0.0,
fontWeight: FlutterFlowTheme.of(
context)
.bodySmall
.fontWeight,
fontStyle: FlutterFlowTheme.of(
context)
.bodySmall
.fontStyle,
lineHeight: 1.4,
),
),
),
].divide(
SizedBox(width: 8)),
),
),
),
),
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
'Tailored Documents',
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
.onBackground,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(24),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
),
alignment:
AlignmentDirectional(0, 0),
child: Icon(
Icons.description_rounded,
color:
FlutterFlowTheme.of(context)
.onSurface,
size: 24,
),
),
Expanded(
flex: 1,
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'Tailored Resume - Google',
style: FlutterFlowTheme.of(
context)
.bodyMedium
.override(
font:
GoogleFonts.lora(
fontWeight:
FontWeight.w600,
fontStyle:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
),
letterSpacing: 0.0,
fontWeight:
FontWeight.w600,
fontStyle:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
lineHeight: 1.5,
),
),
Text(
'Optimized for ATS & Google-specific keywords',
style: FlutterFlowTheme.of(
context)
.labelSmall
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
),
wrapWithModel(
model: \_model.buttonModel1,
updateCallback: () =>
safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Edit',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
].divide(SizedBox(width: 16)),
),
),
),
),
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(24),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
),
alignment:
AlignmentDirectional(0, 0),
child: Icon(
Icons.history_edu_rounded,
color:
FlutterFlowTheme.of(context)
.tertiary,
size: 24,
),
),
Expanded(
flex: 1,
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'Cover Letter - Google',
style: FlutterFlowTheme.of(
context)
.bodyMedium
.override(
font:
GoogleFonts.lora(
fontWeight:
FontWeight.w600,
fontStyle:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
),
letterSpacing: 0.0,
fontWeight:
FontWeight.w600,
fontStyle:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
lineHeight: 1.5,
),
),
Text(
'Personalized for the hiring manager',
style: FlutterFlowTheme.of(
context)
.labelSmall
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
),
wrapWithModel(
model: \_model.buttonModel2,
updateCallback: () =>
safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Edit',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
].divide(SizedBox(width: 16)),
),
),
),
),
].divide(SizedBox(height: 16)),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Application Status',
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
.onBackground,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Expanded(
flex: 1,
child: Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
border: Border.all(
color:
FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(16),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'12',
style: FlutterFlowTheme.of(
context)
.titleLarge
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.onSurface,
letterSpacing: 0.0,
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'Applied',
style: FlutterFlowTheme.of(
context)
.labelSmall
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
),
),
),
),
Expanded(
flex: 1,
child: Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
border: Border.all(
color:
FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(16),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'4',
style: FlutterFlowTheme.of(
context)
.titleLarge
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.tertiary,
letterSpacing: 0.0,
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'Interviews',
style: FlutterFlowTheme.of(
context)
.labelSmall
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
),
),
),
),
Expanded(
flex: 1,
child: Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
border: Border.all(
color:
FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(16),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'2',
style: FlutterFlowTheme.of(
context)
.titleLarge
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.success,
letterSpacing: 0.0,
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'Offers',
style: FlutterFlowTheme.of(
context)
.labelSmall
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme
.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
),
),
),
),
].divide(SizedBox(width: 8)),
),
].divide(SizedBox(height: 16)),
),
].divide(SizedBox(height: 24)),
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
model: _model.buttonModel3,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
icon: Icon(
Icons.auto_awesome_rounded,
color:
FlutterFlowTheme.of(context).primaryText,
size: 24,
),
iconPresent: true,
iconEndPresent: false,
content: 'Generate Tailored Kit',
variant: 'primary',
size: 'medium',
fullWidth: true,
loading: false,
disabled: false,
),
),
),
FlutterFlowIconButton(
borderRadius: 8,
buttonSize: 40,
fillColor: FlutterFlowTheme.of(context)
.secondaryBackground,
icon: Icon(
Icons.share_rounded,
color: FlutterFlowTheme.of(context).primaryText,
size: 24,
),
onPressed: () {
print('IconButton pressed ...');
},
),
].divide(SizedBox(width: 16)),
),
),
),
],
),
),
Align(
alignment: AlignmentDirectional(0, 1),
child: Container(
child: wrapWithModel(
model: \_model.bottomNavModel,
updateCallback: () => safeSetState(() {}),
child: BottomNavWidget(
child: () => BottomNavChild3Widget(),
),
),
),
),
],
),
),
);
}
}
