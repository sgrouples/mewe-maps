import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onLocationRequestCreate = functions.firestore
  .onDocumentCreated("location_requests/{docId}", async (event) => {
    const snapshot = event.data;
    const data = snapshot ? snapshot.data() : null;

    if (!data) {
      console.error("No data found in the created document.");
      return null;
    }

    const requestData = {
      requestedUserId: data.requested_user_id,
      requestingUserId: data.requesting_user_id,
      requestingUserJsonString: data.requesting_user_raw_data,
      requestedAt: data.requested_at,
    };


    if (
      !requestData.requestedUserId ||
      !requestData.requestingUserId ||
      !requestData.requestingUserJsonString ||
      !requestData.requestedAt
    ) {
      console.error("Missing required fields in the location request. Data: ", String(data));
      return null;
    }

    const requestedUserName = JSON.parse(requestData.requestingUserJsonString).name;

    try {
      const userDoc = await admin
        .firestore()
        .collection("users_private_data")
        .doc(requestData.requestedUserId)
        .get();

      if (!userDoc.exists) {
        console.error(
          `User document with ID ${requestData.requestedUserId} not found.`
        );
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcm_token;

      if (!fcmToken) {
        console.error(
          `No FCM token found for user ${requestData.requestedUserId}.`
        );
        return null;
      }

      console.log(`Sending notification 
        to user ${requestData.requestedUserId}...`);

      const message = {
        token: fcmToken,
        notification: {
          title: "Location Request",
          body: `User ${requestedUserName} requests your location.`,
        },
        data: {
          requestData: String(data),
        },
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to user ${requestData.requestedUserId}.`);
    } catch (error) {
      console.error("Error sending notification:", error);
    }

    return null;
  });
