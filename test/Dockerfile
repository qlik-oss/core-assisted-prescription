FROM node:7
ARG TEST_HOST
ENV SWARMMANAGER $TEST_HOST

# Create test directory
RUN mkdir -p /usr/src/test
WORKDIR /usr/src/test

# Bundle test folder
COPY . /usr/src/test

# Execute tests
CMD [ "npm", "run", "test:e2e:swarm" ]
