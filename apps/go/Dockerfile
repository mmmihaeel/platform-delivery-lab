FROM golang:1.22-alpine AS build

WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY cmd ./cmd
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /out/go-service ./cmd/server

FROM alpine:3.20

RUN adduser -D -H appuser && apk add --no-cache ca-certificates
USER appuser
WORKDIR /app
EXPOSE 3008
COPY --from=build /out/go-service /app/go-service
ENTRYPOINT ["/app/go-service"]
