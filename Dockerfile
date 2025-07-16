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
    wget \
    unzip \
    ca-certificates \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    libxss1 \
    && mkdir -p /usr/share/fonts/truetype/suit \
    && wget -O /tmp/suit.zip https://github.com/sun-typeface/SUIT/releases/download/v2.0.5/SUIT-ttf.zip \
    && unzip -j -d /usr/share/fonts/truetype/suit /tmp/suit.zip "*.ttf" \
    && rm /tmp/suit.zip \
    && mkdir -p /usr/share/fonts/truetype/pretendard \
    && wget -O /tmp/pretendard.zip https://github.com/orioncactus/pretendard/releases/download/v1.3.9/Pretendard-1.3.9.zip \
    && unzip -j -d /usr/share/fonts/truetype/pretendard /tmp/pretendard.zip "public/static/alternative/*.ttf" \
    && rm /tmp/pretendard.zip \
    && fc-cache -f -v \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PUPPETEER에서 해당 그룹을 필요로 하는 케이스 존재하여 추가. (audio, video)
RUN groupadd -r pdf && useradd -r -g pdf -G audio,video pdf \
    && mkdir -p /home/pdf/Downloads \
    && chown -R pdf:pdf /home/pdf


WORKDIR /home/pdf

COPY --from=builder --chown=pdf:pdf /src/app ./

USER pdf

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

EXPOSE 3000

# --no-sandbox는 컨테이너 환경에서 필수
CMD [ "node", "index.js", "--no-sandbox" ]
