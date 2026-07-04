# 06 Resume Analyzer

ResumeAnalyzer:

Widget code:

import '/components/accordion_item/accordion_item_widget.dart';
import '/components/analysis_card/analysis_card_widget.dart';
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child2/bottom_nav_child2_widget.dart';
import '/components/button/button_widget.dart';
import '/components/keyword_chip/keyword_chip_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'resume_analyzer_model.dart';
export 'resume_analyzer_model.dart';

class ResumeAnalyzerWidget extends StatefulWidget {
const ResumeAnalyzerWidget({super.key});

static String routeName = 'ResumeAnalyzer';
static String routePath = '/resumeAnalyzer';

@override
State<ResumeAnalyzerWidget> createState() => \_ResumeAnalyzerWidgetState();
}

class \_ResumeAnalyzerWidgetState extends State<ResumeAnalyzerWidget> {
late ResumeAnalyzerModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => ResumeAnalyzerModel());
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
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
FlutterFlowIconButton(
borderRadius: 8,
buttonSize: 40,
fillColor: Colors.transparent,
icon: Icon(
Icons.arrow_back_rounded,
color:
FlutterFlowTheme.of(context).primaryText,
size: 24,
),
onPressed: () {
print('IconButton pressed ...');
},
),
Text(
'Resume Analyzer',
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
].divide(SizedBox(width: 16)),
),
FlutterFlowIconButton(
borderRadius: 8,
buttonSize: 40,
fillColor: Colors.transparent,
icon: Icon(
Icons.share_rounded,
color: FlutterFlowTheme.of(context).primaryText,
size: 20,
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
crossAxisAlignment: CrossAxisAlignment.stretch,
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
borderRadius: BorderRadius.circular(20),
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
CrossAxisAlignment.center,
children: [
Stack(
alignment: AlignmentDirectional(0, 0),
children: [
CircularPercentIndicator(
percent: 0.85,
radius: 60,
lineWidth: 8,
animation: true,
animateFromLastPercent: true,
progressColor:
FlutterFlowTheme.of(context)
.tertiary,
backgroundColor:
FlutterFlowTheme.of(context)
.onPrimary20,
),
Align(
alignment:
AlignmentDirectional(0, 0),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'85',
style: FlutterFlowTheme.of(
context)
.headlineLarge
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.headlineLarge
.fontStyle,
),
letterSpacing: 0.0,
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.headlineLarge
.fontStyle,
lineHeight: 1.2,
),
),
Text(
'ATS SCORE',
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
],
),
),
],
),
Text(
'Great Match!',
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
'Your resume is highly compatible with the Senior Product Designer role at Google.',
textAlign: TextAlign.center,
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
].divide(SizedBox(height: 16)),
),
),
),
),
Text(
'Analysis Breakdown',
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
color: FlutterFlowTheme.of(context)
.secondaryText,
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
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.analysisCardModel1,
updateCallback: () => safeSetState(() {}),
child: AnalysisCardWidget(
description:
'Standard fonts and clear hierarchy detected. Parsable by 98% of systems.',
score: '92/100',
title: 'ATS Compatibility',
tone:
FlutterFlowTheme.of(context).success,
),
),
wrapWithModel(
model: _model.analysisCardModel2,
updateCallback: () => safeSetState(() {}),
child: AnalysisCardWidget(
description:
'Try adding more quantifiable achievements (e.g., \'increased revenue by 20%\').',
score: '65/100',
title: 'Impact & Metrics',
tone:
FlutterFlowTheme.of(context).warning,
),
),
wrapWithModel(
model: _model.analysisCardModel3,
updateCallback: () => safeSetState(() {}),
child: AnalysisCardWidget(
description:
'Strong match for core skills, but missing \'Cross-functional Leadership\'.',
score: '78/100',
title: 'Keyword Match',
tone:
FlutterFlowTheme.of(context).primary,
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
CrossAxisAlignment.stretch,
children: [
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'Keywords & Skills',
style:
FlutterFlowTheme.of(context)
.titleSmall
.override(
font: GoogleFonts.lora(
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleSmall
.fontStyle,
),
letterSpacing: 0.0,
fontWeight:
FontWeight.bold,
fontStyle:
FlutterFlowTheme.of(
context)
.titleSmall
.fontStyle,
lineHeight: 1.4,
),
),
Text(
'12/15 Matched',
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
],
),
Wrap(
spacing: 8,
runSpacing: 8,
alignment: WrapAlignment.start,
crossAxisAlignment:
WrapCrossAlignment.start,
direction: Axis.horizontal,
runAlignment: WrapAlignment.start,
verticalDirection:
VerticalDirection.down,
clipBehavior: Clip.none,
children: [
wrapWithModel(
model: _model.keywordChipModel1,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'User Experience',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel2,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Figma',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel3,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Product Strategy',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel4,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Agile',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel5,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Stakeholder Mgmt',
match: false,
),
),
wrapWithModel(
model: _model.keywordChipModel6,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Data Analysis',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel7,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'User Research',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel8,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Prototyping',
match: true,
),
),
wrapWithModel(
model: _model.keywordChipModel9,
updateCallback: () =>
safeSetState(() {}),
child: KeywordChipWidget(
label: 'Leadership',
match: false,
),
),
],
),
].divide(SizedBox(height: 16)),
),
),
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Text(
'Top Suggestions',
style: FlutterFlowTheme.of(context)
.labelLarge
.override(
font: GoogleFonts.josefinSans(
fontWeight:
FlutterFlowTheme.of(context)
.labelLarge
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(context)
.labelLarge
.fontWeight,
fontStyle:
FlutterFlowTheme.of(context)
.labelLarge
.fontStyle,
lineHeight: 1.3,
),
),
ClipRRect(
borderRadius: BorderRadius.circular(12),
child: Container(
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
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.accordionItemModel1,
updateCallback: () =>
safeSetState(() {}),
child: AccordionItemWidget(
title: 'Quantify Achievements',
content:
'Your experience section lacks numbers. AI suggests: \'Led a team of 5\' or \'Reduced churn by 15%\'.',
open: true,
last: false,
),
),
wrapWithModel(
model: _model.accordionItemModel2,
updateCallback: () =>
safeSetState(() {}),
child: AccordionItemWidget(
title: 'Missing Soft Skills',
content:
'The job description emphasizes \'Mentorship\'. Consider adding this to your summary.',
open: true,
last: true,
),
),
].divide(SizedBox(height: 0)),
),
),
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
model: _model.buttonModel,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
icon: Icon(
Icons.auto_fix_high_rounded,
color:
FlutterFlowTheme.of(context).primaryText,
size: 24,
),
iconPresent: true,
iconEndPresent: false,
content: 'One-Click AI Optimize',
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
Icons.file_download_rounded,
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
child: () => BottomNavChild2Widget(),
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
