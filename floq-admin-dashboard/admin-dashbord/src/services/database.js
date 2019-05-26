import * as firebase from "firebase";

export const REF_FLPHOTOS = "FLPHOTOS";
export const REF_TOKENS = "FLTOKENS";
export const REF_USERS = "FLUSER";
export const FIELD_CLIQ_ID = "cliqID";
export const FIELD_FLAGGED = "flagged";
export const FIELD_FLAGGERS = "flaggers";
export const REF_PHOTOBUCKET = "FLFloqPhotos";
export const REF_CLIQS = "FLFLOQs";
export const FIELD_FILE_ID = "fileID";
export const FIELD_FLAGGED_USER_COUNT = "flagCount";

export const exctractCliqName = cliqID => {
  const split = cliqID.split("-");
  console.log("The splits are: " + split);
  if (split.length > 0) {
    split.pop();
    return split.join(" ");
  } else {
    return "Unknown";
  }
};

export const deleteFlagged = async (id, userId, cliqID, fileID) => {
  const store = firebase.firestore();
  const batch = store.batch();
  const user = await store.doc(`${REF_USERS}/${userId}`).get();
  batch.delete(store.collection(REF_FLPHOTOS).doc(id));
  if (fileID === cliqID) {
    batch.update(store.collection(REF_CLIQS).doc(cliqID), {
      [FIELD_FILE_ID]: "xxx-xxx"
    });
  }
  let count =
    typeof user.get(FIELD_FLAGGED_USER_COUNT) == "number"
      ? user.get(FIELD_FLAGGED_USER_COUNT)
      : 0;
  count = count + 1;
  batch.update(store.collection(REF_USERS).doc(userId), {
    [FIELD_FLAGGED_USER_COUNT]: count
  });

  return batch.commit();
};

export const unflagPhoto = id => {
  const store = firebase.firestore();
  return store
    .collection(REF_FLPHOTOS)
    .doc(id)
    .update({
      [FIELD_FLAGGERS]: firebase.firestore.FieldValue.delete(),
      [FIELD_FLAGGED]: false
    });
};
