part of 'example.dart';

class GetFieldDetailsVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetFieldDetailsVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetFieldDetailsData> dataDeserializer = (dynamic json)  => GetFieldDetailsData.fromJson(jsonDecode(json));
  Serializer<GetFieldDetailsVariables> varsSerializer = (GetFieldDetailsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetFieldDetailsData, GetFieldDetailsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetFieldDetailsData, GetFieldDetailsVariables> ref() {
    GetFieldDetailsVariables vars= GetFieldDetailsVariables(id: id,);
    return _dataConnect.query("GetFieldDetails", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetFieldDetailsField {
  final String id;
  final String name;
  final String cropType;
  final DateTime plantedDate;
  final DateTime? lastHarvestDate;
  final double? sizeAcres;
  final GetFieldDetailsFieldFarm farm;
  final List<GetFieldDetailsFieldTreatmentsOnField> treatments_on_field;
  final List<GetFieldDetailsFieldCropHealthAnalysesOnField> cropHealthAnalyses_on_field;
  GetFieldDetailsField.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  cropType = nativeFromJson<String>(json['cropType']),
  plantedDate = nativeFromJson<DateTime>(json['plantedDate']),
  lastHarvestDate = json['lastHarvestDate'] == null ? null : nativeFromJson<DateTime>(json['lastHarvestDate']),
  sizeAcres = json['sizeAcres'] == null ? null : nativeFromJson<double>(json['sizeAcres']),
  farm = GetFieldDetailsFieldFarm.fromJson(json['farm']),
  treatments_on_field = (json['treatments_on_field'] as List<dynamic>)
        .map((e) => GetFieldDetailsFieldTreatmentsOnField.fromJson(e))
        .toList(),
  cropHealthAnalyses_on_field = (json['cropHealthAnalyses_on_field'] as List<dynamic>)
        .map((e) => GetFieldDetailsFieldCropHealthAnalysesOnField.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetFieldDetailsField otherTyped = other as GetFieldDetailsField;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    cropType == otherTyped.cropType && 
    plantedDate == otherTyped.plantedDate && 
    lastHarvestDate == otherTyped.lastHarvestDate && 
    sizeAcres == otherTyped.sizeAcres && 
    farm == otherTyped.farm && 
    treatments_on_field == otherTyped.treatments_on_field && 
    cropHealthAnalyses_on_field == otherTyped.cropHealthAnalyses_on_field;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, cropType.hashCode, plantedDate.hashCode, lastHarvestDate.hashCode, sizeAcres.hashCode, farm.hashCode, treatments_on_field.hashCode, cropHealthAnalyses_on_field.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['cropType'] = nativeToJson<String>(cropType);
    json['plantedDate'] = nativeToJson<DateTime>(plantedDate);
    if (lastHarvestDate != null) {
      json['lastHarvestDate'] = nativeToJson<DateTime?>(lastHarvestDate);
    }
    if (sizeAcres != null) {
      json['sizeAcres'] = nativeToJson<double?>(sizeAcres);
    }
    json['farm'] = farm.toJson();
    json['treatments_on_field'] = treatments_on_field.map((e) => e.toJson()).toList();
    json['cropHealthAnalyses_on_field'] = cropHealthAnalyses_on_field.map((e) => e.toJson()).toList();
    return json;
  }

  const GetFieldDetailsField({
    required this.id,
    required this.name,
    required this.cropType,
    required this.plantedDate,
    this.lastHarvestDate,
    this.sizeAcres,
    required this.farm,
    required this.treatments_on_field,
    required this.cropHealthAnalyses_on_field,
  });
}

@immutable
class GetFieldDetailsFieldFarm {
  final String id;
  final String name;
  GetFieldDetailsFieldFarm.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetFieldDetailsFieldFarm otherTyped = other as GetFieldDetailsFieldFarm;
    return id == otherTyped.id && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  const GetFieldDetailsFieldFarm({
    required this.id,
    required this.name,
  });
}

@immutable
class GetFieldDetailsFieldTreatmentsOnField {
  final String id;
  final String type;
  final DateTime applicationDate;
  final String? productUsed;
  final String? quantity;
  final String? notes;
  GetFieldDetailsFieldTreatmentsOnField.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  type = nativeFromJson<String>(json['type']),
  applicationDate = nativeFromJson<DateTime>(json['applicationDate']),
  productUsed = json['productUsed'] == null ? null : nativeFromJson<String>(json['productUsed']),
  quantity = json['quantity'] == null ? null : nativeFromJson<String>(json['quantity']),
  notes = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetFieldDetailsFieldTreatmentsOnField otherTyped = other as GetFieldDetailsFieldTreatmentsOnField;
    return id == otherTyped.id && 
    type == otherTyped.type && 
    applicationDate == otherTyped.applicationDate && 
    productUsed == otherTyped.productUsed && 
    quantity == otherTyped.quantity && 
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, type.hashCode, applicationDate.hashCode, productUsed.hashCode, quantity.hashCode, notes.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['type'] = nativeToJson<String>(type);
    json['applicationDate'] = nativeToJson<DateTime>(applicationDate);
    if (productUsed != null) {
      json['productUsed'] = nativeToJson<String?>(productUsed);
    }
    if (quantity != null) {
      json['quantity'] = nativeToJson<String?>(quantity);
    }
    if (notes != null) {
      json['notes'] = nativeToJson<String?>(notes);
    }
    return json;
  }

  const GetFieldDetailsFieldTreatmentsOnField({
    required this.id,
    required this.type,
    required this.applicationDate,
    this.productUsed,
    this.quantity,
    this.notes,
  });
}

@immutable
class GetFieldDetailsFieldCropHealthAnalysesOnField {
  final String id;
  final DateTime analysisDate;
  final String? imageUrl;
  final String? issuesIdentified;
  final String? recommendations;
  final String status;
  GetFieldDetailsFieldCropHealthAnalysesOnField.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  analysisDate = nativeFromJson<DateTime>(json['analysisDate']),
  imageUrl = json['imageUrl'] == null ? null : nativeFromJson<String>(json['imageUrl']),
  issuesIdentified = json['issuesIdentified'] == null ? null : nativeFromJson<String>(json['issuesIdentified']),
  recommendations = json['recommendations'] == null ? null : nativeFromJson<String>(json['recommendations']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetFieldDetailsFieldCropHealthAnalysesOnField otherTyped = other as GetFieldDetailsFieldCropHealthAnalysesOnField;
    return id == otherTyped.id && 
    analysisDate == otherTyped.analysisDate && 
    imageUrl == otherTyped.imageUrl && 
    issuesIdentified == otherTyped.issuesIdentified && 
    recommendations == otherTyped.recommendations && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, analysisDate.hashCode, imageUrl.hashCode, issuesIdentified.hashCode, recommendations.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['analysisDate'] = nativeToJson<DateTime>(analysisDate);
    if (imageUrl != null) {
      json['imageUrl'] = nativeToJson<String?>(imageUrl);
    }
    if (issuesIdentified != null) {
      json['issuesIdentified'] = nativeToJson<String?>(issuesIdentified);
    }
    if (recommendations != null) {
      json['recommendations'] = nativeToJson<String?>(recommendations);
    }
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  const GetFieldDetailsFieldCropHealthAnalysesOnField({
    required this.id,
    required this.analysisDate,
    this.imageUrl,
    this.issuesIdentified,
    this.recommendations,
    required this.status,
  });
}

@immutable
class GetFieldDetailsData {
  final GetFieldDetailsField? field;
  GetFieldDetailsData.fromJson(dynamic json):
  
  field = json['field'] == null ? null : GetFieldDetailsField.fromJson(json['field']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetFieldDetailsData otherTyped = other as GetFieldDetailsData;
    return field == otherTyped.field;
    
  }
  @override
  int get hashCode => field.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (field != null) {
      json['field'] = field!.toJson();
    }
    return json;
  }

  const GetFieldDetailsData({
    this.field,
  });
}

@immutable
class GetFieldDetailsVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetFieldDetailsVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetFieldDetailsVariables otherTyped = other as GetFieldDetailsVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetFieldDetailsVariables({
    required this.id,
  });
}

