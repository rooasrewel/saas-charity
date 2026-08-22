import 'package:flutter/material.dart';

import 'package:saas/core/app_theme.dart';
import 'package:saas/core/dio_client.dart';

import 'package:saas/features/delegate/data/models/association_model.dart';

import 'package:saas/features/delegate/data/repositories/delegate_repository.dart';

import 'package:saas/features/delegate/logic/delegate_bloc.dart';
import 'package:saas/features/delegate/logic/delegate_event.dart';
import 'package:saas/features/delegate/logic/delegate_state.dart';

import 'package:saas/features/delegate/presentation/widgets/association_dropdown.dart';


class DelegateSetupPage extends StatefulWidget {

  const DelegateSetupPage({
    super.key,
  });


  @override
  State<DelegateSetupPage> createState() =>
      _DelegateSetupPageState();
}


class _DelegateSetupPageState
    extends State<DelegateSetupPage> {


  // ==========================================
  // CONTROLLERS
  // ==========================================

  final TextEditingController
  professionalIdController =
  TextEditingController();


  final TextEditingController
  authorizationController =
  TextEditingController();


  // ==========================================
  // ASSOCIATIONS
  // ==========================================

  List<AssociationModel> associations = [];


  String? selectedAssociation;


  bool isLoadingAssociations = true;


  // ==========================================
  // LOADING SUBMIT
  // ==========================================

  bool isLoading = false;


  // ==========================================
  // BLOC
  // ==========================================

  late DelegateBloc delegateBloc;


  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {

    super.initState();


    // ========================================
    // CREATE REPOSITORY
    // ========================================

    final repository =
    DelegateRepository(

      dioClient:
      DioClient(),
    );


    // ========================================
    // CREATE BLOC
    // ========================================

    delegateBloc =
        DelegateBloc(

          repository:
          repository,
        );


    // ========================================
    // LOAD ASSOCIATIONS
    // ========================================

    loadAssociations();
  }


  // ==========================================
  // LOAD ASSOCIATIONS
  // ==========================================

  Future<void> loadAssociations() async {

    setState(() {

      isLoadingAssociations =
      true;

    });


    final DelegateState state =
    await delegateBloc.handleEvent(

      GetAssociationsRequested(),
    );


    if (!mounted) {

      return;
    }


    // ========================================
    // ASSOCIATIONS LOADED
    // ========================================

    if (state
    is AssociationsLoaded) {

      setState(() {

        associations =
            state.associations;

        isLoadingAssociations =
        false;

      });

      return;
    }


    // ========================================
    // LOADING FINISHED
    // ========================================

    setState(() {

      isLoadingAssociations =
      false;

    });


    // ========================================
    // ERROR
    // ========================================

    if (state
    is DelegateError) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            state.message,
          ),
        ),
      );
    }
  }


  // ==========================================
  // SUBMIT
  // ==========================================

  Future<void> submitSetup() async {


    // ========================================
    // VALIDATE ASSOCIATION
    // ========================================

    if (selectedAssociation == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text(
            "Please select an association.",
          ),
        ),
      );

      return;
    }


    // ========================================
    // START LOADING
    // ========================================

    setState(() {

      isLoading =
      true;

    });


    // ========================================
    // SEND REQUEST
    // ========================================

    final DelegateState state =
    await delegateBloc.handleEvent(

      JoinAssociationRequested(

        associationId:
        selectedAssociation!,

        professionalId:
        professionalIdController.text
            .trim(),

        authorizationLetter:
        authorizationController.text
            .trim(),
      ),
    );


    // ========================================
    // CHECK PAGE
    // ========================================

    if (!mounted) {

      return;
    }


    // ========================================
    // STOP LOADING
    // ========================================

    setState(() {

      isLoading =
      false;

    });


    // ========================================
    // SUCCESS
    // ========================================

    if (state
    is AssociationPending) {

      Navigator.pushReplacementNamed(

        context,

        '/pending',
      );

      return;
    }


    // ========================================
    // ERROR
    // ========================================

    if (state
    is DelegateError) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            state.message,
          ),
        ),
      );

      return;
    }
  }


  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {

    professionalIdController.dispose();

    authorizationController.dispose();

    super.dispose();
  }


  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      AppTheme.backgroundColor,


      // ========================================
      // APP BAR
      // ========================================

      appBar:
      AppBar(

        backgroundColor:
        Colors.white,

        elevation:
        0,


        leading:
        IconButton(

          icon:
          const Icon(

            Icons.arrow_back,

            color:
            AppTheme.textDark,
          ),


          onPressed: () {

            Navigator.pop(
              context,
            );

          },
        ),


        title:
        const Text(

          "Complete Profile",

          style:
          TextStyle(

            color:
            AppTheme.textDark,

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),


      // ========================================
      // BODY
      // ========================================

      body:
      SingleChildScrollView(

        padding:
        const EdgeInsets.all(
          20,
        ),


        child:
        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [

            const SizedBox(
              height: 10,
            ),


            // ==================================
            // TITLE
            // ==================================

            const Text(

              "Complete your delegate profile",

              style:
              TextStyle(

                fontSize:
                24,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 8,
            ),
            // ==================================
            // DESCRIPTION
            // ==================================

            const Text(

              "Please provide the required information "
                  "to complete your delegate registration.",

              style:
              TextStyle(

                fontSize:
                14,

                color:
                AppTheme.textGrey,
              ),
            ),


            const SizedBox(
              height: 30,
            ),


            // ==================================
            // ASSOCIATION
            // ==================================

            AssociationDropdown(

              associations:
              associations,

              selectedAssociation:
              selectedAssociation,

              isLoading:
              isLoadingAssociations,


              onChanged:
                  (value) {

                setState(() {

                  selectedAssociation =
                      value;

                });
              },
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // PROFESSIONAL ID
            // ==================================

            const Text(

              "Professional ID",

              style:
              TextStyle(

                fontSize:
                15,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 8,
            ),


            TextField(

              controller:
              professionalIdController,


              decoration:
              const InputDecoration(

                hintText:
                "Enter your professional ID",
              ),
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // AUTHORIZATION
            // ==================================

            const Text(

              "Authorization",

              style:
              TextStyle(

                fontSize:
                15,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 8,
            ),


            TextField(

              controller:
              authorizationController,

              maxLines:
              4,


              decoration:
              const InputDecoration(

                hintText:
                "Enter authorization information",
              ),
            ),


            const SizedBox(
              height: 35,
            ),


            // ==================================
            // SUBMIT BUTTON
            // ==================================

            SizedBox(

              width:
              double.infinity,

              height:
              55,


              child:
              ElevatedButton(

                onPressed:

                isLoading ||
                    isLoadingAssociations

                    ? null

                    : submitSetup,


                child:

                isLoading

                    ? const SizedBox(

                  width:
                  24,

                  height:
                  24,

                  child:
                  CircularProgressIndicator(

                    strokeWidth:
                    2,

                    color:
                    Colors.white,
                  ),
                )

                    : const Text(
                  "Submit Application",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}