import 'dotenv/config';
import express from 'express';
import supabase from './services/supabase.js';
import { verifyJwt } from './middleware/verify-jwt.js';


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


app.get('/protected', verifyJwt, (req, res) => {
  res.json({
    message: 'Access granted',
    user: req.user,
  });
});


console.log('SUPABASE_URL:', process.env.SUPABASE_URL);
console.log(
  'JWT secret length:',
  process.env.SUPABASE_JWT_SECRET?.length
);


app.listen(5000, () => console.log('Server is running'));

