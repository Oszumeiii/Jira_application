import { db } from "../config/db.js";

export class User {
    constructor({ id = null, name, email, role = "Guest", photoUrl = "", createdAt = Date.now(), updatedAt = Date.now() }) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.role = role;
    this.photoUrl = photoUrl;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
}
//luu user moi vao firebase store
async save(){
    if (!this.name || !this.email ) throw new Error(" Ten va email bat buoc")

    const ref = await db.collection("users").add(
        {
            name: this.name,
            email: this.email,
            role: this.role,
            photoUrl: this.photoUrl,
            createdAt: this.createdAt,
            updatedAt: this.updatedAt,
            }
    )
    this.id = ref.id;
    return this;
}
}