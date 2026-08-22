import 'package:flutter/material.dart';

import 'package:saas/core/app_theme.dart';
import 'package:saas/core/dio_client.dart';

import 'package:saas/features/delegate/data/repositories/delegate_repository.dart';

import 'package:saas/features/delegate/logic/delegate_bloc.dart';
import 'package:saas/features/delegate/logic/delegate_event.dart';
import 'package:saas/features/delegate/logic/delegate_state.dart';

import 'package:saas/features/delegate/presentation/widgets/interactive_slider.dart';
import 'package:saas/features/delegate/presentation/widgets/horizontal_photo_grid.dart';


class FieldAuditPage extends StatefulWidget {

  const FieldAuditPage({
    super.key, required int caseId,
  });


  @override
  State<FieldAuditPage> createState() =>
      _FieldAuditPageState();
}


class _FieldAuditPageState
    extends State<FieldAuditPage> {

  // ==========================================
  // BLOC
  // ==========================================

  late DelegateBloc delegateBloc;


  // ==========================================
  // TEXT CONTROLLERS
  // ==========================================

  final TextEditingController observationController =
  TextEditingController();


  final TextEditingController recommendationController =
  TextEditingController();


  final TextEditingController amountController =
  TextEditingController();


  // ==========================================
  // URGENCY
  // ==========================================

  double urgencyLevel = 50;


  // ==========================================
  // SUBMITTING
  // ==========================================

  bool isSubmitting = false;


  // ==========================================
  // FIELD PHOTOS
  // ==========================================

  List<String> selectedPhotoPaths = [];


  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {

    super.initState();


    final repository =
    DelegateRepository(
      dioClient: DioClient(),
    );


    delegateBloc =
        DelegateBloc(
          repository: repository,
        );
  }


  // ==========================================
  // UPLOAD PHOTOS
  // ==========================================

  Future<bool> uploadFieldPhotos(
      String caseId,
      ) async {

    for (
    final String photoPath
    in selectedPhotoPaths
    ) {

      try {

        final String uploadedUrl =
        await delegateBloc
            .repository
            .uploadPhoto(

          filePath:
          photoPath,

          caseId:
          caseId,
        );


        if (uploadedUrl.isEmpty) {

          return false;
        }

      } catch (e) {

        return false;
      }
    }


    return true;
  }


  // ==========================================
  // SUBMIT REPORT
  // ==========================================

  Future<void> submitReport() async {

    // ========================================
    // VALIDATE OBSERVATION
    // ========================================

    if (observationController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Please enter your observations.",
          ),
        ),
      );

      return;
    }


    // ========================================
    // VALIDATE RECOMMENDATION
    // ========================================

    if (recommendationController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Please enter your recommendation.",
          ),
        ),
      );

      return;
    }


    // ========================================
    // PARSE AMOUNT
    // ========================================

    final double? requestedAmount =
    double.tryParse(
      amountController.text.trim(),
    );


    if (requestedAmount == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid requested amount.",
          ),
        ),
      );

      return;
    }


    // ========================================
    // START LOADING
    // ========================================

    setState(() {

      isSubmitting = true;

    });


    // ========================================
    // CASE ID
    // ========================================
    //
    // مؤقتاً ثابت.
    // لاحقاً رح ناخده من الـ Dashboard.
    //

    const String caseId =
        "case_001";


    // ========================================
    // SEND REPORT EVENT
    // ========================================

    final DelegateState state =
    await delegateBloc.handleEvent(

      SubmitFieldReportRequested(

        caseId:
        caseId,

        urgencyLevel:
        urgencyLevel,

        observation:
        observationController.text
            .trim(),

        recommendation:
        recommendationController.text
            .trim(),

        requestedAmount:
        requestedAmount,
      ),
    );


    // ========================================
    // CHECK PAGE
    // ========================================

    if (!mounted) {

      return;
    }


    // ========================================
    // REPORT SUCCESS
    // ========================================

    if (state is AssessmentSuccess) {


      // ======================================
      // UPLOAD PHOTOS
      // ======================================

      if (selectedPhotoPaths.isNotEmpty) {

        final bool photosUploaded =
        await uploadFieldPhotos(
          caseId,
        );


        if (!mounted) {

          return;
        }


        // ====================================
        // PHOTOS UPLOAD FAILED
        // ====================================

        if (!photosUploaded) {

          setState(() {

            isSubmitting = false;

          });


          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content: Text(
                "Report submitted, but some photos failed to upload.",
              ),
            ),
          );


          return;
        }
      }


      // ======================================
      // STOP LOADING
      // ======================================

      setState(() {

        isSubmitting = false;

      });


      // ======================================
      // SUCCESS MESSAGE
      // ======================================

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Field report submitted successfully.",
          ),
        ),
      );


      // ======================================
      // RETURN TO PREVIOUS PAGE
      // ======================================

      Navigator.pop(context);

      return;
    }


    // ========================================
    // STOP LOADING
    // ========================================

    setState(() {

      isSubmitting = false;

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

      return;
    }
  }


  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {

    observationController.dispose();

    recommendationController.dispose();

    amountController.dispose();

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

      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation: 0,


        leading: IconButton(

          onPressed: () {

            Navigator.pop(context);

          },


          icon: const Icon(

            Icons.arrow_back,

            color:
            AppTheme.textDark,
          ),
        ),


        title: const Text(

          "Field Audit",

          style: TextStyle(

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

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [

            // ==================================
            // CASE INFORMATION
            // ==================================

            Container(

              width:
              double.infinity,

              padding:
              const EdgeInsets.all(18),


              decoration:
              BoxDecoration(

                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(15),

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

                  const Text(

                    "Case Information",

                    style: TextStyle(

                      fontSize:
                      18,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      AppTheme.textDark,
                    ),
                  ),


                  const SizedBox(
                    height: 15,
                  ),


                  Row(

                    children: [

                      Container(

                        width:
                        50,

                        height:
                        50,


                        decoration:
                        const BoxDecoration(

                          color:
                          AppTheme.primaryLight,

                          shape:
                          BoxShape.circle,
                        ),


                        child:
                        const Icon(

                          Icons.person,

                          color:
                          AppTheme.primaryColor,
                        ),
                      ),


                      const SizedBox(
                        width: 12,
                      ),


                      const Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,


                        children: [

                          Text(

                            "Ahmed Mansour",

                            style:
                            TextStyle(

                              fontSize:
                              16,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),


                          SizedBox(
                            height: 4,
                          ),


                          Text(

                            "Medical Case",

                            style:
                            TextStyle(
                              color:
                              AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // URGENCY
            // ==================================

            const Text(

              "Urgency Level",

              style:
              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 8,
            ),


            const Text(

              "Determine the urgency of this case.",

              style:
              TextStyle(

                fontSize:
                14,

                color:
                AppTheme.textGrey,
              ),
            ),


            const SizedBox(
              height: 15,
            ),


            InteractiveSlider(

              value:
              urgencyLevel,


              onChanged: (value) {

                setState(() {

                  urgencyLevel =
                      value;

                });
              },
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // FIELD OBSERVATION
            // ==================================

            const Text(

              "Field Observation",

              style:
              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 10,
            ),


            TextField(

              controller:
              observationController,

              maxLines:
              6,


              decoration:
              const InputDecoration(

                hintText:
                "Describe what you observed during the field visit...",
              ),
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // RECOMMENDATION
            // ==================================

            const Text(

              "Recommendation",

              style:
              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 10,
            ),


            TextField(

              controller:
              recommendationController,

              maxLines:
              5,


              decoration:
              const InputDecoration(

                hintText:
                "Write your recommendation...",
              ),
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // REQUESTED AMOUNT
            // ==================================

            const Text(

              "Requested Amount",

              style:
              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 10,
            ),


            TextField(

              controller:
              amountController,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal:
                true,
              ),


              decoration:
              const InputDecoration(

                hintText:
                "Enter requested amount",
              ),
            ),


            const SizedBox(
              height: 25,
            ),


            // ==================================
            // PHOTOS TITLE
            // ==================================

            const Text(

              "Field Photos",

              style:
              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

                color:
                AppTheme.textDark,
              ),
            ),


            const SizedBox(
              height: 8,
            ),


            const Text(

              "Add photos from the field visit.",

              style:
              TextStyle(

                fontSize:
                14,

                color:
                AppTheme.textGrey,
              ),
            ),


            const SizedBox(
              height: 15,
            ),


            // ==================================
            // PHOTO GRID
            // ==================================

            HorizontalPhotoGrid(

              onPhotosChanged:
                  (photos) {

                setState(() {

                  selectedPhotoPaths =
                      photos;

                });
              },
            ),


            const SizedBox(
              height: 30,
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
                isSubmitting
                    ? null
                    : submitReport,


                child:
                isSubmitting


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

                  "Submit Field Report",
                ),
              ),
            ),


            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}