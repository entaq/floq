import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { print } from "util";
import { COMMENT_ADDED } from "./Alerts";
import {
  REF_ANALYTICS,
  REF_COMMENTS,
  REF_FLOQS,
  REF_FLPHOTOS,
  REF_PHOTOS,
  REF_TOKENS,
  REF_USERS,
  FIELD_userUID,
  FIELD_CLIQ_ID,
  FIELD_COMMENTOR,
  FIELD_FLAGGED,
  FIELD_FLAGGERS,
  FIELD_followers,
  FIELD_username,
  FIELD_cliqname,
  FIELD_instanceToken,
  FIELD_COUNT,
  DOC_CLIQS,
  FIELD_COMMENTOR_ID,
  FIELD_PHOTOID,
  FIELD_cliqCount
} from "./Constants";
// tslint:disable-next-line:no-implicit-dependencies
import { FieldValue } from "@google-cloud/firestore";

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
        const tokens = [];
        const tokdata = tokenSnap.data();
        for (const t_key of Object.keys(tokdata)) {
          if (t_key === FIELD_instanceToken) {
            tokens.push(tokdata[t_key]);
            continue;
          }
          if (typeof tokdata[t_key] === "object") {
            const tok = tokdata[t_key][FIELD_instanceToken];
            if (typeof tok === "string") {
              tokens.push(tok);
            }
          }
        } // tokenSnap.get(FIELD_instanceToken);
        const messages = [];
        tokens.forEach(x => {
          const message = {
            notification: {
              title: "Photo Added!!",
              body: `A new photo was added to ${cliqName} album by ${username}. Check it out now !!`
            },
            data: {
              cliqID: cliqID
            },
            token: x
          };
          messages.push(message);
        });

        messages.forEach(message => {
          promise = admin.messaging().send(message);
        });
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
        const tokens = [];
        const tokdata = tokenSnap.data();
        for (const t_key of Object.keys(tokdata)) {
          if (t_key === FIELD_instanceToken) {
            tokens.push(tokdata[t_key]);
            continue;
          }
          if (typeof tokdata[t_key] === "object") {
            const tok = tokdata[t_key][FIELD_instanceToken];
            if (typeof tok === "string") {
              tokens.push(tok);
            }
          }
        }

        const messages = [];
        tokens.forEach(x => {
          const message = {
            notification: {
              title: "New Follower",
              body: `${username} just joined your cliq ${cliqName}. Check it out now !!`
            },
            data: {
              cliqID: cliqID
            },
            token: x
          };
          messages.push(message);
        });

        messages.forEach(message => {
          promise = admin.messaging().send(message);
        });
        return promise;
        // console.log(`The payload is ${message}`);
        // promise = admin.messaging().send(message);
      }
      return promise;
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

/**
 * Analytics
 */

export const incrementUsers = functions.firestore
  .document(`${REF_USERS}/{id}`)
  .onCreate(async (snap, context) => {
    const currentCount = await store
      .collection(REF_ANALYTICS)
      .doc("Users")
      .get();
    const count = currentCount.get("count");
    const resp = await store
      .collection(REF_ANALYTICS)
      .doc("Users")
      .update({ count: count + 1 });
    return resp;
  });

export const decrementUsers = functions.firestore
  .document(`${REF_USERS}/{id}`)
  .onDelete(async (snap, context) => {
    const currentCount = await store
      .collection(REF_ANALYTICS)
      .doc("Users")
      .get();
    const count = currentCount.get("count");
    const resp = await store
      .collection(REF_ANALYTICS)
      .doc("Users")
      .update({ count: count - 1 });
    return resp;
  });

export const countPhotos = functions.firestore
  .document(`${REF_FLPHOTOS}/{id}`)
  .onCreate(async (snap, context) => {
    const currentCount = await store
      .collection(REF_ANALYTICS)
      .doc("Photos")
      .get();
    const count = currentCount.get("count");
    const resp = await store
      .collection(REF_ANALYTICS)
      .doc("Photos")
      .update({ count: count + 1 });
    return resp;
  });

export const notifyForComment = functions.firestore
  .document(`${REF_COMMENTS}/{id}`)
  .onCreate(async (snap, context) => {
    const cliqID = snap.get(FIELD_CLIQ_ID);
    const photoID = snap.get(FIELD_PHOTOID);
    const posterID = snap.get(FIELD_COMMENTOR_ID);
    const commentor = snap.get(FIELD_COMMENTOR);

    const cliq = await store
      .collection(REF_FLOQS)
      .doc(cliqID)
      .get();

    const cliqName = cliq.get(FIELD_cliqname);
    let promise = Promise.resolve("Nothing");

    const followers = cliq.get(FIELD_followers);
    const total = followers.length;

    for (let i = 0; i < total; i++) {
      const key = followers[i];
      if (key != posterID) {
        const tokenSnap = await store.doc(`${REF_TOKENS}/${key}`).get();
        const tokens = [];
        const tokdata = tokenSnap.data();
        for (const t_key of Object.keys(tokdata)) {
          if (t_key === FIELD_instanceToken) {
            tokens.push(tokdata[t_key]);
            continue;
          }
          if (typeof tokdata[t_key] === "object") {
            const tok = tokdata[t_key][FIELD_instanceToken];
            if (typeof tok === "string") {
              tokens.push(tok);
            }
          }
        }
        console.log(!`The tokens are : ${tokens}`);

        const messages = [];
        tokens.forEach(x => {
          const message = {
            notification: {
              title: "New Comment",
              body: `${commentor} just added a new comment to ${cliqName} Cliq`
            },
            data: {
              cliqID: cliqID,
              photoID: photoID,
              type: COMMENT_ADDED
            },
            token: x
          };
          messages.push(message);
          console.log(`Token is is: ${x}`);
        });

        messages.forEach(message => {
          promise = admin.messaging().send(message);
        });
      }
    }
    return promise;
  });

/**
 * Tests and database maintenance
 */

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
    try {
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
    } catch (err) {
      console.log(`Error occurred with: ${err}`);
    }
  }
);

export const flattenPhotosFromCliqs = functions.https.onRequest(
  async (request, response) => {
    const batch = store.batch();
    try {
      const allCliqs = await store.collection(REF_FLOQS).get();
      for (const doc of allCliqs.docs) {
        const id = doc.id;
        const photos = await store
          .collection(REF_FLOQS)
          .doc(id)
          .collection(REF_PHOTOS)
          .get();
        photos.docs.forEach(x => {
          let data = x.data();
          data[FIELD_CLIQ_ID] = id;
          const ref = store.collection(REF_FLPHOTOS).doc(x.id);
          batch.set(ref, data, { merge: true });
        });
      }

      const resp = batch.commit();
      response.status(200).send(resp);
    } catch (e) {
      console.log(`Error coccurred with sig: ${e}`);
      response.status(500).send(e);
    }
  }
);

export const alignOldPhotoSchematoNew = functions.firestore
  .document(`${REF_FLOQS}/{cliqId}/${REF_PHOTOS}/{photoId}`)
  .onCreate(async (snap, context) => {
    try {
      const id = context.params.id;
      const data = snap.data();
      data[FIELD_CLIQ_ID] = id;
      const op = store
        .collection(REF_FLPHOTOS)
        .doc(snap.id)
        .set(data, { merge: true });
      return Promise.resolve(op);
    } catch (e) {
      console.log(`Error occurred with sig: ${e}`);
      return Promise.reject(e);
    }
  });

export const copyOldCommentSubs = functions.https.onRequest(
  async (request, response) => {
    const count = "cliqComments";
    const batch = store.batch();

    try {
      const querySnap = await store.collection("FLCommentSubscriptions").get();

      querySnap.docs.forEach(doc => {
        const newData = {};
        const id = doc.id;
        const data = doc.data();
        newData[count] = data.cliqComments;
        newData["lastUpdated"] = FieldValue.serverTimestamp();
        for (const key of Object.keys(data)) {
          if (key != "cliqComments") {
            const photocount = data[key];
            const photodata = {
              count: photocount,
              lastUpdated: FieldValue.serverTimestamp(),
              userID: ""
            };
            newData[key] = photodata;
          }
        }

        const ref = store.doc(`FLCliqCommentSubscriptions/${id}`);
        console.log("=============");
        console.log(newData);
        console.log(ref);

        batch.set(ref, newData, { merge: true });
      });

      const msg = batch.commit();
      response.status(200).send(msg);
    } catch (e) {
      console.log(`Error occurred with sig: ${e}`);
      response.status(504).send(e);
    }
  }
);

/**
   * 
   * 1
(number)
595006068242
2
595006591726
2
595084033861
2
cliqComments
7
   */
