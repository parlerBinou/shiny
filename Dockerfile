# GitHub: https://github.com/rocker-org/shiny
FROM rocker/shiny-verse:4.0.3

RUN apt-get update && apt-get install -y --no-install-recommends \
      default-jdk \
      r-cran-rjava \
      libgdal-dev \
      libproj-dev \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      libudunits2-dev \
      libgeos-dev \
    && \
    rm -rf /var/lib/apt/lists/*

# Install our custom packages
COPY ./PACKAGES /opt/PACKAGES
RUN cat /opt/PACKAGES | xargs install2.r -s

# Install latest httpuv packages for static assets 400 issue
RUN installGithub.r rstudio/httpuv

# Copy configuration files into the container image
COPY conf/shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Copy our custom index file to override the default one
COPY mountpoints/apps/index.html /srv/shiny-server/index.html

# Make the ShinyApp available at port 3838
EXPOSE 3838

# Apply a temp fix to /etc/ssl/openssl.cnf to address
# https://github.com/StatCan/shiny/issues/14
COPY openssl_patch/openssl_prefix openssl_patch/openssl_suffix /tmp/
RUN cat /tmp/openssl_prefix /etc/ssl/openssl.cnf /tmp/openssl_suffix > /tmp/openssl.cnf \
    && mv /tmp/openssl.cnf /etc/ssl/openssl.cnf \
    && rm /tmp/openssl_prefix /tmp/openssl_suffix

# Copy further configuration files into the Docker image
COPY scripts/shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +xr /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
