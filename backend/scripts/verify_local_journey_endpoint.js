import { createJourneyRouter } from '../src/modules/journey/presentation/routes/journey_routes.js';
import express from 'express';

async function testLocalJourneyRoute() {
  const app = express();
  app.use(express.json());
  app.use('/api/v1/journey', createJourneyRouter());

  const server = app.listen(5099, async () => {
    const url = 'http://127.0.0.1:5099/api/v1/journey/plan';
    const requestBody = {
      originName: 'Ghaziabad (Current Location)',
      originLat: 28.6715,
      originLng: 77.4121,
      destinationName: 'Connaught Place, Delhi',
      destinationLat: 28.6328,
      destinationLng: 77.2197,
      preferredMode: 'balanced',
    };

    console.log('==================================================');
    console.log('🌐 EXECUTING HTTP POST REQUEST TO BACKEND');
    console.log('==================================================');
    console.log(`URL            : ${url}`);
    console.log('Method         : POST');
    console.log('Headers        : Content-Type: application/json');
    console.log('Request Body   :', JSON.stringify(requestBody, null, 2));

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      });

      console.log('\n==================================================');
      console.log(`✅ BACKEND RESPONSE STATUS: ${response.status} ${response.statusText}`);
      console.log('==================================================');

      const json = await response.json();
      console.log('Response JSON Payload:\n', JSON.stringify(json, null, 2));
    } catch (err) {
      console.error('Error:', err);
    } finally {
      server.close();
    }
  });
}

testLocalJourneyRoute();
