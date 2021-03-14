FROM node:latest

MAINTAINER Filipe Farinha <filipe@ktorn.com>

# Cache buster if desired
ARG VERSION="N/A"

# Deps
#RUN apt update && apt install -y autotools-dev automake
RUN npm install -g node-gyp

# Add ssb-config so tuning can be performed if desired
WORKDIR /ssb-config
RUN git clone https://github.com/ssbc/ssb-config.git . \
	&& npm build \
	&& npm install \
	&& npm install -g

# Install ssb-server
WORKDIR /ssb-server
RUN git clone https://github.com/ssbc/ssb-server.git . \
	&& git checkout $(git tag | sort -r | head -n1) \
	&& npm install pull-stream \
	&& npm build \
	&& npm install \
	&& npm install -g

# Set reasonable work dir
WORKDIR /root/.ssb/

# Setup run script
ADD scripts/run-sbot.sh /run-sbot.sh
RUN chmod +x /run-sbot.sh

# Useful info for admins to know how to run the container
EXPOSE 8008
VOLUME /root/.ssb/

ENV HOSTNAME 127.0.0.1

# Run the server
ENTRYPOINT [ "/run-sbot.sh" ]
# Tunable parms (default to add hostname)
CMD [ "--host", "${HOSTNAME}"
