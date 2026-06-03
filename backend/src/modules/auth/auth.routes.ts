import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../../config';
import { AuthService } from './auth.service';

export const authRouter = Router();
const service = new AuthService();

// CORS preflight handler for all auth routes
authRouter.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.sendStatus(204);
});

// Middleware to add CORS headers to all responses
authRouter.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }
  next();
});

// Request logging middleware
authRouter.use((req, res, next) => {
  console.log(`[Auth] ${req.method} ${req.path} - Origin: ${req.headers.origin}`);
  next();
});

// Register endpoint
authRouter.post('/register', async (req, res, next) => {
    try {
        console.log(`[Auth] Registration attempt for email: ${req.body.email}`);
        const result = await service.register(req.body);
        
        res.status(201).json({ 
            success: true, 
            data: result,
            message: 'User registered successfully'
        });
    } catch (err) {
        console.error('[Auth] Registration error:', err);
        next(err);
    }
});

// Login endpoint
authRouter.post('/login', async (req, res, next) => {
    try {
        const { email, password } = req.body;
        
        // Validation
        if (!email || !password) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email and password are required' 
            });
        }
        
        console.log(`[Auth] Login attempt for email: ${email}`);
        const result = await service.login(req.body);
        
        res.status(200).json({ 
            success: true, 
            data: result,
            message: 'Login successful'
        });
    } catch (err) {
        console.error('[Auth] Login error:', err);
        next(err);
    }
});

// Refresh token endpoint
authRouter.post('/refresh', async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        
        if (!refreshToken) {
            return res.status(400).json({ 
                success: false, 
                error: 'Refresh token is required' 
            });
        }
        
        console.log('[Auth] Token refresh attempt');
        const result = await service.refreshToken(req.body);
        
        res.status(200).json({ 
            success: true, 
            data: result,
            message: 'Token refreshed successfully'
        });
    } catch (err) {
        console.error('[Auth] Refresh token error:', err);
        next(err);
    }
});

// Update profile endpoint
authRouter.patch('/profile', async (req, res, next) => {
    try {
        const userId = getUserId(req.headers.authorization);
        
        if (!userId) {
            return res.status(401).json({ 
                success: false, 
                error: 'Authentication required. Please provide a valid token.' 
            });
        }
        
        console.log(`[Auth] Profile update for user: ${userId}`);
        const user = await service.updateProfile(userId, req.body);
        
        res.status(200).json({ 
            success: true, 
            data: user,
            message: 'Profile updated successfully'
        });
    } catch (err) {
        console.error('[Auth] Profile update error:', err);
        next(err);
    }
});

// Get current user endpoint
authRouter.get('/me', async (req, res, next) => {
    try {
        const userId = getUserId(req.headers.authorization);
        
        if (!userId) {
            return res.status(401).json({ 
                success: false, 
                error: 'Authentication required' 
            });
        }
        
        console.log(`[Auth] Fetching user data for: ${userId}`);
        const user = await service.getUserById(userId);
        
        res.status(200).json({ 
            success: true, 
            data: user 
        });
    } catch (err) {
        console.error('[Auth] Get user error:', err);
        next(err);
    }
});

// Logout endpoint
authRouter.post('/logout', async (req, res, next) => {
    try {
        const userId = getUserId(req.headers.authorization);
        
        if (userId) {
            console.log(`[Auth] Logout for user: ${userId}`);
            await service.logout(userId);
        }
        
        res.status(200).json({ 
            success: true, 
            message: 'Logged out successfully' 
        });
    } catch (err) {
        console.error('[Auth] Logout error:', err);
        next(err);
    }
});

// Forgot password endpoint
authRouter.post('/forgot-password', async (req, res, next) => {
    try {
        const { email } = req.body;
        
        if (!email) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email is required' 
            });
        }
        
        console.log(`[Auth] Password reset requested for: ${email}`);
        await service.forgotPassword(email);
        
        res.status(200).json({ 
            success: true, 
            message: 'If an account exists with this email, you will receive password reset instructions.' 
        });
    } catch (err) {
        console.error('[Auth] Forgot password error:', err);
        next(err);
    }
});

// Reset password endpoint
authRouter.post('/reset-password', async (req, res, next) => {
    try {
        const { token, newPassword } = req.body;
        
        if (!token || !newPassword) {
            return res.status(400).json({ 
                success: false, 
                error: 'Token and new password are required' 
            });
        }
        
        if (newPassword.length < 6) {
            return res.status(400).json({ 
                success: false, 
                error: 'Password must be at least 6 characters long' 
            });
        }
        
        console.log('[Auth] Password reset attempt');
        await service.resetPassword(token, newPassword);
        
        res.status(200).json({ 
            success: true, 
            message: 'Password reset successfully' 
        });
    } catch (err) {
        console.error('[Auth] Reset password error:', err);
        next(err);
    }
});

// Verify email endpoint
authRouter.post('/verify-email', async (req, res, next) => {
    try {
        const { token } = req.body;
        
        if (!token) {
            return res.status(400).json({ 
                success: false, 
                error: 'Verification token is required' 
            });
        }
        
        console.log('[Auth] Email verification attempt');
        await service.verifyEmail(token);
        
        res.status(200).json({ 
            success: true, 
            message: 'Email verified successfully' 
        });
    } catch (err) {
        console.error('[Auth] Email verification error:', err);
        next(err);
    }
});

// Helper function to extract user ID from JWT token
function getUserId(authHeader?: string) {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return undefined;
    }

    try {
        const token = authHeader.slice(7); // Remove 'Bearer ' prefix
        const payload = jwt.verify(token, config.jwtSecret) as { userId: string; sub?: string };
        
        // Support both 'userId' and 'sub' claims
        return payload.userId || payload.sub;
    } catch (error) {
        if (error instanceof jwt.TokenExpiredError) {
            console.error('[Auth] Token expired');
        } else if (error instanceof jwt.JsonWebTokenError) {
            console.error('[Auth] Invalid token');
        } else {
            console.error('[Auth] Token verification error:', error);
        }
        return undefined;
    }
}
