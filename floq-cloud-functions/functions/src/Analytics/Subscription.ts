import * as admin from "firebase-admin";
import { DocumentSnapshot, FieldValue } from "@google-cloud/firestore";
import {
  FIELD_CLIQ_ID,
  FIELD_PHOTOID,
  FIELD_CLIQ_CMT_TOTAL
} from "../Constants";

export function updateSubscription(
  store: FirebaseFirestore.Firestore,
  snap: DocumentSnapshot
) {
  const cliqID = snap.get(FIELD_CLIQ_ID);
  const photoID = snap.get(FIELD_PHOTOID);
  const batch = store.batch();
  const data = {
    // [FIELD_CLIQ_CMT_TOTAL] : FieldValue
  };
}
