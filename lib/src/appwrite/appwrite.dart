import 'package:appwrite/appwrite.dart';

Client client = Client();
Account account = Account(client);
Databases databases = Databases(client);

void setupAppwrite() {
  client
      .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
      .setProject('66b2f8470035c3c84510'); // Your project ID
}
