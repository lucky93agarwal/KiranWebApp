import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../design/app_colors.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: Palette.appColor,
        height: 70.h,
        width: 40.w,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Terms and Conditions'),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.close,
                ),
              )
            ],
          ),
          backgroundColor: Colors.black,
          body: Container(
            color: Palette.searchTextFieldColor,
            child: Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                children: [
                  SizedBox(
                    height: 3.h,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SelectableText(
                      '''I have decided to subscribe to the the product/s and / or service/s offered by Kiran Jadhav & Associates LLP, Pune.
            
            I hereby declare that I have subscribed to the product/s and / or service/s on my own initiative, after understanding the risk involved, and all investment and trading decisions based on the product/s and / or service/s subscribed are completely mine.
            
            Along with this all risks and losses if any will be borne by me and it will be my sole responsibility. I fully understand that I will be getting trading and investment calls (based on the product/s and / or service/s subscribed) from Kiran Jadhav & Associates LLP Pune and actual implementation of these calls will
            be my sole responsibility.
            
            I also understand that this declaration will stand true for further products or services subscribed by me at a future date. I hereby also declare that I will not hold Kiran Jadhav & Associates LLP, Pune responsible for any trading or investment losses made from these calls.
            
            I also allow you to call or SMS me for any other investment or promotional activities for Kiran Jadhav & Associates LLP or its group companies as well. ''',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
