# 03 Home Dashboard

HomeDashboard:

Widget code:
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child/bottom_nav_child_widget.dart';
import '/components/button/button_widget.dart';
import '/components/quick_action/quick_action_widget.dart';
import '/components/resume_card/resume_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'home_dashboard_model.dart';
export 'home_dashboard_model.dart';

class HomeDashboardWidget extends StatefulWidget {
const HomeDashboardWidget({super.key});

static String routeName = 'HomeDashboard';
static String routePath = '/homeDashboard';

@override
State<HomeDashboardWidget> createState() => \_HomeDashboardWidgetState();
}

class \_HomeDashboardWidgetState extends State<HomeDashboardWidget> {
late HomeDashboardModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => HomeDashboardModel());
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
'Good morning,',
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
Text(
'Alex Rivera',
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
].divide(SizedBox(height: 4)),
),
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primary,
shape: BoxShape.circle,
),
alignment: AlignmentDirectional(0, 0),
child: Text(
'AR',
textAlign: TextAlign.center,
maxLines: 1,
style: FlutterFlowTheme.of(context)
.labelMedium
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.w600,
fontStyle: FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
),
color:
FlutterFlowTheme.of(context).onPrimary,
fontSize: 15.2,
letterSpacing: 0.0,
fontWeight: FontWeight.w600,
fontStyle: FlutterFlowTheme.of(context)
.labelMedium
.fontStyle,
lineHeight: 1.3,
),
overflow: TextOverflow.clip,
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
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.quickActionModel1,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionWidget(
icon: Icon(
Icons.add_circle_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 24,
),
label: 'Build New Resume',
tone: FlutterFlowTheme.of(context)
.primary,
),
),
),
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.quickActionModel2,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionWidget(
icon: Icon(
Icons.analytics_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 24,
),
label: 'Analyze Resume',
tone: FlutterFlowTheme.of(context)
.tertiary,
),
),
),
].divide(SizedBox(width: 16)),
),
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.quickActionModel3,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionWidget(
icon: Icon(
Icons.business_center_rounded,
color:
FlutterFlowTheme.of(context)
.primary,
size: 24,
),
label: 'Apply to Top Cos',
tone: FlutterFlowTheme.of(context)
.secondary,
),
),
),
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.quickActionModel4,
updateCallback: () =>
safeSetState(() {}),
child: QuickActionWidget(
icon: Icon(
Icons.help,
color:
FlutterFlowTheme.of(context)
.primary,
size: 24,
),
label: 'Create Cover Letter',
tone: FlutterFlowTheme.of(context)
.info,
),
),
),
].divide(SizedBox(width: 16)),
),
].divide(SizedBox(height: 16)),
),
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
FlutterFlowTheme.of(context).primary,
Color(0xFF1E40AF)
],
stops: [0, 1],
begin: AlignmentDirectional(-1, 0),
end: AlignmentDirectional(1, 0),
),
borderRadius: BorderRadius.circular(12),
shape: BoxShape.rectangle,
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
'AI Resume Score',
style: FlutterFlowTheme.of(
context)
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
color:
FlutterFlowTheme.of(
context)
.onSurface,
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
'Your \'Product Designer\' resume is 12% stronger than last week.',
style: FlutterFlowTheme.of(
context)
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
FlutterFlowTheme.of(
context)
.onSurface80,
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
Icon(
Icons.auto_fix_high_rounded,
color: FlutterFlowTheme.of(context)
.onSurface,
size: 32,
),
].divide(SizedBox(width: 16)),
),
),
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'Recent Resumes',
style: FlutterFlowTheme.of(context)
.titleMedium
.override(
font: GoogleFonts.lora(
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.titleMedium
.fontStyle,
),
letterSpacing: 0.0,
fontWeight: FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(context)
.titleMedium
.fontStyle,
lineHeight: 1.4,
),
),
wrapWithModel(
model: _model.buttonModel,
updateCallback: () =>
safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'View All',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
],
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
wrapWithModel(
model: _model.resumeCardModel1,
updateCallback: () =>
safeSetState(() {}),
child: ResumeCardWidget(
date: 'Edited 2h ago',
score: '94',
title:
'Senior Product Designer - Google',
),
),
wrapWithModel(
model: _model.resumeCardModel2,
updateCallback: () =>
safeSetState(() {}),
child: ResumeCardWidget(
date: 'Edited yesterday',
score: '82',
title: 'UX Researcher - Meta',
),
),
wrapWithModel(
model: _model.resumeCardModel3,
updateCallback: () =>
safeSetState(() {}),
child: ResumeCardWidget(
date: 'Edited 3 days ago',
score: '76',
title: 'General Creative Portfolio',
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
Align(
alignment: AlignmentDirectional(0, 1),
child: Container(
child: wrapWithModel(
model: \_model.bottomNavModel,
updateCallback: () => safeSetState(() {}),
child: BottomNavWidget(
child: () => BottomNavChildWidget(),
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
