FROM node:10

# Set the working directory inside the container
WORKDIR /app

# Download the index.js file
RUN git clone https://github.com/rearc/quest.git /app/
RUN cp /app/src/000.js /app/index.js

# Initialize npm and install express
RUN npm init -y && npm install express

# Run the app
CMD ["node", "index.js"]