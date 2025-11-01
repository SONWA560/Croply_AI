part of 'example.dart';

class CreateFieldVariablesBuilder {
  String farmId;
  String name;
  String cropType;
  DateTime plantedDate;
  final Optional<DateTime> _lastHarvestDate = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<double> _sizeAcres = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateFieldVariablesBuilder lastHarvestDate(DateTime? t) {
   _lastHarvestDate.value = t;
   return this;
  }
  CreateFieldVariablesBuilder sizeAcres(double? t) {
   _sizeAcres.value = t;
   return this;
  }

  CreateFieldVariablesBuilder(this._dataConnect, {required  this.farmId,required  this.name,required  this.cropType,required  this.plantedDate,});
  Deserializer<CreateFieldData> dataDeserializer = (dynamic json)  => CreateFieldData.fromJson(jsonDecode(json));
  Serializer<CreateFieldVariables> varsSerializer = (CreateFieldVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateFieldData, CreateFieldVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateFieldData, CreateFieldVariables> ref() {
    CreateFieldVariables vars= CreateFieldVariables(farmId: farmId,name: name,cropType: cropType,plantedDate: plantedDate,lastHarvestDate: _lastHarvestDate,sizeAcres: _sizeAcres,);
    return _dataConnect.mutation("CreateField", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateFieldFieldInsert {
  final String id;
  CreateFieldFieldInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateFieldFieldInsert otherTyped = other as CreateFieldFieldInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateFieldFieldInsert({
    required this.id,
  });
}

@immutable
class CreateFieldData {
  final CreateFieldFieldInsert field_insert;
  CreateFieldData.fromJson(dynamic json):
  
  field_insert = CreateFieldFieldInsert.fromJson(json['field_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateFieldData otherTyped = other as CreateFieldData;
    return field_insert == otherTyped.field_insert;
    
  }
  @override
  int get hashCode => field_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['field_insert'] = field_insert.toJson();
    return json;
  }

  const CreateFieldData({
    required this.field_insert,
  });
}

@immutable
class CreateFieldVariables {
  final String farmId;
  final String name;
  final String cropType;
  final DateTime plantedDate;
  final Optional<DateTime> lastHarvestDate;
  final Optional<double> sizeAcres;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateFieldVariables.fromJson(Map<String, dynamic> json):
  
  farmId = nativeFromJson<String>(json['farmId']),
  name = nativeFromJson<String>(json['name']),
  cropType = nativeFromJson<String>(json['cropType']),
  plantedDate = nativeFromJson<DateTime>(json['plantedDate']),
  lastHarvestDate = (() {
    final o = Optional<DateTime>.optional(nativeFromJson, nativeToJson);
    o.value = json['lastHarvestDate'] == null ? null : nativeFromJson<DateTime>(json['lastHarvestDate']);
    return o;
  })(),
  sizeAcres = (() {
    final o = Optional<double>.optional(nativeFromJson, nativeToJson);
    o.value = json['sizeAcres'] == null ? null : nativeFromJson<double>(json['sizeAcres']);
    return o;
  })();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateFieldVariables otherTyped = other as CreateFieldVariables;
    return farmId == otherTyped.farmId && 
    name == otherTyped.name && 
    cropType == otherTyped.cropType && 
    plantedDate == otherTyped.plantedDate && 
    lastHarvestDate == otherTyped.lastHarvestDate && 
    sizeAcres == otherTyped.sizeAcres;
    
  }
  @override
  int get hashCode => Object.hashAll([farmId.hashCode, name.hashCode, cropType.hashCode, plantedDate.hashCode, lastHarvestDate.hashCode, sizeAcres.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['farmId'] = nativeToJson<String>(farmId);
    json['name'] = nativeToJson<String>(name);
    json['cropType'] = nativeToJson<String>(cropType);
    json['plantedDate'] = nativeToJson<DateTime>(plantedDate);
    if(lastHarvestDate.state == OptionalState.set) {
      json['lastHarvestDate'] = lastHarvestDate.toJson();
    }
    if(sizeAcres.state == OptionalState.set) {
      json['sizeAcres'] = sizeAcres.toJson();
    }
    return json;
  }

  const CreateFieldVariables({
    required this.farmId,
    required this.name,
    required this.cropType,
    required this.plantedDate,
    required this.lastHarvestDate,
    required this.sizeAcres,
  });
}

