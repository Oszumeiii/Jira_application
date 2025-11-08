import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const serviceAccount = require('../jiraapp-46b2d-firebase-adminsdk-fbsvc-92c070394e.json');

initializeApp({
  credential: cert(serviceAccount),
});

export const db = getFirestore();
