import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

const fcm = admin.messaging();

export const newEvent = functions.firestore
    .document("events/{eventId}")
    .onCreate(async snapshot => {

        const event = snapshot.data();
        const title = event.title;

        var date = new Date(0); // The 0 there is the key, which sets the date to the epoch
        
        date.setMilliseconds(event.date);

        const querySnapshot = await db.collection("users").get();

        const tokens = new Array();

        querySnapshot.forEach(async user => {
            if (event.managerId === user.data().uid) {
                tokens.push(user.data().token);
            }
        });

        const payload: admin.messaging.MessagingPayload =
        {
            notification: {
                title: title,
                body: date.toISOString().slice(0,10),
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                "priority": "high",
            },

            data: {
                sound: "default",
                status: "newEvent",
                screen: "newEvent",
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
        };

        return fcm.sendToDevice(tokens, payload);

    });