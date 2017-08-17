FROM alpine:latest
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN apk add --no-cache curl jq

COPY get_dtr_logs.sh /get_dtr_logs.sh

CMD ["/get_dtr_logs.sh"]
