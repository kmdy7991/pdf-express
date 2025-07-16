const express = require('express');
const puppeteer = require('puppeteer');

const app = express();

app.use(express.json({ limit: '10mb' }));

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK', message: 'Success' });
});

app.post('/generate', async (req, res) => {
    const { html } = req.body;

    if (!html) {
        return res.status(400).send('HTML content is required');
    }

    let browser;
    try {
        // --no-sandbox 옵션은 Docker 환경에서 실행할 때 중요
        browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] });
        const page = await browser.newPage();

        await page.setContent(html, { waitUntil: 'networkidle0' });

        const pdfBuffer = await page.pdf({
            format: 'A4',
            printBackground: true,
            margin: { top: '50px', right: '50px', bottom: '50px', left: '50px' }
        });

        res.contentType('application/pdf');

        res.send(pdfBuffer);

    } catch (error) {
        console.error('PDF Generate Error:', error);
        res.status(500).send('Failed to generate PDF');
    } finally {
        if (browser) {
            await browser.close();
        }
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`listening on port ${PORT}`);
});