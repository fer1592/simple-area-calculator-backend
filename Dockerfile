FROM node:16-alpine
RUN apk update && apk add bash
WORKDIR /simple-area-calculator-project

COPY package*.json ./

RUN npm install
COPY . .
EXPOSE 80

CMD ["node", "server.js"]