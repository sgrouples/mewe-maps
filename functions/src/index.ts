import * as admin from "firebase-admin";
admin.initializeApp();

import { onLocationRequestCreate } from "./triggers/firestore/onLocationRequestCreate";

export {
  onLocationRequestCreate,
};
