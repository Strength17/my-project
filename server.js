import express from 'express';

const app = express();

app.get('/', (req, res, next) => {
    res.send("Check '/health'");
});

app.get('/health', (req, res, next) => {
    res.send("This application is healthy");
});


app.listen(5000, () => console.log('Server is running'));