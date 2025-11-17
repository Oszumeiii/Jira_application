import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';
import 'dotenv/config'; 

const serviceAccountPath = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;

if (!serviceAccountPath) {
  throw new Error('Environment variable GOOGLE_SERVICE_ACCOUNT_JSON not set!');
}

const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

initializeApp({
  credential: cert(serviceAccount),
});

export const db = getFirestore();
