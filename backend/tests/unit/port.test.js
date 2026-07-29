import test from "node:test";
import assert from "node:assert/strict";
import net from "node:net";

import { findAvailablePort } from "../../src/utils/port.js";

function createServer(port) {
  return new Promise((resolve, reject) => {
    const server = net.createServer();

    server.once("error", reject);
    server.listen(port, "127.0.0.1", () => resolve(server));
  });
}

test("findAvailablePort skips an occupied port and returns the next free one", async () => {
  const occupiedServer = await createServer(0);
  const occupiedPort = occupiedServer.address().port;

  try {
    const nextPort = await findAvailablePort(occupiedPort, "127.0.0.1", 3);

    assert.notEqual(nextPort, occupiedPort);
    assert.ok(nextPort >= occupiedPort);
  } finally {
    await new Promise((resolve, reject) => {
      occupiedServer.close((error) => {
        if (error) {
          reject(error);
          return;
        }

        resolve();
      });
    });
  }
});
