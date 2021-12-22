# An Apache web server image.
FROM httpd:2.4
# To serve the contents of the zip folder.
COPY ./zip/ /usr/local/apache2/htdocs/