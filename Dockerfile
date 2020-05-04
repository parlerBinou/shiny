# GitHub: https://github.com/rocker-org/shiny
FROM rocker/shiny-verse:3.6.2

RUN sudo apt-get install -y libgdal-dev libproj-dev

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
