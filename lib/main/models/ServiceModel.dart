class ServiceListModel {
  List<ServiceData>? data;

  ServiceListModel({this.data});

  ServiceListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ServiceData>[];
      json['data'].forEach((v) {
        data!.add(new ServiceData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceData {
  int? id;
  String? title;
  String? label;
  String? value;
  String? image;
  String? description;
  int? status;

  ServiceData({this.id, this.title, this.label, this.value, this.image, this.description, this.status});

  ServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    label = json['label'] ?? json['title']; // Safety fallback
    value = json['value'];
    image = json['image'];
    description = json['description'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['label'] = this.label;
    data['value'] = this.value;
    data['image'] = this.image;
    data['description'] = this.description;
    data['status'] = this.status;
    return data;
  }
}
