FROM golang:1.19-alpine as builder

# Setup
RUN mkdir /app
WORKDIR /app

# Copy go dep definitions first for better caching
COPY go.mod go.sum /app/
RUN go get ./...

# Copy & build
ADD . /app/
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /traefik-forward-auth .

# Copy into scratch container
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /traefik-forward-auth ./
ENTRYPOINT ["./traefik-forward-auth"]
