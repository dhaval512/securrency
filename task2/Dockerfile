FROM golang:alpine as builder

ENV DBPORT=5432
ENV DBHOST=172.17.0.2
ENV DBUSER=postgres
ENV DBPASS=TestSecret
ENV DBNAME=peopledatabase
RUN apk update && apk add --no-cache git

# Set current working directory
WORKDIR /app

COPY . .
RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./bin/main .

# Start a new stage from scratch
FROM scratch

COPY --from=builder /app/bin/main .

# Run executable
CMD ["./main"]
