const functions = require("firebase-functions");
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");
const { firestore } = require("firebase-admin");

const ALGOLIA_APP_ID = "HFCBBSGQ73";
const ALGOLIA_ADMIN_KEY = "0af3761cf932c61a0c4c157e313058e0";
const GROUPS_ALGOLIA_INDEX_NAME = "groups";
const USERS_ALGOLIA_INDEX_NAME = "users";

admin.initializeApp(functions.config().firebase);
//const firestore = admin.firestore;

// user algolia data
exports.createUser = functions.firestore
  .document("users/{UserId}")
  .onCreate(async (snap, context) => {
    const newValue = snap.data();
    newValue.objectID = snap.id;

    var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

    var index = client.initIndex(USERS_ALGOLIA_INDEX_NAME);
    index.saveObject(newValue);
    console.log("Finished");
  });

exports.updateUser = functions.firestore
  .document("users/{UserId}")
  .onUpdate(async (snap, context) => {
    const afterUpdate = snap.after.data();
    afterUpdate.objectID = snap.after.id;

    var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

    var index = client.initIndex(USERS_ALGOLIA_INDEX_NAME);
    index.saveObject(afterUpdate);
  });

exports.deleteUser = functions.firestore
  .document("users/{UserId}")
  .onDelete(async (snap, context) => {
    const oldID = snap.id;
    var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

    var index = client.initIndex(USERS_ALGOLIA_INDEX_NAME);
    index.deleteObject(oldID);
  });

//groups aloglia data implementation
exports.createGroup = functions.firestore
  .document("groups/{groupId}")
  .onCreate(async (snap, context) => {
    const newValue = snap.data();
    newValue.objectID = snap.id;

    var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

    var index = client.initIndex(GROUPS_ALGOLIA_INDEX_NAME);
    index.saveObject(newValue);
    console.log("Finished");
  });

exports.updateGroup = functions.firestore
  .document("groups/{groupId}")
  .onUpdate(async (snap, context) => {
    const afterUpdate = snap.after.data();
    afterUpdate.objectID = snap.after.id;

    var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

    var index = client.initIndex(GROUPS_ALGOLIA_INDEX_NAME);
    index.saveObject(afterUpdate);
  });

exports.deleteGroup = functions.firestore
  .document("groups/{groupId}")
  .onDelete(async (snap, context) => {
    const oldID = snap.id;
    var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

    var index = client.initIndex(GROUPS_ALGOLIA_INDEX_NAME);
    index.deleteObject(oldID);
  });

// send notification to group users
exports.onCreateMessageItem = functions.firestore
  .document("groups/{groupId}/groupMessages/{messageId}")
  .onCreate(async (snapshot, context) => {
    console.log("Messages Item Created", snapshot.data());
    // 1) Get user connected to the feed
    const groupId = context.params.groupId;
    const groupMessageItem = snapshot.data();
    const senderId = groupMessageItem.senderId;
    const username = groupMessageItem.senderName;
    // const userRef = admin.firestore().doc(`users/${userId}`);

    firestore()
      .collection("groups")
      .doc(groupId)
      .collection("groupMembers")
      .get()
      .then(function (docs) {
        docs.forEach((data) => {
          console.log(data.id, "=>", data.data());

          firestore()
            .collection("users")
            .doc(data.id)
            .get()
            .then(function (doc) {
              // 2) Once we have user, check if they have a notification token; send notification, if they have a token
              const androidNotificationToken = doc.data().notificationToken;

              if (androidNotificationToken) {
                sendNotification(androidNotificationToken, doc.id, username);
              } else {
                console.log("No token for user, cannot send notification");
              }
            });
        });
      });

    // const doc = await userRef.get();

    function sendNotification(androidNotificationToken, userId, username) {
      let body;

      title = `New message from ` + username;
      // 4) Create message for push notification
      const message = {
        notification: {
          title: title,
          body: groupMessageItem.message,
        },
        token: androidNotificationToken,
        data: {
          recipient: userId,
          sender: `${username}`,
        },
      };

      // 5) Send message with admin.messaging()
      if (senderId != userId) {
        admin
          .messaging()
          .send(message)
          .then((response) => {
            // Response is a message ID string
            console.log("Successfully sent message", response);
          })
          .catch((error) => {
            console.log("Error sending message", error);
          });
      }
    }
  });
