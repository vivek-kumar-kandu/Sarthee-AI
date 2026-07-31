async function verifyNominatimSearch() {
  const query = 'India Gate, Delhi';
  const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&countrycodes=in&limit=3`;

  console.log('==================================================');
  console.log('🌐 EXECUTING LIVE OPENSTREETMAP NOMINATIM SEARCH TEST');
  console.log('==================================================');
  console.log(`Query          : "${query}"`);
  console.log(`URL            : ${url}`);

  const startTime = Date.now();
  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'SartheeAI/1.0 (contact@sarthee.ai)',
      },
    });
    const elapsedMs = Date.now() - startTime;

    if (response.ok) {
      const results = await response.json();
      console.log('\n==================================================');
      console.log(`✅ LIVE NOMINATIM RESULTS RETURNED (${elapsedMs} ms)`);
      console.log('==================================================');

      results.forEach((item, index) => {
        console.log(`\nResult #${index + 1}:`);
        console.log(`Display Name   : ${item.display_name}`);
        console.log(`Resolved Lat   : ${item.lat}`);
        console.log(`Resolved Lon   : ${item.lon}`);
      });
    }
  } catch (error) {
    console.error('Error:', error);
  }
}

verifyNominatimSearch();
