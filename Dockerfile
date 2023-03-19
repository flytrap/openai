FROM golang:1.16-alpine AS builder

LABEL stage=gobuilder

ENV GO111MODULE=on
ENV CGO_ENABLED 0
ENV GOPROXY https://goproxy.cn,direct

WORKDIR /build

COPY . .
RUN go mod tidy
RUN go mod download
RUN go build -ldflags="-s -w" -o /app/openai main.go


FROM alpine

WORKDIR /app
# 需要先本地编译，手动 GOOS=linux GOARCH=amd64 go build -o openai
COPY keyword.txt .
COPY --from=builder /app/openai /app/openai

RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata

EXPOSE "$PORT"

CMD ["./openai"]
