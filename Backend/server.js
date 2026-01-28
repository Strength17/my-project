import 'dotenv/config';
import express from 'express';
import supabase from './utils/supabaseClient.js';
import { verifyJwt } from './middleware/auth.js';
import orgAccess from './middleware/orgAccess.js';


const app = express();

// Home route
app.get('/', (req, res, next) => {
    res.send("This is the home page");
});

// Test Supabase connection
app.get('/test-db', async (req, res) => {
  const { data, error } = await supabase.from('users').select('*').limit(5);

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json(data);
});

// Protected route example
app.get('/protected', verifyJwt, (req, res) => {
  res.json({
    message: 'Access granted',
    user: req.user,
  });
});


app.get(
  "/orgs/:org_id/protected",
  verifyJwt,    // verifies JWT → user_id
  orgAccess,         // verifies org membership
  (req, res) => {
    res.json({
      message: "Org access granted",
      user: req.user,
      org: req.org,
    });
  }
);




app.listen(5000, () => console.log('Server is running'));

