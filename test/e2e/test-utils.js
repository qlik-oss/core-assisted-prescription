import WebSocket from 'ws';
import qixSchema from '../node_modules/enigma.js/schemas/qix/3.2/schema.json';
import enigmaMixin from 'halyard.js/dist/halyard-enigma-mixin';

export function getEnigmaBaseConfig() {
  return {
    schema: qixSchema,
    mixins: enigmaMixin,
    identity: generateGUID(),
    createSocket: url => new WebSocket(url),
    listeners: {
      'notification:OnConnected': (params) => {
        console.log('OnConnected', params);
      },
    },
    handleLog: logRow => console.log(logRow),
  };
}

export function getSwarmHost() {
  return process.env.SWARMMANAGER || (process.env.USERNAME || process.env.USER) + '-docker-manager1'
}

let generateGUID = () => 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
  const r = Math.random() * 16 | 0;
  const v = c === 'x' ? r : ((r & 0x3) | 0x8);
  return v.toString(16);
});
