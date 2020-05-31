import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'BaseModel.dart';

Directory directory;

Future selectDate({ BuildContext context, BaseModel model, String dateString }) async {
  DateTime initialDate = DateTime.now();

  if(dateString != null) {
    List dateParts = dateString.split(',');
    initialDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
  }

  DateTime picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1950),
    lastDate: DateTime(2050)
  );

  if(picked != null) {
    model.setChosenDate(
      DateFormat.yMMMMd('en_US').format(picked.toLocal())
    );
    return '${picked.year}, ${picked.month}, ${picked.day}';
  }
}