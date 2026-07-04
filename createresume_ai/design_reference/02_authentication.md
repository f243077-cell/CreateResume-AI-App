# 02 Authentication

Authentication:

Widget code:
import '/components/button/button_widget.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'authentication_model.dart';
export 'authentication_model.dart';

class AuthenticationWidget extends StatefulWidget {
const AuthenticationWidget({super.key});

static String routeName = 'Authentication';
static String routePath = '/authentication';

@override
State<AuthenticationWidget> createState() => \_AuthenticationWidgetState();
}

class \_AuthenticationWidgetState extends State<AuthenticationWidget> {
late AuthenticationModel \_model;

final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
super.initState();
\_model = createModel(context, () => AuthenticationModel());
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
body: SingleChildScrollView(
primary: false,
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
ClipRRect(
child: Container(
height: 300,
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
FlutterFlowTheme.of(context).primary,
FlutterFlowTheme.of(context).secondary20
],
stops: [0, 1],
begin: AlignmentDirectional(0, -1),
end: AlignmentDirectional(0, 1),
),
shape: BoxShape.rectangle,
),
child: Stack(
alignment: AlignmentDirectional(-1, -1),
children: [
Align(
alignment: AlignmentDirectional(1, -1),
child: Transform.rotate(
angle: 45 _ (math.pi / 180),
alignment: AlignmentDirectional(0, 0),
child: Container(
width: 200,
height: 200,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primary10,
borderRadius: BorderRadius.circular(40),
shape: BoxShape.rectangle,
),
),
),
),
Align(
alignment: AlignmentDirectional(-1, 1),
child: Transform.rotate(
angle: -15 _ (math.pi / 180),
alignment: AlignmentDirectional(0, 0),
child: Container(
width: 150,
height: 150,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).accent10,
borderRadius: BorderRadius.circular(30),
shape: BoxShape.rectangle,
),
),
),
),
Padding(
padding: EdgeInsets.all(32),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Container(
width: 80,
height: 80,
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context)
.secondaryBackground,
borderRadius: BorderRadius.circular(24),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context).primary,
width: 2,
),
),
alignment: AlignmentDirectional(0, 0),
child: Icon(
Icons.auto_awesome_rounded,
color: FlutterFlowTheme.of(context).onSurface,
size: 40,
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'CraftResume AI',
style: FlutterFlowTheme.of(context)
.headlineMedium
.override(
font: GoogleFonts.josefinSans(
fontWeight: FontWeight.w800,
fontStyle:
FlutterFlowTheme.of(context)
.headlineMedium
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.primaryText,
letterSpacing: 0.0,
fontWeight: FontWeight.w800,
fontStyle: FlutterFlowTheme.of(context)
.headlineMedium
.fontStyle,
lineHeight: 1.25,
),
),
Text(
'Elevate your career with intelligence.',
textAlign: TextAlign.center,
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
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight: FlutterFlowTheme.of(context)
.bodyMedium
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.bodyMedium
.fontStyle,
lineHeight: 1.5,
),
),
].divide(SizedBox(height: 4)),
),
].divide(SizedBox(height: 24)),
),
),
],
),
),
),
Container(
child: Container(
decoration: BoxDecoration(
color: FlutterFlowTheme.of(context).primaryBackground,
borderRadius: BorderRadius.only(
topLeft: Radius.circular(40),
topRight: Radius.circular(40),
),
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
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Welcome Back',
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
'Sign in to continue your professional journey',
style: FlutterFlowTheme.of(context)
.bodyMedium
.override(
font: GoogleFonts.lora(
fontWeight: FlutterFlowTheme.of(context)
.bodyMedium
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
.bodyMedium
.fontStyle,
),
color: FlutterFlowTheme.of(context)
.secondaryText,
letterSpacing: 0.0,
fontWeight: FlutterFlowTheme.of(context)
.bodyMedium
.fontWeight,
fontStyle: FlutterFlowTheme.of(context)
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
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: \_model.textFieldModel1,
updateCallback: () => safeSetState(() {}),
child: TextFieldWidget(
label: 'Email Address',
labelPresent: true,
helper: '',
helperPresent: false,
leadingIcon: Icon(
Icons.email_rounded,
color: FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
leadingIconPresent: true,
trailingIconPresent: false,
hint: 'alex@example.com',
value: '',
onChange: '',
onSubmit: '',
variant: 'outlined',
error: false,
),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: \_model.textFieldModel2,
updateCallback: () => safeSetState(() {}),
child: TextFieldWidget(
label: 'Password',
labelPresent: true,
helper: '',
helperPresent: false,
leadingIcon: Icon(
Icons.lock_rounded,
color: FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
leadingIconPresent: true,
trailingIcon: Icon(
Icons.visibility_off_rounded,
color: FlutterFlowTheme.of(context)
.primaryText,
size: 24,
),
trailingIconPresent: true,
hint: '••••••••',
value: '',
onChange: '',
onSubmit: '',
variant: 'outlined',
error: false,
),
),
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.end,
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
wrapWithModel(
model: _model.buttonModel1,
updateCallback: () =>
safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Forgot Password?',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
],
),
].divide(SizedBox(height: 8)),
),
].divide(SizedBox(height: 16)),
),
Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
wrapWithModel(
model: \_model.buttonModel2,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Sign In',
variant: 'primary',
size: 'large',
fullWidth: true,
loading: false,
disabled: false,
),
),
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Expanded(
flex: 1,
child: Divider(
height: 16,
thickness: 1,
indent: 0,
endIndent: 0,
color: FlutterFlowTheme.of(context)
.alternate,
),
),
Text(
'OR',
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
Expanded(
flex: 1,
child: Divider(
height: 16,
thickness: 1,
indent: 0,
endIndent: 0,
color: FlutterFlowTheme.of(context)
.alternate,
),
),
].divide(SizedBox(width: 16)),
),
].divide(SizedBox(height: 16)),
),
Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.socialAuthButtonModel1,
updateCallback: () => safeSetState(() {}),
child: SocialAuthButtonWidget(
bgColor:
FlutterFlowTheme.of(context).primary,
iconSlug:
'https://cdn.simpleicons.org/google/0d0d0d.svg',
label: 'Google',
),
),
),
Expanded(
flex: 1,
child: wrapWithModel(
model: _model.socialAuthButtonModel2,
updateCallback: () => safeSetState(() {}),
child: SocialAuthButtonWidget(
bgColor:
FlutterFlowTheme.of(context).primary,
iconSlug:
'https://cdn.simpleicons.org/apple/0d0d0d.svg',
label: 'Apple',
),
),
),
].divide(SizedBox(width: 16)),
),
Container(
child: Padding(
padding:
EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Don\'t have an account?',
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
color: FlutterFlowTheme.of(context)
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
wrapWithModel(
model: _model.buttonModel3,
updateCallback: () => safeSetState(() {}),
child: ButtonWidget(
iconPresent: false,
iconEndPresent: false,
content: 'Create Account',
variant: 'ghost',
size: 'small',
fullWidth: false,
loading: false,
disabled: false,
),
),
].divide(SizedBox(width: 4)),
),
),
),
),
Container(
decoration: BoxDecoration(
color:
FlutterFlowTheme.of(context).surfaceVariant30,
borderRadius: BorderRadius.circular(8),
shape: BoxShape.rectangle,
border: Border.all(
color: FlutterFlowTheme.of(context).alternate,
width: 1,
),
),
child: Padding(
padding: EdgeInsets.all(16),
child: Container(
child: Row(
mainAxisSize: MainAxisSize.max,
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Icon(
Icons.verified_user_rounded,
color:
FlutterFlowTheme.of(context).success,
size: 16,
),
Text(
'ATS-Optimized & Secure Encryption',
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
].divide(SizedBox(width: 8)),
),
),
),
),
].divide(SizedBox(height: 32)),
),
),
),
),
),
],
),
),
),
);
}
}
