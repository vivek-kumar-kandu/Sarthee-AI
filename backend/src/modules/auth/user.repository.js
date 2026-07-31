import { User } from "./user.model.js";

/**
 * ============================================================================
 * SARTHEE AI — USER REPOSITORY
 * ============================================================================
 *
 * Database access layer for User documents.
 *
 * Responsibilities:
 *
 * • MongoDB queries only
 * • No business logic
 * • No HTTP concerns
 */

export class UserRepository {
  constructor({ model = User } = {}) {
    if (!model) {
      throw new TypeError("UserRepository requires a Mongoose model.");
    }

    this._model = model;
  }

  async findByFirebaseUid(firebaseUid) {
    return this._model.findOne({ firebaseUid }).lean().exec();
  }

  async findByEmail(email) {
    return this._model
      .findOne({ email: normalizeEmail(email) })
      .lean()
      .exec();
  }

  async findById(id) {
    return this._model.findById(id).lean().exec();
  }

  async createUser(data) {
    const document = await this._model.create(data);

    return document.toObject();
  }

  async updateUser(id, data) {
    return this._model
      .findByIdAndUpdate(id, { $set: data }, { new: true, runValidators: true })
      .lean()
      .exec();
  }

  async deleteUser(id) {
    return this._model.findByIdAndDelete(id).lean().exec();
  }
}

function normalizeEmail(email) {
  if (typeof email !== "string") {
    return email;
  }

  return email.trim().toLowerCase();
}

export function createUserRepository(options) {
  return new UserRepository(options);
}

export const userRepository = new UserRepository();

export default userRepository;

