import { db } from "../config/db.js";

export class Project {
  constructor({
    id = null,
    name,
    description = "",
    ownerId,
    members = [],
    status = "active",
    createdAt = Date.now(),
    updatedAt = Date.now(),
  }) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.ownerId = ownerId;
    this.members = members;
    this.status = status;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  async save() {
    if (!this.name || !this.ownerId)
      throw new Error("Tên và ownerId là bắt buộc");

    const ref = await db.collection("projects").add({
      name: this.name,
      description: this.description,
      ownerId: this.ownerId,
      members: this.members,
      status: this.status,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    });

    this.id = ref.id;
    return this;
  }


}
