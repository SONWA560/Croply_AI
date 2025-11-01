library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'get_my_farms.dart';

part 'create_field.dart';

part 'get_field_details.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser ({required String displayName, required String email, }) {
    return CreateUserVariablesBuilder(dataConnect, displayName: displayName,email: email,);
  }
  
  
  GetMyFarmsVariablesBuilder getMyFarms () {
    return GetMyFarmsVariablesBuilder(dataConnect, );
  }
  
  
  CreateFieldVariablesBuilder createField ({required String farmId, required String name, required String cropType, required DateTime plantedDate, }) {
    return CreateFieldVariablesBuilder(dataConnect, farmId: farmId,name: name,cropType: cropType,plantedDate: plantedDate,);
  }
  
  
  GetFieldDetailsVariablesBuilder getFieldDetails ({required String id, }) {
    return GetFieldDetailsVariablesBuilder(dataConnect, id: id,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'croplyai',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

