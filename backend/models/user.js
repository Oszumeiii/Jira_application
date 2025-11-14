import { db } from "../config/db.js";
import admin from "firebase-admin";

export class User {
  constructor({
    uid = null,
    firstName = "",
    lastName = "",
    userName = "",
    email,
    role = "member",
    status = "active",
    photoUrl = "",
    friends = [],
    createdAt = admin.firestore.FieldValue.serverTimestamp(),
    updatedAt = admin.firestore.FieldValue.serverTimestamp(),
  }) {
    this.uid = uid;                  
    this.firstName = firstName;
    this.lastName = lastName;
    this.userName = userName;
    this.email = email;
    this.role = role;
    this.status = status;
    this.photoUrl = photoUrl;
    this.friends = friends;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }


  async save() {
    if (!this.email) throw new Error("Email is required");

    const payload = {
      uid: this.uid,
      firstName: this.firstName,
      lastName: this.lastName,
      userName: this.userName,
      email: this.email,
      role: this.role,
      status: this.status,
      photoUrl: this.photoUrl,
      friends: this.friends,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };

    const ref = db.collection("users").doc();

    await ref.set({ ...payload, uid: ref.id });

    this.uid = ref.id;

    return this;
  }

static async searchByEmail(emailQuery, limit = 10) {
  if (!emailQuery) return [];
  emailQuery = emailQuery.toLowerCase();
  const snapshot = await db
    .collection("users")
    .orderBy("email")
    .startAt(emailQuery)
    .endAt(emailQuery + '\uf8ff')  
    .limit(limit)
    .get();

  return snapshot.docs.map(doc => doc.data());
}


}


// export class User {
//     constructor({ id = null, name, email, role = "Guest", photoUrl = "", createdAt = Date.now(), updatedAt = Date.now() }) {
//     this.id = id;
//     this.name = name;
//     this.email = email;
//     this.role = role;
//     this.photoUrl = photoUrl;
//     this.createdAt = createdAt;
//     this.updatedAt = updatedAt;
// }
// //luu user moi vao firebase store
// async save(){
//     if (!this.name || !this.email ) throw new Error(" Ten va email bat buoc")

//     const ref = await db.collection("users").add(
//         {
//             name: this.name,
//             email: this.email,
//             role: this.role,
//             photoUrl: this.photoUrl,
//             createdAt: this.createdAt,
//             updatedAt: this.updatedAt,
//             }
//     )
//     this.id = ref.id;
//     return this;
// }
// }