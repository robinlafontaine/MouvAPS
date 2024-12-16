import 'package:flutter/cupertino.dart';

import 'package:mouvaps/utils/constants.dart' as Constants;
import 'package:shadcn_ui/shadcn_ui.dart';

const LabelTextStyle = TextStyle(
  fontSize: Constants.form_label_font_size,
  fontWeight: Constants.form_label_font_weight,
  color: Constants.textColor,
);

const FormInputDecoration = ShadDecoration(
        color: Constants.textFieldColor,
        border: ShadBorder(
          top: BorderSide(color: Constants.textFieldColor),
        )
    );

const PlaceholderTextStyle = TextStyle(
  color: Constants.textFieldPlaceholderColor,
);

