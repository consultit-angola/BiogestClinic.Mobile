# Firebase Cloud Messaging setup

The application is prepared to use Socket.IO while it is active and Firebase Cloud Messaging when Android places it in the background or terminates its process. FCM remains disabled until all Firebase values are configured.

## Firebase Console

1. Create or select the Firebase project.
2. Register an Android application with package name `com.consultitangola.biogestclinic.mobile`.
3. Copy these values from the Android application configuration into the local `.env` file and into the `BIOGEST_ENV` GitHub Actions secret:

```dotenv
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
```

These Android identifiers configure the client but are not Firebase Admin credentials.

## Socket server

1. In Firebase Console, create a service account key for the Firebase Admin SDK.
2. Keep the downloaded JSON outside both repositories.
3. Encode the complete JSON file as Base64 and create the SocketIO repository secret `BIOGEST_FIREBASE_SERVICE_ACCOUNT_BASE64`.
4. Deploy `BiogestClinic.SocketIO`. The workflow provisions the JSON under the server deployment root and configures `FIREBASE_SERVICE_ACCOUNT_PATH` automatically.

The SocketIO server requires Node.js 22 or newer. Its deployment workflow upgrades the host runtime to Node.js 22.23.2.

## Verification

1. Build and install MyBio on an Android device with Google Play services.
2. Sign in and accept the notification permission.
3. Confirm that the SocketIO SQLite database contains a device token for the user's channel.
4. Send a chat message while MyBio is open: Socket.IO must update the chat immediately.
5. Send a message while MyBio is in the background and again after closing it: Android must display the FCM notification.
6. Send several messages from the same user and then from another user: supported launchers must show the number of distinct unread senders, not the number of messages.

Do not use Android's **Force stop** action for the closed-app test. Android blocks background delivery to a force-stopped application until the user opens it again.
