import jwt from 'jsonwebtoken';
import { logger } from '../../config/logger.js';

const JWT_SECRET = process.env.JWT_SECRET || 'sarthee_ai_production_secret_key_2026';
const REFRESH_SECRET = process.env.REFRESH_SECRET || 'sarthee_ai_refresh_secret_key_2026';

/** Token Revocation Blacklist */
const revokedTokenBlacklist = new Set();

/**
 * Generates JWT Access & Refresh token pair for an authenticated user
 */
export const generateTokenPair = (user) => {
  const payload = {
    userId: user.id || user.userId || 'user_guest',
    email: user.email || 'guest@sarthee.ai',
    role: user.role || 'user',
  };

  const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: '2h' });
  const refreshToken = jwt.sign(payload, REFRESH_SECRET, { expiresIn: '7d' });

  return { accessToken, refreshToken, expiresInSeconds: 7200 };
};

/** Revokes a JWT token (adds to blacklist) */
export const revokeToken = (token) => {
  if (token) revokedTokenBlacklist.add(token);
};

/**
 * Authentication Middleware: Verifies Bearer JWT Access Token
 */
export const authenticateJwt = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // Guest fallback for open endpoints
    req.user = { userId: 'guest_user', role: 'user', isGuest: true };
    return next();
  }

  const token = authHeader.split(' ')[1];

  if (revokedTokenBlacklist.has(token)) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Token has been revoked/blacklisted.' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    logger.warn({ event: 'auth_jwt_verification_failed', error: err.message });
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Invalid or expired access token.' });
  }
};

/**
 * Role-Based Access Control (RBAC) Middleware
 * @param {...string} allowedRoles Roles allowed to access route (e.g. 'admin')
 */
export const requireRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      logger.warn({ event: 'auth_forbidden_access', requiredRoles: allowedRoles, userRole: req.user?.role });
      return res.status(403).json({
        error: 'FORBIDDEN',
        message: `Forbidden. Requires one of the following roles: ${allowedRoles.join(', ')}`,
      });
    }
    next();
  };
};
