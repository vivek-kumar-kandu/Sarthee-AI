import net from "node:net";

export async function findAvailablePort(
  preferredPort,
  host = "0.0.0.0",
  attempts = 10,
) {
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const candidatePort = preferredPort + attempt;

    const isAvailable = await isPortAvailable(candidatePort, host);
    if (isAvailable) {
      return candidatePort;
    }
  }

  throw new Error(
    `Unable to find an available port after ${attempts} attempts starting from ${preferredPort}`,
  );
}

function isPortAvailable(port, host) {
  return new Promise((resolve) => {
    const server = net.createServer();

    server.once("error", () => resolve(false));
    server.once("listening", () => {
      server.close(() => resolve(true));
    });

    server.listen(port, host);
  });
}
