# Toko Online Customer

A Flutter customer storefront backed by an in-memory Node.js REST API.

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- Node.js 18 or newer
- Android emulator or a connected device

## Installation and run

1. Start the API:

   ```powershell
   cd backend
   npm install
   $env:JWT_SECRET = "replace-with-a-long-random-secret"
   $env:ADMIN_API_KEY = "replace-with-a-secret-admin-key"
   npm start
   ```

   The API listens on port `3000`. Product data, users, and orders are stored in memory and reset when the server restarts.
   Admins can mark a `Diproses` order as `Dikirim` with `PATCH /api/admin/orders/{id}/status` and the `x-admin-key` header. Customers can mark their own shipped orders as `Diterima` in the app.

2. In a second terminal, fetch Flutter packages and start the app:

   ```powershell
   cd app_customer
   flutter pub get
   flutter run
   ```

   Android emulator builds connect to the host API at `10.0.2.2:3000`. iOS simulator and web use `localhost:3000`. For a physical device, update `lib/config/api.dart` to use the development computer's LAN IP address and ensure both devices share the same network.

3. Create an account from the app, or sign in with that account. Orders and account information are in-memory, so they are not retained after restarting the API.
