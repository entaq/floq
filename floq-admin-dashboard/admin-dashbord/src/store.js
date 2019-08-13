import { createStore, combineReducers, compose } from "redux";
import firebase from "firebase";
import "firebase/firestore";
import { reactReduxFirebase, firebaseReducer } from "react-redux-firebase";
import { reduxFirestore, firestoreReducer } from "redux-firestore";

//Reducers

const firebaseConfig = {
  apiKey: "AIzaSyAeU5DOfojvyeJRjgNEf9fs4TXltW-K3MA",
  authDomain: "floq-4fe74.firebaseapp.com",
  databaseURL: "https://floq-4fe74.firebaseio.com",
  projectId: "floq-4fe74",
  storageBucket: "floq-4fe74.appspot.com",
  messagingSenderId: "1049089634264"
};

//react- redux firebase config
const rrfConfig = {
  userProfiles: "users",
  usesFirestoreForProfiles: true
};

firebase.initializeApp(firebaseConfig);

//Init firestore

const firestore = firebase.firestore();

// Add reduxFirestore store enhancer to store creator

const createFirestoreWithFirebase = compose(
  reactReduxFirebase(firebase, rrfConfig),
  reduxFirestore(firebase)
)(createStore);

const rootReducers = combineReducers({
  firebase: firebaseReducer,
  firestore: firestoreReducer
});

const initialState = {};

const store = createFirestoreWithFirebase(
  rootReducers,
  initialState,
  compose(
    reactReduxFirebase(firebase),
    window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
  )
);

export default store;
