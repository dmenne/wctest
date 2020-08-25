FROM rocker/shiny-verse:latest

LABEL maintainer="dieter.menne@menne-biomed.de"

# system libraries of general use
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libv8-dev

RUN install2.r --error --deps TRUE \
  DT \
  pairwiseCI \
  shinyAce \
  shinyjs

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /app /srv/shiny-server/

# Make the ShinyApp available at port 3838
EXPOSE 3838

HEALTHCHECK --interval=60s CMD curl --fail http://localhost:3838 || exit 1

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
