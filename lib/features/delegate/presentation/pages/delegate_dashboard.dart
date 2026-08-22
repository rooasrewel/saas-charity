import 'package:flutter/material.dart';

import 'package:saas/core/app_routes.dart';
import 'package:saas/core/app_theme.dart';
import 'package:saas/core/dio_client.dart';

import 'package:saas/features/delegate/data/models/delegate_model.dart';
import 'package:saas/features/delegate/data/models/field_case_model.dart';

import 'package:saas/features/delegate/data/repositories/delegate_repository.dart';

import 'package:saas/features/delegate/logic/delegate_bloc.dart';
import 'package:saas/features/delegate/logic/delegate_event.dart';
import 'package:saas/features/delegate/logic/delegate_state.dart';


class DelegateDashboard extends StatefulWidget {
  const DelegateDashboard({
    super.key,
  });

  @override
  State<DelegateDashboard> createState() =>
      _DelegateDashboardState();
}


class _DelegateDashboardState
    extends State<DelegateDashboard> {

  // ==========================================
  // CURRENT BOTTOM NAVIGATION INDEX
  // ==========================================

  int currentIndex = 0;


  // ==========================================
  // DELEGATE LOGIC
  // ==========================================

  late DelegateBloc delegateBloc;


  // ==========================================
  // FIELD CASES
  // ==========================================

  List<FieldCaseModel> fieldCases = [];

  bool isLoadingCases = true;


  // ==========================================
  // DASHBOARD STATISTICS
  // ==========================================

  int casesForReview = 0;

  int verifiedToday = 0;

  bool isLoadingStatistics = true;


  // ==========================================
  // DASHBOARD LOADING
  // ==========================================

  bool isLoading = false;


  // ==========================================
  // DELEGATE DATA
  // ==========================================

  DelegateModel? delegateData;


  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {
    super.initState();

    final repository = DelegateRepository(
      dioClient: DioClient(),
    );

    delegateBloc = DelegateBloc(
      repository: repository,
    );

    // تحميل البيانات
    loadDashboard();

    loadFieldCases();

    loadDashboardStatistics();
  }


  // ==========================================
  // LOAD DELEGATE DASHBOARD
  // ==========================================

  Future<void> loadDashboard() async {

    setState(() {
      isLoading = true;
    });


    final DelegateState state =
    await delegateBloc.handleEvent(
      DashboardRequested(),
    );


    if (!mounted) {
      return;
    }


    setState(() {
      isLoading = false;
    });


    // ========================================
    // SUCCESS
    // ========================================

    if (state is DelegateDashboardLoaded) {

      setState(() {

        delegateData =
            state.delegate;

      });

      return;
    }


    // ========================================
    // ERROR
    // ========================================

    if (state is DelegateError) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            state.message,
          ),
        ),
      );
    }
  }


  // ==========================================
  // LOAD FIELD CASES
  // ==========================================

  Future<void> loadFieldCases() async {

    setState(() {
      isLoadingCases = true;
    });


    final DelegateState state =
    await delegateBloc.handleEvent(
      GetFieldCasesRequested(),
    );


    if (!mounted) {
      return;
    }


    // ========================================
    // SUCCESS
    // ========================================

    if (state is FieldCasesLoaded) {

      setState(() {

        fieldCases =
            state.cases;

        isLoadingCases = false;

      });

      return;
    }


    // ========================================
    // STOP LOADING
    // ========================================
    setState(() {
      isLoadingCases = false;
    });


    // ========================================
    // ERROR
    // ========================================

    if (state is DelegateError) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            state.message,
          ),
        ),
      );
    }
  }


  // ==========================================
  // LOAD DASHBOARD STATISTICS
  // ==========================================

  Future<void> loadDashboardStatistics() async {

    setState(() {
      isLoadingStatistics = true;
    });


    final DelegateState state =
    await delegateBloc.handleEvent(
      GetDashboardStatisticsRequested(),
    );


    if (!mounted) {
      return;
    }


    // ========================================
    // SUCCESS
    // ========================================

    if (state
    is DashboardStatisticsLoaded) {

      setState(() {

        casesForReview =
            state.dashboard.casesForReview;

        verifiedToday =
            state.dashboard.verifiedToday;

        isLoadingStatistics = false;

      });

      return;
    }


    // ========================================
    // STOP LOADING
    // ========================================

    setState(() {
      isLoadingStatistics = false;
    });


    // ========================================
    // ERROR
    // ========================================

    if (state is DelegateError) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            state.message,
          ),
        ),
      );
    }
  }


  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppTheme.backgroundColor,


      // ========================================
      // APP BAR
      // ========================================

      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation: 0,

        automaticallyImplyLeading: false,

        title: const Text(
          "ImpactConnect",

          style: TextStyle(
            color:
            AppTheme.textDark,

            fontWeight:
            FontWeight.bold,

            fontSize: 20,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () {},

            icon: const Icon(
              Icons.notifications_none,

              color:
              AppTheme.textDark,
            ),
          ),
        ],
      ),


      // ========================================
      // BODY
      // ========================================

      body: Stack(

        children: [

          SingleChildScrollView(

            child: Padding(

              padding:
              const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const SizedBox(
                    height: 10,
                  ),


                  // ==================================
                  // PROFILE / WELCOME
                  // ==================================

                  Row(

                    children: [

                      const CircleAvatar(

                        radius: 28,

                        backgroundImage:
                        AssetImage(
                          "assets/images/profile.jpg",
                        ),
                      ),


                      const SizedBox(
                        width: 15,
                      ),


                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: 22,

                              fontWeight:
                              FontWeight.bold,

                              color:
                              AppTheme.textDark,
                            ),
                          ),


                          const SizedBox(
                            height: 4,
                          ),


                          Text(

                            delegateData != null
                                ? "Welcome back, ${delegateData!.name}"
                                : "Welcome back, Delegate",

                            style: const TextStyle(
                              color:
                              AppTheme.textGrey,

                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),


                  const SizedBox(
                    height: 25,
                  ),


                  // ==================================
                  // STATISTICS
                  // ==================================

                  Row(

                    children: [

                      // ==============================
                      // CASES FOR REVIEW
                      // ==============================

                      Expanded(

                        child: Container(

                          height: 120,

                          decoration:
                          BoxDecoration(

                            color:
                            Colors.white,

                            borderRadius:
                            BorderRadius.circular(
                              15,
                            ),
                          ),

                          child: Padding(

                            padding:
                            const EdgeInsets.all(
                              16,
                            ),

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                const Icon(
                                  Icons.assignment,

                                  color:
                                  AppTheme
                                      .primaryColor,
                                ),


                                const Spacer(),


                                isLoadingStatistics

                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )

                                    : Text(
                                  casesForReview
                                      .toString(),

                                  style:
                                  const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),


                                const Text(
                                  "Cases For Review",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(
                        width: 15,
                      ),
                      // ==============================
                      // VERIFIED TODAY
                      // ==============================

                      Expanded(

                        child: Container(

                          height: 120,

                          decoration:
                          BoxDecoration(

                            color:
                            Colors.white,

                            borderRadius:
                            BorderRadius.circular(
                              15,
                            ),
                          ),

                          child: Padding(

                            padding:
                            const EdgeInsets.all(
                              16,
                            ),

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                const Icon(
                                  Icons.verified,

                                  color:
                                  AppTheme
                                      .primaryColor,
                                ),


                                const Spacer(),


                                isLoadingStatistics

                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )

                                    : Text(
                                  verifiedToday
                                      .toString(),

                                  style:
                                  const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),


                                const Text(
                                  "Verified Today",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(
                    height: 25,
                  ),


                  // ==================================
                  // PENDING AUDIT
                  // ==================================

                  const Text(
                    "Pending Audit",

                    style: TextStyle(
                      fontSize: 20,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      AppTheme.textDark,
                    ),
                  ),


                  const SizedBox(
                    height: 15,
                  ),


                  // ==================================
                  // CASES LOADING
                  // ==================================

                  if (isLoadingCases)

                    const Center(

                      child: Padding(

                        padding:
                        EdgeInsets.all(30),

                        child:
                        CircularProgressIndicator(),
                      ),
                    )


                  // ==================================
                  // NO CASES
                  // ==================================

                  else if (fieldCases.isEmpty)

                    const Center(

                      child: Padding(
                        padding:
                        EdgeInsets.all(30),

                        child: Text(
                          "No pending cases.",

                          style: TextStyle(
                            color:
                            AppTheme.textGrey,
                          ),
                        ),
                      ),
                    )


                  // ==================================
                  // CASES
                  // ==================================

                  else

                    Column(

                      children:
                      fieldCases.map(
                            (fieldCase) {

                          return Container(

                            width:
                            double.infinity,

                            padding:
                            const EdgeInsets.all(
                              15,
                            ),

                            margin:
                            const EdgeInsets.only(
                              bottom: 12,
                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              Colors.white,

                              borderRadius:
                              BorderRadius.circular(
                                15,
                              ),

                              border:
                              Border.all(
                                color:
                                const Color(
                                  0xffe2e8f0,
                                ),
                              ),
                            ),

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                // ==========================
                                // BENEFICIARY
                                // ==========================

                                Text(

                                  fieldCase
                                      .beneficiaryName,

                                  style:
                                  const TextStyle(
                                    fontSize: 16,

                                    fontWeight:
                                    FontWeight.bold,

                                    color:
                                    AppTheme.textDark,
                                  ),
                                ),


                                const SizedBox(
                                  height: 5,
                                ),


                                // ==========================
                                // CASE TYPE
                                // ==========================

                                Text(

                                  fieldCase.caseType,

                                  style:
                                  const TextStyle(
                                    color:
                                    AppTheme.textGrey,
                                  ),
                                ),


                                const SizedBox(
                                  height: 8,
                                ),


                                // ==========================
                                // STATUS
                                // ==========================

                                Text(

                                  "Status: ${fieldCase.status}",

                                  style:
                                  const TextStyle(
                                    color:
                                    AppTheme.textGrey,
                                    fontSize: 13,
                                  ),
                                ),


                                const SizedBox(
                                  height: 10,
                                ),


                                // ==========================
                                // REVIEW BUTTON
                                // ==========================

                                Align(

                                  alignment:
                                  Alignment.centerRight,

                                  child:
                                  ElevatedButton(

                                    onPressed: () {

                                      Navigator.pushNamed(
                                        context,

                                        AppRoutes.fieldAudit,

                                        arguments:
                                        fieldCase.id,
                                      );
                                    },

                                    child:
                                    const Text(
                                      "Review",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),


                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),


          // ========================================
          // GENERAL LOADING
          // ========================================

          if (isLoading)

            Container(

              color:
              Colors.white.withOpacity(0.7),

              child:
              const Center(

                child:
                CircularProgressIndicator(
                  color:
                  AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),


      // ========================================
      // BOTTOM NAVIGATION
      // ========================================

      bottomNavigationBar:
      BottomNavigationBar(

        currentIndex:
        currentIndex,

        selectedItemColor:
        AppTheme.primaryColor,

        unselectedItemColor:
        AppTheme.textGrey,

        onTap: (index) {

          setState(() {
            currentIndex = index;
          });


          // ==============================
          // HOME
          // ==============================

          if (index == 0) {
            return;
          }


          // ==============================
          // MESSAGES
          // ==============================

          if (index == 1) {

            Navigator.pushNamed(
              context,
              AppRoutes.messages,
            );

            return;
          }


          // ==============================
          // SETTINGS
          // ==============================

          if (index == 2) {

            Navigator.pushNamed(
              context,
              AppRoutes.settings,
            );

            return;
          }


          // ==============================
          // PROFILE
          // ==============================

          if (index == 3) {

            Navigator.pushNamed(
              context,
              AppRoutes.profile,
            );

            return;
          }
        },


        items: const [

          BottomNavigationBarItem(
            icon:
            Icon(Icons.home),

            label:
            "Home",
          ),

          BottomNavigationBarItem(
            icon:
            Icon(Icons.message),

            label:
            "Messages",
          ),

          BottomNavigationBarItem(
            icon:
            Icon(Icons.settings),
            label:
            "Settings",
          ),

          BottomNavigationBarItem(
            icon:
            Icon(Icons.person),

            label:
            "Profile",
          ),
        ],
      ),
    );
  }
}