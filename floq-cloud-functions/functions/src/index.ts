import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const REF_FLOQS = "FLFLOQs";
const REF_PHOTOS = "Photos";
const REF_TOKENS = "FLTOKENS";
const FIELD_fileID = "fileID";
const FIELD_username = "userName";
const FIELD_dateCreated = "dateCreated";
const FIELD_timestamp = "timestamp";
const FIELD_cliqname = "cliqName";
const FIELD_uid = "uid";
const FIELD_profileImg = "profileUrl";
const FIELD_userUID = "userID";
const FIELD_userEmail = "userEmail";
const FIELD_latestCliq = "latestCliq";
const FIELD_cliqCount = "cliqCount";
const FIELD_dateJoined = "dateJoined";
const FIELD_followers = "followers";
const FIELD_deleted = "deleted";
const FIELD_dateDeleted = "dateDeleted";
const FIELD_instanceToken = "instanceToken";
const REF_ANALYTICS = "FLANALYTICS";
const DOC_CLIQS = "Cliqs";
const FIELD_COUNT = "count";

admin.initializeApp();
const store = admin.firestore();

const rsettings = { timestampsInSnapshots: true };
store.settings(rsettings);

export const photoAdded = functions.firestore
  .document(`${REF_FLOQS}/{cliqID}/${REF_PHOTOS}/{photoID}`)
  .onCreate(async (snap, context) => {
    let promise = Promise.resolve("Nothing");
    const username = snap.get(FIELD_username);
    const posterID = snap.get(FIELD_userUID);
    const cliqID = context.params.cliqID;
    const cliq = await store.doc(`${REF_FLOQS}/${cliqID}`).get();
    const followers = cliq.get(FIELD_followers);
    const cliqName = cliq.get(FIELD_cliqname);
    for (const key in followers) {
      if (key !== posterID) {
        const tokenSnap = await store.doc(`${REF_TOKENS}/${key}`).get();
        const token = tokenSnap.get(FIELD_instanceToken);
        const message = {
          notification: {
            title: "Photo Added!!",
            body: `A new photo was added to ${cliqName} album by ${username}. Check it out now !!`
          },
          data: {
            cliqID: cliqID
          },
          token: token
        };
        promise = admin.messaging().send(message);
      }
    }
    return promise;
  });

export const analyticsOnCliqs = functions.firestore
  .document(`${REF_FLOQS}/{id}`)
  .onCreate(async (snap, context) => {
    var ref = store.doc(`${REF_ANALYTICS}/${DOC_CLIQS}`);
    return store
      .runTransaction(trans => {
        return trans.get(ref).then(docsnap => {
          var newCount = docsnap.get(FIELD_COUNT) + 1;
          trans.update(ref, { [FIELD_COUNT]: newCount });
        });
      })
      .then(result => {
        console.log(`Transaction succesful ${result}`);
      })
      .catch(err => {
        console.log(`Error occurred with sig: ${err}`);
      });
  });

export const testFunctionsWorks = functions.https.onRequest(
  (request, response) => {
    response.send("Hello from Firebase, Im working fully!");
  }
);
