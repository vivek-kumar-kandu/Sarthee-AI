import mongoose from 'mongoose';
import { logger } from '../../config/logger.js';

/**
 * Database Connection Manager
 *
 * Connects to MongoDB via Mongoose when MONGODB_URI is provided.
 * Gracefully falls back to in-memory domain repositories if unconfigured or offline.
 */
class DatabaseManager {
  constructor() {
    this.isConnected = false;
  }

  async connect() {
    const mongoUri = process.env.MONGODB_URI;

    if (!mongoUri) {
      logger.info({ event: 'mongodb_unconfigured_inmemory_fallback', message: 'MONGODB_URI not set. Running in-memory domain repositories.' });
      return false;
    }

    try {
      await mongoose.connect(mongoUri, {
        serverSelectionTimeoutMS: 3000,
      });
      this.isConnected = true;
      logger.info({ event: 'mongodb_connected_success', uri: mongoUri.replace(/\/\/[^:]+:[^@]+@/, '//***:***@') });
      return true;
    } catch (err) {
      logger.warn({ event: 'mongodb_connection_warning_fallback', error: err.message });
      this.isConnected = false;
      return false;
    }
  }

  async disconnect() {
    if (this.isConnected) {
      await mongoose.disconnect();
      this.isConnected = false;
    }
  }
}

export const dbManager = new DatabaseManager();
