import 'package:flutter/material.dart';

class AppLayout{
  static displayWidth(context) {
    return MediaQuery.sizeOf(context).width;
  }

  static displayHeightFull(context){
    return MediaQuery.sizeOf(context).height;
  }

  static displayHeightWithoutStatusBar(context){
    return MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top;
  }

  static displayHeightWithoutAppBar(context){
    return MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top - kToolbarHeight;
  }

  static displayHeightWithoutBothBars(context){
    return MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top - kToolbarHeight - kBottomNavigationBarHeight;
  }
}