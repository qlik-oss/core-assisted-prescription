import enigmaMixin from 'halyard.js/dist/halyard-enigma-mixin';
import WebSocket from 'ws';
import qixSchema from '../node_modules/enigma.js/schemas/qix/3.2/schema.json';

export function getEnigmaBaseConfig() {
  return {
    schema: qixSchema,
    mixins: enigmaMixin,
    createSocket: url => new WebSocket(url),
    listeners: {
      'notification:OnConnected': (params) => {
        console.log('OnConnected', params);
      },
    },
    handleLog: logRow => console.log(logRow),
  };
}

export function getTestHost() {
  return process.env.SWARM ? process.env.SWARMMANAGER || `${process.env.USERNAME || process.env.USER}-docker-manager1` : 'localhost';
}
