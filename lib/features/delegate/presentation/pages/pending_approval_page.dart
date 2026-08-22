import 'dart:async';

import 'package:flutter/material.dart';

import 'package:saas/core/app_theme.dart';
import 'package:saas/core/dio_client.dart';

import 'package:saas/features/delegate/data/repositories/delegate_repository.dart';

import 'package:saas/features/delegate/logic/delegate_bloc.dart';
import 'package:saas/features/delegate/logic/delegate_event.dart';
import 'package:saas/features/delegate/logic/delegate_state.dart';


class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({
    super.key,
  });

  @override
  State<PendingApprovalPage> createState() =>
      _PendingApprovalPageState();
}


class _PendingApprovalPageState
    extends State<PendingApprovalPage> {

  late DelegateBloc delegateBloc;

  Timer? approvalTimer;

  bool isChecking = false;


  @override
  void initState() {
    super.initState();

    // ==========================================
    // CREATE REPOSITORY
    // ==========================================

    final repository = DelegateRepository(
      dioClient: DioClient(),
    );


    // ==========================================
    // CREATE BLOC
    // ==========================================

    delegateBloc = DelegateBloc(
      repository: repository,
    );


    // ==========================================
    // FIRST CHECK
    // ==========================================

    checkApproval();


    // ==========================================
    // PERIODIC CHECK
    // ==========================================

    approvalTimer = Timer.periodic(
      const Duration(seconds: 10),
          (timer) {

        checkApproval();

      },
    );
  }


  // ==========================================
  // CHECK APPROVAL
  // ==========================================

  Future<void> checkApproval() async {

    if (isChecking) {
      return;
    }


    setState(() {
      isChecking = true;
    });


    final DelegateState state =
    await delegateBloc.handleEvent(
      CheckApprovalStatusRequested(),
    );


    if (!mounted) {
      return;
    }


    setState(() {
      isChecking = false;
    });


    // ==========================================
    // APPROVED
    // ==========================================

    if (state is DelegateApproved) {

      approvalTimer?.cancel();


      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
      );

      return;
    }

    // ==========================================
// REJECTED
// ==========================================

    if (state is DelegateError) {

      approvalTimer?.cancel();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Your application has been rejected.",
          ),
        ),
      );

      Navigator.pop(context);

      return;
    }


    // ==========================================
    // ERROR
    // ==========================================

    if (state is DelegateError) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.message,
          ),
        ),
      );
    }
  }


  @override
  void dispose() {

    approvalTimer?.cancel();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppTheme.backgroundColor,


      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation: 0,

        automaticallyImplyLeading: false,

        title: const Text(
          "Application Status",

          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),


      body: Center(

        child: Padding(

          padding:
          const EdgeInsets.all(25),


          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,


            children: [

              // ==================================
              // ICON
              // ==================================

              Container(

                width: 100,
                height: 100,

                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              ),


              const SizedBox(height: 30),


              // ==================================
              // TITLE
              // ==================================

              const Text(
                "Application Under Review",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),


              const SizedBox(height: 12),


              // ==================================
              // DESCRIPTION
              // ==================================

              const Text(
                "Your delegate application has been "
                    "submitted successfully.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textGrey,
                  height: 1.5,
                ),
              ),


              const SizedBox(height: 8),


              const Text(
                "Please wait while the association "
                    "reviews your application.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.5,
                ),
              ),


              const SizedBox(height: 35),


              // ==================================
              // LOADING
              // ==================================

              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),


              const SizedBox(height: 20),


              Text(
                isChecking
                    ? "Checking application status..."
                    : "Waiting for approval",

                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 14,
                ),
              ),


              const SizedBox(height: 30),


              // ==================================
              // MANUAL CHECK BUTTON
              // ==================================

              SizedBox(

                width: double.infinity,

                height: 50,

                child: OutlinedButton(

                  onPressed:
                  isChecking
                      ? null
                      : checkApproval,

                  style: OutlinedButton.styleFrom(

                    foregroundColor:
                    AppTheme.primaryColor,

                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Check Status",
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