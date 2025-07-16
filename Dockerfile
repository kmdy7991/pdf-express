FROM node:20-slim AS builder

WORKDIR /src/app

COPY package*.json ./

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN npm ci

COPY . .

FROM node:20-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    chromium \
    fonts-noto-cjk \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    libxss1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PUPPETEER에서 해당 그룹을 필요로 하는 케이스 존재하여 추가. (audio, video)
RUN groupadd -r pdf && useradd -r -g pdf -G audio,video pdf \
    && mkdir -p /home/pdf/Downloads \
    && chown -R pdf:pdf /home/pdf


WORKDIR /home/pdf

COPY --from=builder /src/app ./
COPY --chown=pdf:pdf . .

USER pdf

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

EXPOSE 3000

# --no-sandbox는 컨테이너 환경에서 필수
CMD [ "node", "server.js", "--no-sandbox" ]
