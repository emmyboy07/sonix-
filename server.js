const puppeteer = require('puppeteer-core');
const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

// Retry action function to handle retries
async function retryAction(action, retries = 3, delay = 2000) {
    let lastError;
    for (let attempt = 1; attempt <= retries; attempt++) {
        try {
            return await action();
        } catch (error) {
            console.warn(`Action failed. Attempt ${attempt}/${retries}: ${error.message}`);
            lastError = error;
            if (attempt < retries) {
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
    }
    throw lastError;
}

// Main function to search and simulate movie download
async function searchAndDownloadMovie(movieName) {
    const browser = await puppeteer.launch({
        executablePath: process.env.CHROME_PATH,  // Use the configured Chrome path
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-blink-features=AutomationControlled',
            '--disable-web-security',
            '--allow-running-insecure-content',
        ],
    });

    const page = await browser.newPage();

    try {
        await retryAction(() => page.setViewport({ width: 1280, height: 800 }));
        await retryAction(() =>
            page.setUserAgent(
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            )
        );

        console.log('Navigating to MovieBox...');
        await retryAction(() =>
            page.goto('https://moviebox.ng', { waitUntil: 'load', timeout: 60000 })
        );

        console.log('Searching for movie...');
        await retryAction(async () => {
            const searchInput = await page.waitForSelector('.pc-search-input', { timeout: 5000 });
            await searchInput.focus();
            await searchInput.type(movieName);
            await page.keyboard.press('Enter');
        });

        console.log('Waiting for search results...');
        await retryAction(() => page.waitForSelector('.pc-card', { timeout: 15000 }));

        const movieCards = await page.$$('.pc-card');
        if (movieCards.length === 0) {
            throw new Error('No search results found.');
        }

        console.log('Selecting the first search result...');
        await retryAction(async () => {
            const watchNowButton = await movieCards[0].$('.pc-card-btn');
            if (!watchNowButton) throw new Error("No 'Watch Now' button found.");
            await watchNowButton.click();
        });

        console.log('Waiting for the movie details page...');
        await retryAction(() => page.waitForSelector('.flx-ce-ce.pc-download-btn', { timeout: 30000 }));

        console.log('Clicking the download button...');
        await retryAction(async () => {
            const downloadButton = await page.$('.flx-ce-ce.pc-download-btn');
            if (!downloadButton) throw new Error('No download button found.');
            await downloadButton.click();
        });

        console.log('Selecting download quality...');
        const selectedResolution = await retryAction(async () => {
            const qualityOptions = await page.$$('.pc-quality-list .pc-itm');
            if (qualityOptions.length === 0) throw new Error('No quality options available.');
            const randomIndex = Math.floor(Math.random() * qualityOptions.length);
            const selectedOption = qualityOptions[randomIndex];
            const resolution = await selectedOption.$eval('.pc-resolution', el => el.textContent.trim());
            console.log(`Selected resolution: ${resolution}`);
            await selectedOption.click();
            return resolution;
        });

        console.log('Simulating download...');
        const fakeDownloadLink = `https://example.com/download/${movieName.replace(
            /\s+/g,
            '-'
        )}-${selectedResolution}.mp4`;

        return { downloadLink: fakeDownloadLink, resolution: selectedResolution };
    } catch (error) {
        console.error('Error:', error.message);
        throw error;
    } finally {
        if (browser && browser.isConnected()) {
            await browser.close();
        }
    }
}

// Express app setup
const app = express();
app.use(cors());
app.use(bodyParser.json());

// Serve static frontend files (optional if you have a frontend)
app.use(express.static(path.join(__dirname, 'public')));

app.post('/download', async (req, res) => {
    const { movieTitle } = req.body;
    if (!movieTitle) {
        return res.status(400).json({ error: 'Movie title is required.' });
    }

    try {
        const { downloadLink, resolution } = await searchAndDownloadMovie(movieTitle);
        res.json({ downloadLink, resolution, message: 'Download simulated successfully.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
