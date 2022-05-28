# #######
# Stage 1
# Build docker | React App
FROM node:16.13.2-alpine as build-stage

# set working directory
RUN mkdir /usr/app

# Copy all files from current directory to docker container image
COPY . /usr/app

WORKDIR /usr/app

# Install & cache app dependencies
RUN yarn

# Add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# Build static assets
RUN npm run build

# #######
# Stage 2
# Copy the react app build above to NGINX container image
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy static assets from builder stage
COPY --from=build-stage /user/app/build .

# Start NGINX docker container w/ global directives & daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]
