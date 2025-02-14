FROM node:22.14.0-alpine
WORKDIR /opt
ADD . /opt/
RUN npm ci --cache /var/jenkins_home/.npm --prefer-offline
ENTRYPOINT ["npm", "run", "start"]
