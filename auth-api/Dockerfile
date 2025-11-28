FROM golang:1.23-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o auth-api .

FROM alpine:latest
WORKDIR /app
COPY --from=build /app/auth-api .
EXPOSE 8081
CMD ["./auth-api"]