import 'package:flutter/material.dart';

import 'package:saas/core/app_theme.dart';
import 'package:saas/features/delegate/data/models/association_model.dart';


class AssociationDropdown extends StatelessWidget {

  final List<AssociationModel> associations;

  final String? selectedAssociation;

  final ValueChanged<String?> onChanged;

  final bool isLoading;


  const AssociationDropdown({

    super.key,

    required this.associations,

    required this.selectedAssociation,

    required this.onChanged,

    this.isLoading = false,
  });


  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        // ==========================================
        // TITLE
        // ==========================================

        const Text(

          "Select Association",

          style: TextStyle(

            fontSize: 15,

            fontWeight:
            FontWeight.bold,

            color:
            AppTheme.textDark,
          ),
        ),


        const SizedBox(
          height: 8,
        ),


        // ==========================================
        // DROPDOWN
        // ==========================================

        Container(

          width:
          double.infinity,

          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),


          decoration:
          BoxDecoration(

            color:
            Colors.white,

            borderRadius:
            BorderRadius.circular(10),

            border:
            Border.all(

              color:
              const Color(
                0xffe2e8f0,
              ),

              width:
              1.5,
            ),
          ),


          child:
          DropdownButtonHideUnderline(

            child:
            DropdownButton<String>(

              // ==================================
              // SELECTED VALUE
              // ==================================

              value:
              selectedAssociation,


              // ==================================
              // HINT
              // ==================================

              hint:

              isLoading

                  ? const Text(
                "Loading associations...",
              )

                  : const Text(
                "Choose an association",
              ),


              // ==================================
              // EXPANDED
              // ==================================

              isExpanded:
              true,


              // ==================================
              // ICON
              // ==================================

              icon:
              isLoading

                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )

                  : const Icon(
                Icons.keyboard_arrow_down,
              ),


              // ==================================
              // ITEMS
              // ==================================

              items:
              isLoading

                  ? null

                  : associations
                  .map(
                    (
                    association,
                    ) {

                  return DropdownMenuItem<
                      String>(

                    value:
                    association.id,
                    child:
                    Text(
                      association.name,
                    ),
                  );
                },
              )
                  .toList(),


              // ==================================
              // ON CHANGED
              // ==================================

              onChanged:
              isLoading
                  ? null
                  : onChanged,
            ),
          ),
        ),


        // ==========================================
        // NO ASSOCIATIONS
        // ==========================================

        if (!isLoading &&
            associations.isEmpty)

          const Padding(

            padding:
            EdgeInsets.only(
              top: 8,
            ),

            child:
            Text(

              "No associations available.",

              style:
              TextStyle(

                fontSize:
                13,

                color:
                Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}