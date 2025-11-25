import { db } from "../config/db.js";
import { Timestamp } from "firebase-admin/firestore";

export class Project {
  constructor({
    id = null,
    name,
    priority = "Low",
    projectType , 
    sumary , 
    description = "",
    ownerId,
    members = [],
    status = "active",
    createdAt = Timestamp.now(),
    updatedAt = Timestamp.now(),
  }) {
    this.id = id;
    this.name = name;
    this.priority = priority , 
    this.projectType = projectType,
    this.sumary = sumary , 
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

    const data = {
      name: this.name,
      priority : this.priority , 
      projectType : this.projectType , 
      sumary : this.sumary ,
      description: this.description,
      ownerId: this.ownerId,
      members: this.members.length ? this.members : [this.ownerId],
      status: this.status,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };

    const ref = await db.collection("projects").add(data);
    this.id = ref.id;

    return this;
  }
}