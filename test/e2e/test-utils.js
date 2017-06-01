import enigmaMixin from 'halyard.js/dist/halyard-enigma-mixin';
import WebSocket from 'ws';
import fs from 'fs';
import qixSchema from '../node_modules/enigma.js/schemas/qix/3.2/schema.json';

const getSwarmManagerIP = () => {
  const USER_DIR = `${process.env.USERPROFILE || process.env.HOME}`;
  const MANAGER_NAME = `${process.env.USERNAME || process.env.USER}-docker-manager1`;
  const MANAGER_CONFIG = `${USER_DIR}/.docker/machine/machines/${MANAGER_NAME}/config.json`;
  const config = JSON.parse(fs.readFileSync(MANAGER_CONFIG, 'utf8'));
  return config.Driver.IPAddress;
};

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
  return process.env.SWARM ? process.env.SWARMMANAGER || getSwarmManagerIP() : 'localhost';
}
