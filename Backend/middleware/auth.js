import { jwtVerify, createRemoteJWKSet } from 'jose';

const SUPABASE_PROJECT_URL = process.env.SUPABASE_URL;
// example: https://xewjiyzfwzccymjjtvaw.supabase.co

const SUPABASE_JWT_ISSUER = `${SUPABASE_PROJECT_URL}/auth/v1`;

const JWKS = createRemoteJWKSet(
  new URL(`${SUPABASE_JWT_ISSUER}/.well-known/jwks.json`)
);

export async function verifyJwt(req, res, next) {
  console.log("🔥 verifyJwt HIT:", req.method, req.originalUrl);

  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: 'Missing Authorization header' });
  }

  const [type, token] = authHeader.split(' ');

  if (type !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Invalid Authorization format' });
  }

  try {
    const { payload, protectedHeader } = await jwtVerify(token, JWKS, {
      issuer: SUPABASE_JWT_ISSUER,
      audience: 'authenticated',
    });

    console.log('Token exp (timestamp):', payload.exp, 'Current time:', Math.floor(Date.now()/1000));

    console.log('✅ JWT verified');
    console.log('alg:', protectedHeader.alg); // should be ES256
    console.log('kid:', protectedHeader.kid);

    req.user = payload;
    next();
  } catch (err) {
    console.error('❌ JWT verification failed:', err);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}
