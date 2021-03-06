import 'package:unknperson/models/FakepersonFields.dart';

class Fakeperson {
  String model;
  int pk;
  FakepersonFields fakepersonfields;
  bool isSelected;

  Fakeperson({this.model, this.pk, this.fakepersonfields, this.isSelected});

  Fakeperson.fromJson(Map<String, dynamic> json) {
    model = json['model'];
    if(json['pk'] != null){
      pk = json['pk'];
    }
    fakepersonfields = json['fields'] != null ? new FakepersonFields.fromJson(json['fields']) : null;
    isSelected = json['isSelected'];;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['model'] = this.model;

    if(this.pk != null){
      data['pk'] = this.pk;
    }
    if (this.fakepersonfields != null) {
      data['fields'] = this.fakepersonfields.toJson();
    }
    data['isSelected'] = this.isSelected;
    return data;
  }
}
