import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const REF_FLOQS = "FLFLOQs";
const REF_PHOTOS = "Photos";
const REF_TOKENS = "FLTOKENS";
const REF_USERS = "FLUSER";
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
const FIELD_FLAGGED = "flagged";
const FIELD_FLAGGERS = "flaggers";

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

    const total = followers.length;
    for (let i = 0; i < total; i++) {
      const key = followers[i];
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
        console.log(`The payload is ${message}`);
        promise = admin.messaging().send(message);
      }
    }
    return promise;
  });

export const joinedNotification = functions.firestore
  .document(`${REF_FLOQS}/{cliqID}`)
  .onUpdate(async (snap, context) => {
    const updateCliq = snap.after;
    let promise = Promise.resolve("Nothing");
    const followers: Array<string> = updateCliq.get(FIELD_followers);
    const followerID = followers[followers.length - 1];
    const newfollower = await store
      .collection(REF_USERS)
      .doc(followerID)
      .get();
    const username = newfollower.get(FIELD_username);
    const cliqName = updateCliq.get(FIELD_cliqname);
    const total = snap.before.get(FIELD_followers).length;
    const cliqID = updateCliq.id;
    for (let i = 0; i < total; i++) {
      const key = followers[i];
      if (key !== followerID) {
        const tokenSnap = await store.doc(`${REF_TOKENS}/${key}`).get();
        const token = tokenSnap.get(FIELD_instanceToken);

        const message = {
          notification: {
            title: "New Follower",
            body: `${username} just joined your cliq ${cliqName}. Check it out now !!`
          },
          data: {
            cliqID: cliqID
          },
          token: token
        };
        console.log(`The payload is ${message}`);
        promise = admin.messaging().send(message);
      }
    }
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
  async (request, response) => {
    const alldocs = await store.collection(REF_FLOQS).get();
    let batch = store.batch();
    alldocs.forEach(element => {
      let data = element.data();
      let followers = data[FIELD_followers];
      if (Array.isArray(followers)) {
        let y = 0;
      } else {
        let arrdata = [];
        for (const key in followers) {
          arrdata.push(key);
        }
        batch.update(element.ref, { [FIELD_followers]: arrdata });
      }
    });

    batch
      .commit()
      .then(x => {
        response.status(200).send(x);
      })
      .catch(err => {
        response.status(404).send(err);
      });
  }
);

export const reAlignDatabase = functions.https.onRequest(
  async (request, response) => {
    const batch = store.batch();
    const docs = await store.collection(REF_USERS).get();
    for (const doc of docs.docs) {
      const id = doc.id;
      const mydocs = await store
        .collection(REF_FLOQS)
        .where(FIELD_followers, "array-contains", id)
        .get();
      const count = mydocs.size;
      batch.update(doc.ref, { [FIELD_cliqCount]: count });
    }

    batch
      .commit()
      .then(x => {
        response.status(200).send(x);
      })
      .catch(err => {
        response.status(404).send(err);
      });
  }
);

export const reAlignFlaggingFaults = functions.https.onRequest(
  async (request, response) => {
    const batch = store.batch();
    const cliqs = await store.collection(REF_FLOQS).get();

    for (const doc of cliqs.docs) {
      const id = doc.id;
      const photos = await store
        .collection(REF_FLOQS)
        .doc(id)
        .collection(REF_PHOTOS)
        .get();
      photos.docs.forEach(element => {
        const update = { [FIELD_FLAGGED]: false, [FIELD_FLAGGERS]: [] };
        batch.update(element.ref, update);
      });
    }

    const resp = await batch.commit();
    response.status(200).send(resp);
  }
);
