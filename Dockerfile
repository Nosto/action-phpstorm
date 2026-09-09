FROM supercid/jbstorm:latest
RUN apt-get update -y -o Acquire::Check-Valid-Until=false
RUN apt-get install -y xsltproc
COPY *.xslt /
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
