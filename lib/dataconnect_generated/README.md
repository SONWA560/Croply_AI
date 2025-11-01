# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetMyFarms
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.getMyFarms().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetMyFarmsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getMyFarms();
GetMyFarmsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.getMyFarms().ref();
ref.execute();

ref.subscribe(...);
```


### GetFieldDetails
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getFieldDetails(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetFieldDetailsData, GetFieldDetailsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getFieldDetails(
  id: id,
);
GetFieldDetailsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getFieldDetails(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateUser
#### Required Arguments
```dart
String displayName = ...;
String email = ...;
ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateUser, we created `CreateUserBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateUserVariablesBuilder {
  ...
   CreateUserVariablesBuilder farmName(String? t) {
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

  ...
}
ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
)
.farmName(farmName)
.location(location)
.phoneNumber(phoneNumber)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateUserData, CreateUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
);
CreateUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String displayName = ...;
String email = ...;

final ref = ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
).ref();
ref.execute();
```


### CreateField
#### Required Arguments
```dart
String farmId = ...;
String name = ...;
String cropType = ...;
DateTime plantedDate = ...;
ExampleConnector.instance.createField(
  farmId: farmId,
  name: name,
  cropType: cropType,
  plantedDate: plantedDate,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateField, we created `CreateFieldBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateFieldVariablesBuilder {
  ...
   CreateFieldVariablesBuilder lastHarvestDate(DateTime? t) {
   _lastHarvestDate.value = t;
   return this;
  }
  CreateFieldVariablesBuilder sizeAcres(double? t) {
   _sizeAcres.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createField(
  farmId: farmId,
  name: name,
  cropType: cropType,
  plantedDate: plantedDate,
)
.lastHarvestDate(lastHarvestDate)
.sizeAcres(sizeAcres)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateFieldData, CreateFieldVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createField(
  farmId: farmId,
  name: name,
  cropType: cropType,
  plantedDate: plantedDate,
);
CreateFieldData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String farmId = ...;
String name = ...;
String cropType = ...;
DateTime plantedDate = ...;

final ref = ExampleConnector.instance.createField(
  farmId: farmId,
  name: name,
  cropType: cropType,
  plantedDate: plantedDate,
).ref();
ref.execute();
```

