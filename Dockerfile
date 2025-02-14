FROM node:22.14.0
WORKDIR /opt
ADD . /opt/
RUN npm install
ENTRYPOINT ["npm", "run", "start"]
