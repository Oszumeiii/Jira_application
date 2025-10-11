const { initializeApp, applicationDefault, cert } = from ('firebase-admin/app');
const { getFirestore } = from('firebase-admin/firestore');
const serviceAccount = from('../google-services.json');

// Replace the following with your service account credentials

initializeApp({
    credential: cert(serviceAccount)
});

const db = getFirestore();

module.exports = db;