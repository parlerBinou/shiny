# GitHub: https://github.com/rocker-org/shiny
FROM rocker/shiny-verse:3.6.2

RUN apt-get update && apt-get install -y \
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

# Make the ShinyApp available at port 3838
EXPOSE 3838

# Copy further configuration files into the Docker image
COPY scripts/shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +xr /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
