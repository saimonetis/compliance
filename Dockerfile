# Use nginx alpine as base image for smaller size
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy all HTML files to nginx html directory
COPY *.html /usr/share/nginx/html/

# Create nginx configuration for proper routing
COPY openshift/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 8080 (OpenShift compatible)
EXPOSE 8080

# Run nginx as non-root user for OpenShift compatibility
RUN addgroup -g 1001 -S nginx-group && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx-group -g nginx-group nginx-user && \
    chown -R nginx-user:nginx-group /usr/share/nginx/html && \
    chown -R nginx-user:nginx-group /var/cache/nginx && \
    chown -R nginx-user:nginx-group /etc/nginx && \
    chmod -R 755 /usr/share/nginx/html && \
    touch /var/run/nginx.pid && \
    chown nginx-user:nginx-group /var/run/nginx.pid

USER 1001

CMD ["nginx", "-g", "daemon off;"] 