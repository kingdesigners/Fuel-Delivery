class RiderModel {
  int? id;
  String? name;
  String? email;
  String? contactNumber;
  double? latitude;
  double? longitude;
  double? distance; // calculated local

  RiderModel({this.id, this.name, this.email, this.contactNumber, this.latitude, this.longitude});

  RiderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    contactNumber = json['contact_number'];
    // Assuming backend might send coordinates if tracking is active
    latitude = json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null;
    longitude = json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null;
  }
}

class RiderListModel {
  List<RiderModel>? data;

  RiderListModel({this.data});

  RiderListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <RiderModel>[];
      json['data'].forEach((v) {
        data!.add(new RiderModel.fromJson(v));
      });
    }
  }
}
