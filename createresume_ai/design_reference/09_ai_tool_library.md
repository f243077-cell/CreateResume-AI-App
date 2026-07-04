# 09 Ai Tool Library

AIToolLibrary:
Widget code:

import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child5/bottom_nav_child5_widget.dart';
import '/components/button/button_widget.dart';
import '/components/quick_action_chip/quick_action_chip_widget.dart';
import '/components/tool_card/tool_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'a_i_tools_library_model.dart';
export 'a_i_tools_library_model.dart';

class AIToolsLibraryWidget extends StatefulWidget {
const AIToolsLibraryWidget({super.key});

static String routeName = 'AIToolsLibrary';
static String routePath = '/aIToolsLibrary';

@override
State<AIToolsLibraryWidget> createState() => \_AIToolsLibraryWidgetState();
}

class \_AIToolsLibraryWidgetState extends State<AIToolsLibraryWidget> {
late AIToolsLibraryModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => AIToolsLibraryModel());
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
padding: EdgeInsets.all(24),
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
'AI POWER TOOLS',
style: FlutterFlowTheme.of(context)
.headlineSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.w800,
fontStyle: FlutterFlowTheme.of(context)
.headlineSmall
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.onSurface,
letterSpacing: 0.0,
fontWeight: FontWeight.w800,
fontStyle: FlutterFlowTheme.of(context)
.headlineSmall
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'Intelligent Resume Optimization',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight: FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight: FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).accent10,
borderRadius: BorderRadius.circular(9999),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context).accent30,
width: 1,
),
),
child: Padding(
padding:
EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Icon(
Icons.auto_awesome_rounded,
color:
FlutterFlowTheme.of(context).onAccent,
size: 14,
),
Text(
'24 Credits',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.onAccent,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(width: 4)),
),
),
),
),
],
),
),
),
Container(
height: 2,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primary,
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
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
FlutterFlowTheme.of(context).primary,
Color(0xFF1E40AF)
],
stops: [0, 1],
begin: AlignmentDirectional(0, -1),
end: AlignmentDirectional(0, 1),
),
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
),
child: Padding(
padding: EdgeInsets.all(32),
child: Container(
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Icon(
Icons.psychology_rounded,
color:
FlutterFlowTheme.of(context)
.onSurface,
size: 28,
),
Text(
'Resume Scorecard',
style: FlutterFlowTheme.of(
context)
.titleLarge
.override(
font:
GoogleFonts.josefinSans(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
),
color: FlutterFlowTheme.of(
context)
.onSurface,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
].divide(SizedBox(width: 8)),
),
Text(
'Upload your PDF to see how ATS algorithms rank your profile against top job descriptions.',
style: FlutterFlowTheme.of(context)
.bodyMedium
.override(
font: GoogleFonts.lora(
fontWeight:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
),
color:
FlutterFlowTheme.of(context)
.onSurface80,
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
wrapWithModel(
model: \_model.buttonModel1,
updateCallback: () =>
safeSetState(() {}),
child: ButtonWidget(
icon: Icon(
Icons.upload_file_rounded,
color:
FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
iconPresent: true,
iconEndPresent: false,
content: 'Upload & Analyze',
variant: 'secondary',
size: 'medium',
fullWidth: true,
loading: false,
disabled: false,
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
'CONTENT GENERATION',
style: FlutterFlowTheme.of(context)
.labelMedium
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
lineHeight: 1.3,
),
),
wrapWithModel(
model: _model.toolCardModel1,
updateCallback: () => safeSetState(() {}),
child: ToolCardWidget(
desc:
'Generate a tailored cover letter based on any job description.',
icon: Icon(
Icons.history_edu_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 24,
),
tint:
FlutterFlowTheme.of(context).primary,
title: 'Cover Letter GPT',
),
),
wrapWithModel(
model: _model.toolCardModel2,
updateCallback: () => safeSetState(() {}),
child: ToolCardWidget(
desc:
'Turn weak tasks into high-impact, quantified achievements.',
icon: Icon(
Icons.bolt_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 24,
),
tint:
FlutterFlowTheme.of(context).tertiary,
title: 'Bullet Point Rewriter',
),
),
wrapWithModel(
model: _model.toolCardModel3,
updateCallback: () => safeSetState(() {}),
child: ToolCardWidget(
desc:
'Compare your profile with a job post to find missing keywords.',
icon: Icon(
Icons.analytics_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 24,
),
tint: Color(0xFFF59E0B),
title: 'Skill Gap Analyzer',
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
'SMART SUGGESTIONS',
style: FlutterFlowTheme.of(context)
.labelMedium
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
lineHeight: 1.3,
),
),
SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.quickActionChipModel1,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionChipWidget(
icon: Icon(
Icons.spellcheck_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 16,
),
label: 'Action Verbs',
),
),
wrapWithModel(
model: _model.quickActionChipModel2,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionChipWidget(
icon: Icon(
Icons.key_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 16,
),
label: 'ATS Keywords',
),
),
wrapWithModel(
model: _model.quickActionChipModel3,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionChipWidget(
icon: Icon(
Icons.auto_fix_high_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 16,
),
label: 'Summary Pro',
),
),
wrapWithModel(
model: _model.quickActionChipModel4,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionChipWidget(
icon: Icon(
Icons.add_chart_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 16,
),
label: 'Quantify',
),
),
].divide(SizedBox(width: 8)),
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
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
width: 48,
height: 48,
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
Icons.business_rounded,
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
'Target: Top Companies',
style: FlutterFlowTheme.of(
context)
.titleMedium
.override(
font:
GoogleFonts.lora(
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
Text(
'Apply to Google, Meta, or Amazon with a custom-built strategy.',
style: FlutterFlowTheme.of(
context)
.bodySmall
.override(
font:
GoogleFonts.lora(
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
color: FlutterFlowTheme
.of(context)
.secondaryText,
letterSpacing: 0.0,
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
lineHeight: 1.4,
),
),
].divide(SizedBox(height: 4)),
),
),
].divide(SizedBox(width: 16)),
),
wrapWithModel(
model: \_model.buttonModel2,
updateCallback: () =>
safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Start Target Application',
variant: 'outline',
size: 'medium',
fullWidth: true,
loading: false,
disabled: false,
),
),
].divide(SizedBox(height: 16)),
),
),
),
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
Align(
alignment: AlignmentDirectional(0, 1),
child: Container(
child: wrapWithModel(
model: \_model.bottomNavModel,
updateCallback: () => safeSetState(() {}),
child: BottomNavWidget(
child: () => BottomNavChild5Widget(),
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

UserProfileSetting:
Widget Code:
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child6/bottom_nav_child6_widget.dart';
import '/components/button/button_widget.dart';
import '/components/settings_row/settings_row_widget.dart';
import '/components/subscription_card/subscription_card_widget.dart';
import '/components/switch_component/switch_component_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'user_profile_settings_model.dart';
export 'user_profile_settings_model.dart';

class UserProfileSettingsWidget extends StatefulWidget {
const UserProfileSettingsWidget({super.key});

static String routeName = 'UserProfileSettings';
static String routePath = '/userProfileSettings';

@override
State<UserProfileSettingsWidget> createState() =>
\_UserProfileSettingsWidgetState();
}

class \_UserProfileSettingsWidgetState extends State<UserProfileSettingsWidget> {
late UserProfileSettingsModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => UserProfileSettingsModel());
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
Text(
'Profile & Settings',
style: FlutterFlowTheme.of(context)
.titleLarge
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.bold,
fontStyle: FlutterFlowTheme.of(context)
.titleLarge
.fontStyle,
),
color:
FlutterFlowTheme.of(context).primaryText,
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle: FlutterFlowTheme.of(context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
FlutterFlowIconButton(
borderRadius: 8,
buttonSize: 40,
fillColor: Colors.transparent,
icon: Icon(
Icons.edit_note_rounded,
color: FlutterFlowTheme.of(context).primary,
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
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Container(
width: 72,
height: 72,
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context).primary,
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
),
alignment: AlignmentDirectional(0, 0),
child: Text(
'JV',
textAlign: TextAlign.center,
maxLines: 1,
style: FlutterFlowTheme.of(context)
.labelMedium
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.w600,
fontStyle:
FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.onPrimary,
fontSize: 27.36,
letterSpacing: 0.0,
fontWeight: FontWeight.w600,
fontStyle:
FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
lineHeight: 1.3,
),
overflow: TextOverflow.clip,
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
'Julian Vanderbilt',
style: FlutterFlowTheme.of(context)
.titleLarge
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
),
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'julian.v@design.com',
style: FlutterFlowTheme.of(context)
.bodyMedium
.override(
font: GoogleFonts.lora(
fontWeight:
FlutterFlowTheme.of(
context)
.bodyMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
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
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Icon(
Icons.verified_rounded,
color:
FlutterFlowTheme.of(context)
.success,
size: 16,
),
Text(
'Pro Member',
style: FlutterFlowTheme.of(
context)
.labelSmall
.override(
font:
GoogleFonts.josefinSans(
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
color: FlutterFlowTheme.of(
context)
.success,
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
].divide(SizedBox(width: 4)),
),
].divide(SizedBox(height: 4)),
),
),
].divide(SizedBox(width: 24)),
),
wrapWithModel(
model: \_model.subscriptionCardModel,
updateCallback: () => safeSetState(() {}),
child: SubscriptionCardWidget(
plan: 'AI Power User',
price: '\$12.99/mo',
status: 'Active',
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Padding(
padding: EdgeInsetsDirectional.fromSTEB(
16, 0, 16, 0),
child: Container(
child: Text(
'ACCOUNT',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color:
FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
),
),
ClipRRect(
borderRadius: BorderRadius.circular(12),
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.settingsRowModel1,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.primary,
icon: Icon(
Icons.person_outline_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle:
'Manage your contact details',
title: 'Personal Information',
),
),
wrapWithModel(
model: _model.settingsRowModel2,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.primary,
icon: Icon(
Icons.security_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle:
'Password and 2FA settings',
title: 'Login & Security',
),
),
wrapWithModel(
model: _model.settingsRowModel3,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.primary,
icon: Icon(
Icons.link_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle:
'Google, LinkedIn, and Drive',
title: 'Connected Accounts',
),
),
],
),
),
),
].divide(SizedBox(height: 4)),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Padding(
padding: EdgeInsetsDirectional.fromSTEB(
16, 0, 16, 0),
child: Container(
child: Text(
'PREFERENCES',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color:
FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
),
),
ClipRRect(
borderRadius: BorderRadius.circular(12),
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: \_model.settingsRowModel4,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.primary,
icon: Icon(
Icons
.notifications_none_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle: 'Email and push alerts',
title: 'Notifications',
),
),
wrapWithModel(
model: \_model.settingsRowModel5,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.tertiary,
icon: Icon(
Icons.auto_awesome_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle:
'Formal, Creative, or Technical',
title: 'AI Writing Style',
),
),
Container(
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context)
.secondaryBackground,
shape: BoxShape.rectangle,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
Padding(
padding: EdgeInsetsDirectional
.fromSTEB(24, 16, 24, 16),
child: Container(
child: Row(
mainAxisSize:
MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment
.spaceBetween,
crossAxisAlignment:
CrossAxisAlignment
.center,
children: [
Column(
mainAxisSize:
MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment
.start,
crossAxisAlignment:
CrossAxisAlignment
.center,
children: [
Text(
'Dark Mode',
style: FlutterFlowTheme
.of(context)
.labelLarge
.override(
font: GoogleFonts
.josefinSans(
fontWeight: FlutterFlowTheme.of(
context)
.labelLarge
.fontWeight,
fontStyle: FlutterFlowTheme.of(
context)
.labelLarge
.fontStyle,
),
color: FlutterFlowTheme.of(
context)
.primaryText,
letterSpacing:
0.0,
fontWeight: FlutterFlowTheme.of(
context)
.labelLarge
.fontWeight,
fontStyle: FlutterFlowTheme.of(
context)
.labelLarge
.fontStyle,
lineHeight:
1.3,
),
),
Text(
'Switch app appearance',
style: FlutterFlowTheme
.of(context)
.bodySmall
.override(
font: GoogleFonts
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
.secondaryText,
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
lineHeight:
1.4,
),
),
].divide(SizedBox(
height: 4)),
),
wrapWithModel(
model: \_model
.switchModel,
updateCallback: () =>
safeSetState(
() {}),
child:
SwitchComponentWidget(
label: '',
labelPresent: false,
variant: 'iOS',
active: true,
),
),
],
),
),
),
Container(
height: 1,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(
context)
.alternate,
shape: BoxShape.rectangle,
),
),
],
),
),
],
),
),
),
].divide(SizedBox(height: 4)),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Padding(
padding: EdgeInsetsDirectional.fromSTEB(
16, 0, 16, 0),
child: Container(
child: Text(
'SUPPORT',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color:
FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
),
),
ClipRRect(
borderRadius: BorderRadius.circular(12),
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.settingsRowModel6,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.primary,
icon: Icon(
Icons.help_outline_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle: 'FAQ and user guides',
title: 'Help Center',
),
),
wrapWithModel(
model: _model.settingsRowModel7,
updateCallback: () =>
safeSetState(() {}),
child: SettingsRowWidget(
color:
FlutterFlowTheme.of(context)
.primary,
icon: Icon(
Icons.gpp_maybe_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 20,
),
subtitle:
'How we handle your data',
title: 'Privacy Policy',
),
),
],
),
),
),
].divide(SizedBox(height: 4)),
),
wrapWithModel(
model: \_model.buttonModel,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
icon: Icon(
Icons.logout_rounded,
color: FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
iconPresent: true,
iconEndPresent: false,
content: 'Sign Out',
variant: 'destructive',
size: 'medium',
fullWidth: true,
loading: false,
disabled: false,
),
),
Container(
alignment: AlignmentDirectional(0, 0),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'CraftResume AI v2.4.0',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.onBackground,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
Text(
'Made with ❤️ for professionals',
style: FlutterFlowTheme.of(context)
.labelSmall
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.onBackground,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelSmall
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelSmall
.fontStyle,
lineHeight: 1.2,
),
),
].divide(SizedBox(height: 4)),
),
),
Container(
height: 32,
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
Align(
alignment: AlignmentDirectional(0, 1),
child: Container(
child: wrapWithModel(
model: \_model.bottomNavModel,
updateCallback: () => safeSetState(() {}),
child: BottomNavWidget(
child: () => BottomNavChild6Widget(),
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
