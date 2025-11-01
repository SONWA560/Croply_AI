part of 'example.dart';

class GetMyFarmsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetMyFarmsVariablesBuilder(this._dataConnect, );
  Deserializer<GetMyFarmsData> dataDeserializer = (dynamic json)  => GetMyFarmsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetMyFarmsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetMyFarmsData, void> ref() {
    
    return _dataConnect.query("GetMyFarms", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetMyFarmsFarms {
  final String id;
  final String name;
  final String location;
  final double? sizeAcres;
  GetMyFarmsFarms.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  location = nativeFromJson<String>(json['location']),
  sizeAcres = json['sizeAcres'] == null ? null : nativeFromJson<double>(json['sizeAcres']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyFarmsFarms otherTyped = other as GetMyFarmsFarms;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    location == otherTyped.location && 
    sizeAcres == otherTyped.sizeAcres;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, location.hashCode, sizeAcres.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['location'] = nativeToJson<String>(location);
    if (sizeAcres != null) {
      json['sizeAcres'] = nativeToJson<double?>(sizeAcres);
    }
    return json;
  }

  const GetMyFarmsFarms({
    required this.id,
    required this.name,
    required this.location,
    this.sizeAcres,
  });
}

@immutable
class GetMyFarmsData {
  final List<GetMyFarmsFarms> farms;
  GetMyFarmsData.fromJson(dynamic json):
  
  farms = (json['farms'] as List<dynamic>)
        .map((e) => GetMyFarmsFarms.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyFarmsData otherTyped = other as GetMyFarmsData;
    return farms == otherTyped.farms;
    
  }
  @override
  int get hashCode => farms.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['farms'] = farms.map((e) => e.toJson()).toList();
    return json;
  }

  const GetMyFarmsData({
    required this.farms,
  });
}

