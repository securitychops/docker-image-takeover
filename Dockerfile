# dont use still alpha
FROM alpine:3.11.3 as builder

RUN apk update
RUN apk add --no-cache git

WORKDIR /build

RUN git clone https://github.com/m4ll0k/takeover

WORKDIR /build/takeover

COPY go-go-gadget.sh .
COPY process.py .

FROM alpine:3.11.3

COPY --from=builder /build/takeover /tmp

RUN apk update && \
    apk add --no-cache python3 && \
    pip3 install --upgrade pip && \
    pip3 install --upgrade awscli && \
    pip3 install --upgrade boto3 && \
    addgroup -S bender && \
    adduser -S -G bender bender && \
    chown -R bender:bender /tmp

WORKDIR /tmp

RUN python3 setup.py build && \
    python3 setup.py install

USER bender

ENTRYPOINT [ "sh" ]

CMD [ "go-go-gadget.sh" ]
