import 'package:flutter/cupertino.dart';

import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:shadcn_ui/shadcn_ui.dart';

const labelTextStyle = TextStyle(
  fontSize: constants.formLabelFontSize,
  fontVariations:[
    FontVariation(
        'wght', constants.formLabelFontWeight
    )
  ],
  color: constants.textColor,
);

const errorTextStyle = TextStyle(
  fontSize: constants.formErrorFontSize,
  fontVariations:[
    FontVariation(
        'wght', constants.formErrorFontWeight
    )
  ],
  color: constants.errorColor,
);

const formInputDecoration = ShadDecoration(
        color: constants.textFieldColor,
    );

const placeholderTextStyle = TextStyle(
  color: constants.textFieldPlaceholderColor,
);

