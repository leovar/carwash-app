class FirestoreCollections {
  static String users = 'users';
  static String invoices = 'invoices';
  static String products = 'products';
  static String locations = 'locations';
  static String vehicles = 'vehicles';
  static String vehicleType = 'vehicleType';
  static String customers = 'customers';
  static String additionalProducts = 'additionalProducts';

  /// Fields User Collection
  static String usersFieldUid = 'uid';
  static String usersFieldName = 'name';
  static String photoUrl = 'photoUrl';
  static String usersFieldEmail = 'email';
  static String usersFieldIsAdministrator = 'isAdministrator';
  static String usersFieldIsCoordinator = 'isCoordinator';
  static String usersFieldIsOperator = 'isOperator';

  ///Fields Vehicle Collection
  static String vehiclesFieldPlaca = 'placa';

  /// Fields Vehicle Type Collection
  static String vehicleTypeFieldVehicleType = 'vehicleType';

  /// Fields Product Collection
  static String productFieldProductName = 'productName';
  static String productFieldLocations = 'locations';

  /// Fields Customer Collections
  static String customerFieldVehicles = 'vehicles';
  static String customerFieldPhoneNumber = 'phoneNumber';
  static String customerFieldCreationDate = 'creationDate';
  static String customerFieldEmail = 'email';


}