FROM node:14-alpine

WORKDIR /app
COPY package.json /app/package.json
RUN npm install --no-optional --only=production

COPY . /app
ENTRYPOINT ["node"]
CMD ["index.js"]
