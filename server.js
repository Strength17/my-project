import 'dotenv/config';
import express from 'express';
import supabase from './lib/supabase.js';

const app = express();

app.get('/', (req, res, next) => {
    res.send("Check '/health'");
});

app.get('/health', (req, res, next) => {
    res.send("This application is healthy");
});

app.get('/test-db', async (req, res) => {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .limit(5);

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json(data);
});

console.log('SUPABASE_URL:', process.env.SUPABASE_URL);

app.listen(5000, () => console.log('Server is running'));

