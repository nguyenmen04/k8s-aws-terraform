FROM nginx:alpine
# Copy the static web files into the Nginx default html directory
COPY . /usr/share/nginx/html
# Expose port 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
