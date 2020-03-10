class FirestoreCollections {
  static String users = 'users';
  static String invoices = 'invoices';
  static String products = 'products';
  static String locations = 'locations';
  static String vehicles = 'vehicles';
  static String vehicleType = 'vehicleType';
  static String customers = 'customers';
  static String additionalProducts = 'additionalProducts';
  static String brands = 'brands';
  static String colors = 'colors';
  static String brandReferences = 'brandReferences';

  /// Fields User Collection
  static String usersFieldUid = 'uid';
  static String usersFieldName = 'name';
  static String photoUrl = 'photoUrl';
  static String usersFieldEmail = 'email';
  static String usersFieldIsAdministrator = 'isAdministrator';
  static String usersFieldIsCoordinator = 'isCoordinator';
  static String usersFieldIsOperator = 'isOperator';
  static String usersFieldLocations = 'locations';
  static String usersFieldUserActive = 'active';

  ///Fields Vehicle Collection
  static String vehiclesFieldPlaca = 'placa';
  static String vehiclesFieldId = 'id';

  /// Fields Vehicle Type Collection
  static String vehicleTypeFieldVehicleType = 'vehicleType';
  static String vehicleTypeFieldUid = 'uid';

  /// Fields Product Collection
  static String productFieldProductName = 'productName';
  static String productFieldLocations = 'locations';
  static String productFieldUidVehicleType = 'vehicleTypeUid';
  static String productFieldProductActive = 'productActive';

  /// Fields Customer Collections
  static String customerFieldVehicles = 'vehicles';
  static String customerFieldPhoneNumber = 'phoneNumber';
  static String customerFieldCreationDate = 'creationDate';
  static String customerFieldEmail = 'email';

  /// Fields Invoice Collections
  static String invoiceFieldCreationDate = 'creationDate';
  static String invoiceFieldProducts = 'products';
  static String invoiceFieldImages = 'images';
  static String invoiceFieldLocation = 'location';
  static String invoiceFieldConsecutive = 'consecutive';
  static String invoiceFieldPlaca = 'placa';
  static String invoiceFieldUserOperatorName = 'userOperatorName';
  static String invoiceFieldBrand = 'brand';
  static String invoiceFieldHaveSpecialService = 'haveSpecialService';

  /// Fields Brands
  static String brandFieldVehicleType = 'vehicleType';
  static String brandFieldBrand = 'brand';


}