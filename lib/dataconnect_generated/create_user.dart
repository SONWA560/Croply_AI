part of 'example.dart';

class CreateUserVariablesBuilder {
  String displayName;
  String email;
  final Optional<String> _farmName = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<String> _location = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<String> _phoneNumber = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateUserVariablesBuilder farmName(String? t) {
   _farmName.value = t;
   return this;
  }
  CreateUserVariablesBuilder location(String? t) {
   _location.value = t;
   return this;
  }
  CreateUserVariablesBuilder phoneNumber(String? t) {
   _phoneNumber.value = t;
   return this;
  }

  CreateUserVariablesBuilder(this._dataConnect, {required  this.displayName,required  this.email,});
  Deserializer<CreateUserData> dataDeserializer = (dynamic json)  => CreateUserData.fromJson(jsonDecode(json));
  Serializer<CreateUserVariables> varsSerializer = (CreateUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateUserData, CreateUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUserData, CreateUserVariables> ref() {
    CreateUserVariables vars= CreateUserVariables(displayName: displayName,email: email,farmName: _farmName,location: _location,phoneNumber: _phoneNumber,);
    return _dataConnect.mutation("CreateUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateUserUserInsert {
  final String id;
  CreateUserUserInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserUserInsert otherTyped = other as CreateUserUserInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateUserUserInsert({
    required this.id,
  });
}

@immutable
class CreateUserData {
  final CreateUserUserInsert user_insert;
  CreateUserData.fromJson(dynamic json):
  
  user_insert = CreateUserUserInsert.fromJson(json['user_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserData otherTyped = other as CreateUserData;
    return user_insert == otherTyped.user_insert;
    
  }
  @override
  int get hashCode => user_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_insert'] = user_insert.toJson();
    return json;
  }

  const CreateUserData({
    required this.user_insert,
  });
}

@immutable
class CreateUserVariables {
  final String displayName;
  final String email;
  Optional<String> farmName;
  Optional<String> location;
  Optional<String> phoneNumber;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateUserVariables.fromJson(Map<String, dynamic> json, this.farmName, this.location, this.phoneNumber):
  
  displayName = nativeFromJson<String>(json['displayName']),
  email = nativeFromJson<String>(json['email']) {
  
  
  
  
    farmName = Optional.optional(nativeFromJson, nativeToJson);
    farmName.value = json['farmName'] == null ? null : nativeFromJson<String>(json['farmName']);
  
  
    location = Optional.optional(nativeFromJson, nativeToJson);
    location.value = json['location'] == null ? null : nativeFromJson<String>(json['location']);
  
  
    phoneNumber = Optional.optional(nativeFromJson, nativeToJson);
    phoneNumber.value = json['phoneNumber'] == null ? null : nativeFromJson<String>(json['phoneNumber']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserVariables otherTyped = other as CreateUserVariables;
    return displayName == otherTyped.displayName && 
    email == otherTyped.email && 
    farmName == otherTyped.farmName && 
    location == otherTyped.location && 
    phoneNumber == otherTyped.phoneNumber;
    
  }
  @override
  int get hashCode => Object.hashAll([displayName.hashCode, email.hashCode, farmName.hashCode, location.hashCode, phoneNumber.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['displayName'] = nativeToJson<String>(displayName);
    json['email'] = nativeToJson<String>(email);
    if(farmName.state == OptionalState.set) {
      json['farmName'] = farmName.toJson();
    }
    if(location.state == OptionalState.set) {
      json['location'] = location.toJson();
    }
    if(phoneNumber.state == OptionalState.set) {
      json['phoneNumber'] = phoneNumber.toJson();
    }
    return json;
  }

  CreateUserVariables({
    required this.displayName,
    required this.email,
    required this.farmName,
    required this.location,
    required this.phoneNumber,
  });
}

