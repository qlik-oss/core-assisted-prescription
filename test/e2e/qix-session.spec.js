import Halyard from 'halyard.js';
import enigma from 'enigma.js';
import { getEnigmaBaseConfig, getTestHost, getLoginCookie } from '../utils/test-utils';

describe('QIX Session in a swarm', () => {
  let qixGlobal;
  let sessionApp;
  let customAnalyticsCookie;

  before(async () => {
    customAnalyticsCookie = await getLoginCookie();
  });

  beforeEach(() => {
    const enigmaConfig = getEnigmaBaseConfig(customAnalyticsCookie);

    enigmaConfig.session = {
      host: getTestHost(),
      route: '/doc/session-doc',
    };

    return enigma.getService('qix', enigmaConfig).then((qix) => {
      qixGlobal = qix.global;
      return qixGlobal.getActiveDoc().then((app) => {
        sessionApp = app;
      });
    }).catch((err) => {
      console.log(`error: ${err}`);
    });
  });

  afterEach(() => {
    qixGlobal.session.on('error', () => { });
    return qixGlobal.session.close().then(() => {
      qixGlobal = null;
    });
  });

  it('get engine component version', () => qixGlobal.engineVersion().then((resp) => {
    expect(resp.qComponentVersion).to.match(/^(\d+\.)?(\d+\.)?(\*|\d+)$/);
  }));

  it('verify that a session app is opened', () => sessionApp.getAppLayout().then((layout) => {
    expect(layout.qTitle).to.match(/SessionApp_[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i); // title should be 'SessionApp_<GUID>'
  }));

  it('load data into session app using halyard', () => {
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

    return qixGlobal.setScriptAndReloadWithHalyard(sessionApp, halyard, false)
      .then(() => sessionApp.getAppLayout().then((layout) => {
        expect(layout.qHasScript).to.be.true;
        expect(layout.qHasData).to.be.true;
      }));
  });
});
