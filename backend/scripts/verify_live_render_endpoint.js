import process from 'node:process';

async function verifyLiveRenderEndpoint() {
  const url = 'https://sarthee-ai.onrender.com/api/v1/journey/plan';
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
  console.log('🌐 EXECUTING LIVE HTTP REQUEST TO RENDER SERVER');
  console.log('==================================================');
  console.log(`URL            : ${url}`);
  console.log('Method         : POST');
  console.log('Headers        : Content-Type: application/json');
  console.log('Request Body   :', JSON.stringify(requestBody, null, 2));

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    console.log('\n==================================================');
    console.log(`✅ LIVE RENDER RESPONSE STATUS: ${response.status} ${response.statusText}`);
    console.log('==================================================');

    const json = await response.json();
    console.log('Response JSON  :', JSON.stringify(json, null, 2));
  } catch (error) {
    console.error('❌ Request failed:', error);
  }
}

verifyLiveRenderEndpoint();
