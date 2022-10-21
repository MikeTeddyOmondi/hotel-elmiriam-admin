# #######
# Stage 1
# Build docker | React App
FROM node:16.13.2-alpine as build

# set working directory
RUN mkdir /usr/app

# Copy all files from current directory to docker container image
COPY . /usr/app/

WORKDIR /usr/app

# Install & cache app dependencies
USER root
RUN npm install --silent
RUN npm install react-scripts@3.0.1 -g --silent

# Add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# Build static assets
USER node
RUN npm run build

# #######
# Stage 2
# Copy the react app build above to NGINX container image
FROM nginx:1.22.1-alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy nginx config file
COPY nginx/nginx.conf /etc/nginx/conf.d

# Copy static assets from builder stage
COPY --from=build /user/app/build .

# Start NGINX docker container w/ global directives & daemon off
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
