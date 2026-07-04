# 05 Resume Editor

ResumeEditor:
Widget code:

import '/components/button/button_widget.dart';
import '/components/editor_field/editor_field_widget.dart';
import '/components/section_handle/section_handle_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'resume_editor_model.dart';
export 'resume_editor_model.dart';

class ResumeEditorWidget extends StatefulWidget {
const ResumeEditorWidget({super.key});

static String routeName = 'ResumeEditor';
static String routePath = '/resumeEditor';

@override
State<ResumeEditorWidget> createState() => \_ResumeEditorWidgetState();
}

class \_ResumeEditorWidgetState extends State<ResumeEditorWidget> {
late ResumeEditorModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => ResumeEditorModel());
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
color: FlutterFlowTheme.of(context).secondary,
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
Icons.close_rounded,
color: FlutterFlowTheme.of(context).primary,
size: 24,
),
onPressed: () {
print('IconButton pressed ...');
},
),
Text(
'CRAFT RESUME AI',
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
color: FlutterFlowTheme.of(context).primary,
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
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.buttonModel1,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'EXPORT',
variant: 'outline',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
wrapWithModel(
model: _model.buttonModel2,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'SAVE',
variant: 'primary',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
].divide(SizedBox(width: 8)),
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
'PREVIEW',
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
color:
FlutterFlowTheme.of(context)
.onBackground,
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
Text(
'FULLSCREEN',
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
],
),
Container(
height: 240,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(32),
child: Container(
child: Container(
height: 176,
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
width: 40,
height: 1,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(
context)
.primary,
shape: BoxShape.rectangle,
),
),
Text(
'JULIAN VANDERBILT',
textAlign: TextAlign.center,
style:
FlutterFlowTheme.of(context)
.titleLarge
.override(
font: GoogleFonts
.josefinSans(
fontWeight:
FlutterFlowTheme.of(
context)
.titleLarge
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
),
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.titleLarge
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.titleLarge
.fontStyle,
lineHeight: 1.3,
),
),
Text(
'SENIOR ARCHITECTURAL DESIGNER',
style:
FlutterFlowTheme.of(context)
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
.onSurface,
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
Divider(
height: 16,
thickness: 1,
indent: 40,
endIndent: 40,
color:
FlutterFlowTheme.of(context)
.alternate,
),
Text(
'Expert in Art Deco restoration and modern structural AI implementation. Proven track record of delivering high-profile commercial projects.',
textAlign: TextAlign.center,
maxLines: 3,
style:
FlutterFlowTheme.of(context)
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
overflow: TextOverflow.ellipsis,
),
].divide(SizedBox(height: 8)),
),
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
'RESUME STRUCTURE',
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
.onBackground,
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
model: _model.sectionHandleModel1,
updateCallback: () => safeSetState(() {}),
child: SectionHandleWidget(
icon: Icon(
Icons.description_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 20,
),
title: 'Professional Summary',
),
),
wrapWithModel(
model: _model.sectionHandleModel2,
updateCallback: () => safeSetState(() {}),
child: SectionHandleWidget(
icon: Icon(
Icons.business_center_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 20,
),
title: 'Work Experience',
),
),
wrapWithModel(
model: _model.sectionHandleModel3,
updateCallback: () => safeSetState(() {}),
child: SectionHandleWidget(
icon: Icon(
Icons.school_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 20,
),
title: 'Education & Credentials',
),
),
wrapWithModel(
model: _model.sectionHandleModel4,
updateCallback: () => safeSetState(() {}),
child: SectionHandleWidget(
icon: Icon(
Icons.diamond_rounded,
color: FlutterFlowTheme.of(context)
.primary,
size: 20,
),
title: 'Core Proficiencies',
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
'WORK EXPERIENCE',
style:
FlutterFlowTheme.of(context)
.titleMedium
.override(
font: GoogleFonts.lora(
fontWeight:
FlutterFlowTheme.of(
context)
.titleMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.titleMedium
.fontStyle,
),
color:
FlutterFlowTheme.of(
context)
.primaryText,
letterSpacing: 0.0,
fontWeight:
FlutterFlowTheme.of(
context)
.titleMedium
.fontWeight,
fontStyle:
FlutterFlowTheme.of(
context)
.titleMedium
.fontStyle,
lineHeight: 1.4,
),
),
Icon(
Icons.edit_rounded,
color:
FlutterFlowTheme.of(context)
.onSurface,
size: 20,
),
],
),
wrapWithModel(
model: \_model.editorFieldModel1,
updateCallback: () =>
safeSetState(() {}),
child: EditorFieldWidget(
label: 'JOB TITLE',
value: 'Senior AI Strategist',
),
),
wrapWithModel(
model: \_model.editorFieldModel2,
updateCallback: () =>
safeSetState(() {}),
child: EditorFieldWidget(
label: 'COMPANY',
value: 'Empire State Tech',
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Text(
'ACHIEVEMENTS',
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
.onSurface,
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
Container(
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context)
.surfaceVariant,
borderRadius:
BorderRadius.circular(8),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(
context)
.alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(16),
child: Container(
child: Column(
mainAxisSize:
MainAxisSize.min,
mainAxisAlignment:
MainAxisAlignment.start,
crossAxisAlignment:
CrossAxisAlignment
.center,
children: [
Text(
'• Orchestrated \$2M efficiency gain via neural networks',
style: FlutterFlowTheme
.of(context)
.bodyMedium
.override(
font: GoogleFonts
.lora(
fontWeight: FlutterFlowTheme.of(
context)
.bodyMedium
.fontWeight,
fontStyle: FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
),
letterSpacing:
0.0,
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
lineHeight: 1.5,
),
),
Text(
'• Led 15-person design cohort for urban restoration',
style: FlutterFlowTheme
.of(context)
.bodyMedium
.override(
font: GoogleFonts
.lora(
fontWeight: FlutterFlowTheme.of(
context)
.bodyMedium
.fontWeight,
fontStyle: FlutterFlowTheme.of(
context)
.bodyMedium
.fontStyle,
),
letterSpacing:
0.0,
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
lineHeight: 1.5,
),
),
Row(
mainAxisSize:
MainAxisSize.max,
mainAxisAlignment:
MainAxisAlignment
.end,
crossAxisAlignment:
CrossAxisAlignment
.center,
children: [
wrapWithModel(
model: _model
.buttonModel3,
updateCallback: () =>
safeSetState(
() {}),
child: ButtonWidget(
icon: Icon(
Icons
.auto_awesome_rounded,
color: FlutterFlowTheme.of(
context)
.primaryText,
size: 24,
),
iconPresent: true,
iconEndPresent:
false,
content:
'AI IMPROVE',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
],
),
].divide(
SizedBox(height: 8)),
),
),
),
),
].divide(SizedBox(height: 4)),
),
].divide(SizedBox(height: 24)),
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
Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).secondary,
shape: BoxShape.rectangle,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Container(
height: 2,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primary,
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
model: _model.buttonModel4,
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
content: 'REWRITE WITH AI',
variant: 'primary',
size: 'medium',
fullWidth: true,
loading: false,
disabled: false,
),
),
),
Container(
width: 56,
height: 56,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius: BorderRadius.circular(8),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context).primary,
width: 1,
),
),
alignment: AlignmentDirectional(0, 0),
child: Icon(
Icons.auto_fix_high_rounded,
color: FlutterFlowTheme.of(context).onSurface,
size: 24,
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
