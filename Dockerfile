# Use the official lightweight Perl image
FROM perl:slim-bullseye

# Set the non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-perl2 \
        libapache2-request-perl \
        libapache2-authcookie-perl \
        cpanminus \
        git \
        git-svn \
        wget \
        unzip \
        build-essential \
        && rm -rf /var/lib/apt/lists/*

RUN cpanm install CGI::Carp

# Enable Apache modules
RUN a2enmod perl
RUN a2enmod rewrite

# Create the directory for YaBB
RUN mkdir -p /var/www/html/yabb
RUN mkdir -p /var/www/html/yabb/data

# Clone the YaBB repository using git svn
RUN git svn clone https://svn.code.sf.net/p/yabb/svn/branches/2.6.12 -r2072 /var/www/html/yabb

# Update YaBB configuration to point to the new data directory
#RUN sed -i 's|^\(\$boarddir\s*=\s*\).*$|\1"/var/www/html/yabb/data/Boards";|' /var/www/html/yabb/Paths.pl && \
#    sed -i 's|^\(\$boardsdir\s*=\s*\).*$|\1"/var/www/html/yabb/data/Boards";|' /var/www/html/yabb/Paths.pl && \
#    sed -i 's|^\(\$datadir\s*=\s*\).*$|\1"/var/www/html/yabb/data/Messages";|' /var/www/html/yabb/Paths.pl && \
#    sed -i 's|^\(\$memberdir\s*=\s*\).*$|\1"/var/www/html/yabb/data/Members";|' /var/www/html/yabb/Paths.pl && \
#    sed -i 's|^\(\$vardir\s*=\s*\).*$|\1"/var/www/html/yabb/data/Variables";|' /var/www/html/yabb/Paths.pl && \
#    sed -i 's|^\(\$attachdir\s*=\s*\).*$|\1"/var/www/html/yabb/data/Attachments";|' /var/www/html/yabb/Paths.pl


# Set the appropriate permissions
RUN chown -R www-data:www-data /var/www/html/yabb && \
    chmod -R 755 /var/www/html/yabb &&\
    chmod -R 777 /var/www/html/yabb/data


# Copy the Apache configuration file
COPY yabb.conf /etc/apache2/sites-available/yabb.conf

# Enable the YaBB site and disable the default site
RUN a2ensite yabb.conf
RUN a2dissite 000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
