const enigma = require('enigma.js');
const { getEnigmaBaseConfig, getLoginCookie } = require('../utils/test-utils');

describe('QIX open doc in a swarm', () => {
  let qix;
  let session;
  let customAnalyticsCookie;

  before(async () => {
    customAnalyticsCookie = await getLoginCookie();
  });

  beforeEach(async () => {
    const enigmaConfig = getEnigmaBaseConfig(customAnalyticsCookie, '/doc/doc/drugcases.qvf');

    session = enigma.create(enigmaConfig);
    qix = await session.open();
  });

  afterEach(async () => {
    await session.close();
  });

  it('and verify that the intended doc is opened', async () => {
    const app = await qix.getActiveDoc();
    const layout = await app.getAppLayout();
    expect(layout.qFileName).to.equal('/doc/drugcases.qvf');
  });
});
