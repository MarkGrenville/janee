import * as functionsV1 from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onUserCreate = functionsV1.auth.user().onCreate(async (user) => {
  console.log(`[trigger:onUserCreate] New user signed up: ${user.uid} (${user.email})`);

  try {
    await admin.firestore().collection("users").doc(user.uid).set({
      displayName: user.displayName || user.email?.split("@")[0] || "Anonymous",
      email: user.email || "",
      photoURL: user.photoURL || "",
      publicProfile: false,
      bio: "",
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    console.log(`[trigger:onUserCreate] Created user profile for ${user.uid}`);
  } catch (err) {
    console.log(`[trigger:onUserCreate] Error creating profile for ${user.uid}:`, err);
  }
});
