# An Apache web server image.
FROM httpd:2.4
# Having servers.txt as the default document.
COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf
# We will mount the rule files when the container is started.