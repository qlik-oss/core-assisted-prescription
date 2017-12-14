const Halyard = require('halyard.js');
const enigma = require('enigma.js');
const { getEnigmaBaseConfig, getLoginCookie } = require('../utils/test-utils');

describe('QIX Session in a swarm', () => {
  let qix;
  let session;
  let customAnalyticsCookie;

  before(async () => {
    customAnalyticsCookie = await getLoginCookie();
  });

  beforeEach(async () => {
    const enigmaConfig = getEnigmaBaseConfig(customAnalyticsCookie, '/doc/session-doc');

    session = enigma.create(enigmaConfig);
    qix = await session.open();
  });

  afterEach(async () => {
    await session.close();
  });

  it('get engine component version', async () => {
    const response = await qix.engineVersion();
    expect(response.qComponentVersion).to.match(/^(\d+\.)?(\d+\.)?(\*|\d+)$/);
  });

  it('verify that a session app is opened', async () => {
    const app = await qix.getActiveDoc();
    const layout = await app.getAppLayout();
    expect(layout.qTitle).to.match(/SessionApp_[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i); // title should be 'SessionApp_<GUID>'
  });

  it('load data into session app using halyard', async () => {
    const halyard = new Halyard();
    const filePathMovie = '/data/movies.csv';
    const tableMovie = new Halyard.Table(filePathMovie, {
      name: 'Movies',
      fields: [
        { src: 'Movie', name: 'Movie' },
        { src: 'Year', name: 'Year' },
        { src: 'Adjusted Costs', name: 'Adjusted Costs' },
        { src: 'Description', name: 'Description' },
        { src: 'Image', name: 'Image' }],
      delimiter: ',',
    });
    halyard.addTable(tableMovie);

    const app = await qix.getActiveDoc();
    await qix.setScriptAndReloadWithHalyard(app, halyard, false);
    const layout = await app.getAppLayout();

    expect(layout.qHasScript).to.be.true;
    expect(layout.qHasData).to.be.true;
  });
});
