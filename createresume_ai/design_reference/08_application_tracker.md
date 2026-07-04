# 08 Application Tracker

Application Tracker:

Widget code:

import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child4/bottom_nav_child4_widget.dart';
import '/components/status_column/status_column_widget.dart';
import '/components/status_column_child/status_column_child_widget.dart';
import '/components/status_column_child2/status_column_child2_widget.dart';
import '/components/status_column_child3/status_column_child3_widget.dart';
import '/components/status_column_child4/status_column_child4_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'application_tracker_model.dart';
export 'application_tracker_model.dart';

class ApplicationTrackerWidget extends StatefulWidget {
  const ApplicationTrackerWidget({super.key});

  static String routeName = 'ApplicationTracker';
  static String routePath = '/applicationTracker';

  @override
  State<ApplicationTrackerWidget> createState() =>
      _ApplicationTrackerWidgetState();
}

class _ApplicationTrackerWidgetState extends State<ApplicationTrackerWidget> {
  late ApplicationTrackerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ApplicationTrackerModel());
  }

  @override
  void dispose() {
    _model.dispose();

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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            print('FAB pressed ...');
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          icon: Icon(
            Icons.add_rounded,
            color: FlutterFlowTheme.of(context).onPrimary,
            size: 24,
          ),
          elevation: 0,
          label: Text(
            'Add App',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.josefinSans(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).onPrimary,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.3,
                ),
          ),
        ),
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
                                'Application Tracker',
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
                                'Manage your journey to hire',
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
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              wrapWithModel(
                                model: _model.statusColumnModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: StatusColumnWidget(
                                  count: '3',
                                  label: 'Applied',
                                  child: () => StatusColumnChildWidget(),
                                ),
                              ),
                              wrapWithModel(
                                model: _model.statusColumnModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: StatusColumnWidget(
                                  count: '2',
                                  label: 'Interview',
                                  child: () => StatusColumnChild2Widget(),
                                ),
                              ),
                              wrapWithModel(
                                model: _model.statusColumnModel3,
                                updateCallback: () => safeSetState(() {}),
                                child: StatusColumnWidget(
                                  count: '1',
                                  label: 'Offer',
                                  child: () => StatusColumnChild3Widget(),
                                ),
                              ),
                              wrapWithModel(
                                model: _model.statusColumnModel4,
                                updateCallback: () => safeSetState(() {}),
                                child: StatusColumnWidget(
                                  count: '5',
                                  label: 'Archive',
                                  child: () => StatusColumnChild4Widget(),
                                ),
                              ),
                            ].divide(SizedBox(width: 24)),
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
                  model: _model.bottomNavModel,
                  updateCallback: () => safeSetState(() {}),
                  child: BottomNavWidget(
                    child: () => BottomNavChild4Widget(),
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




