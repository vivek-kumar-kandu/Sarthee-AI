export class MemoryEmergencyRepository {
  constructor() {
    this.store = new Map();
  }

  async save(sosPayload) {
    if (!sosPayload || !sosPayload.sosId) {
      throw new Error('MemoryEmergencyRepository.save requires valid sosPayload with sosId.');
    }
    this.store.set(sosPayload.sosId, { ...sosPayload });
    return this.store.get(sosPayload.sosId);
  }

  async findById(sosId) {
    return this.store.get(sosId) || null;
  }

  async findByUserId(userId) {
    const results = [];
    for (const item of this.store.values()) {
      if (item.userId === userId) {
        results.push(item);
      }
    }
    return results;
  }

  async updateStatus(sosId, status) {
    const item = this.store.get(sosId);
    if (!item) return null;
    item.status = status;
    item.updatedAt = new Date().toISOString();
    this.store.set(sosId, item);
    return item;
  }

  async findRecent(limit = 10) {
    const list = Array.from(this.store.values());
    list.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    return list.slice(0, limit);
  }

  async findActive() {
    const list = [];
    for (const item of this.store.values()) {
      if (item.status === 'DISPATCHED' || item.status === 'ACKNOWLEDGED') {
        list.push(item);
      }
    }
    return list;
  }
}

export const memoryEmergencyRepository = new MemoryEmergencyRepository();
