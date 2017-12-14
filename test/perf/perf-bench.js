const cluster = require('cluster');
const commandLineArgs = require('command-line-args');
const runner = require('./perf-runner');
const os = require('os');

const optionDefinitions = [
  {
    name: 'threads',
    alias: 't',
    type: Number,
  },
];

const args = commandLineArgs(optionDefinitions, { partial: true });

if (cluster.isMaster) {
  let numCPUs = 1;

  if (args.threads > 0) {
    numCPUs = args.threads;
  } else if (args.threads === -1) {
    numCPUs = os.cpus().length;
  }

  console.log('threads');
  console.log('Using nr of CPUs: ', numCPUs);

  for (let i = 0; i < numCPUs; i += 1) {
    cluster.fork();
  }

  cluster.on('exit', (worker) => {
    console.log(`worker ${worker.process.pid} died`);
  });
} else {
  console.log(`Worker ${cluster.worker.id} with pid ${process.pid} started`);
  runner.start(cluster.worker.id);
}
