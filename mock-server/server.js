const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3000;

// Secret key for JWT (in production, use environment variable)
const JWT_SECRET = 'your-secret-key-change-in-production';
const JWT_ACCESS_TOKEN_EXPIRY = '24h'; // 24 hours
const JWT_REFRESH_TOKEN_EXPIRY = '30d'; // 30 days

// Enable CORS for Flutter app
app.use(cors());
app.use(express.json());

// In-memory user storage (replace with database in production)
const users = [];
const refreshTokens = [];

// Helper function to generate JWT tokens
function generateTokens(user) {
  const accessToken = jwt.sign(
    {
      user_id: user.id,
      email: user.email,
    },
    JWT_SECRET,
    { expiresIn: JWT_ACCESS_TOKEN_EXPIRY }
  );

  const refreshToken = jwt.sign(
    {
      user_id: user.id,
      email: user.email,
      token_type: 'refresh',
    },
    JWT_SECRET,
    { expiresIn: JWT_REFRESH_TOKEN_EXPIRY }
  );

  return { accessToken, refreshToken };
}

// Helper function to verify JWT token
function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
}

// Authentication endpoints

// POST /api/auth/register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Email and password are required',
        },
      });
    }

    // Check if user already exists
    const existingUser = users.find((u) => u.email === email);
    if (existingUser) {
      return res.status(400).json({
        error: {
          code: 'USER_EXISTS',
          message: 'User with this email already exists',
        },
      });
    }

    // Validate password requirements
    if (password.length < 8) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Password must be at least 8 characters',
        },
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const user = {
      id: uuidv4(),
      email,
      name: name || null,
      passwordHash,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    users.push(user);

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);

    // Store refresh token
    refreshTokens.push(refreshToken);

    // Return response
    res.status(201).json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Registration failed',
      },
    });
  }
});

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Email and password are required',
        },
      });
    }

    // Find user
    const user = users.find((u) => u.email === email);
    if (!user) {
      return res.status(401).json({
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.passwordHash);
    if (!isValidPassword) {
      return res.status(401).json({
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      });
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);

    // Store refresh token
    refreshTokens.push(refreshToken);

    // Return response
    res.status(200).json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Login failed',
      },
    });
  }
});

// POST /api/auth/refresh
app.post('/api/auth/refresh', (req, res) => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Refresh token is required',
        },
      });
    }

    // Verify refresh token
    const decoded = verifyToken(refresh_token);
    if (!decoded || decoded.token_type !== 'refresh') {
      return res.status(401).json({
        error: {
          code: 'INVALID_TOKEN',
          message: 'Invalid or expired refresh token',
        },
      });
    }

    // Check if refresh token is in our list
    if (!refreshTokens.includes(refresh_token)) {
      return res.status(401).json({
        error: {
          code: 'INVALID_TOKEN',
          message: 'Refresh token not found',
        },
      });
    }

    // Find user
    const user = users.find((u) => u.id === decoded.user_id);
    if (!user) {
      return res.status(401).json({
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    // Generate new tokens
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);

    // Remove old refresh token and add new one
    const index = refreshTokens.indexOf(refresh_token);
    if (index > -1) {
      refreshTokens.splice(index, 1);
    }
    refreshTokens.push(newRefreshToken);

    // Return response
    res.status(200).json({
      access_token: accessToken,
      refresh_token: newRefreshToken,
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Token refresh failed',
      },
    });
  }
});

// POST /api/auth/logout
app.post('/api/auth/logout', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      // In a real implementation, you might want to blacklist the token
      // For mock server, we just return success
    }

    res.status(200).json({
      message: 'Logged out successfully',
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Logout failed',
      },
    });
  }
});

// GET /api/user/profile
app.get('/api/user/profile', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    if (!decoded) {
      return res.status(401).json({
        error: {
          code: 'INVALID_TOKEN',
          message: 'Invalid or expired token',
        },
      });
    }

    // Find user
    const user = users.find((u) => u.id === decoded.user_id);
    if (!user) {
      return res.status(404).json({
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    res.status(200).json({
      id: user.id,
      email: user.email,
      name: user.name,
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to get profile',
      },
    });
  }
});

// PUT /api/user/profile
app.put('/api/user/profile', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    if (!decoded) {
      return res.status(401).json({
        error: {
          code: 'INVALID_TOKEN',
          message: 'Invalid or expired token',
        },
      });
    }

    // Find user
    const user = users.find((u) => u.id === decoded.user_id);
    if (!user) {
      return res.status(404).json({
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    // Update user
    const { email, name } = req.body;
    if (email) user.email = email;
    if (name !== undefined) user.name = name;
    user.updated_at = new Date().toISOString();

    res.status(200).json({
      id: user.id,
      email: user.email,
      name: user.name,
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to update profile',
      },
    });
  }
});

// POST /api/auth/password-reset/request
app.post('/api/auth/password-reset/request', (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Email is required',
        },
      });
    }

    // In a real implementation, you would send an email with a reset token
    // For mock server, we just return success
    res.status(200).json({
      message: 'Password reset email sent (mock)',
    });
  } catch (error) {
    console.error('Password reset request error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to request password reset',
      },
    });
  }
});

// POST /api/auth/password-reset/verify
app.post('/api/auth/password-reset/verify', async (req, res) => {
  try {
    const { token, password } = req.body;

    if (!token || !password) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Token and password are required',
        },
      });
    }

    // In a real implementation, you would verify the reset token
    // For mock server, we accept any token and update password
    // In production, you would need to validate the token and find the user

    res.status(200).json({
      message: 'Password reset successfully (mock)',
    });
  } catch (error) {
    console.error('Password reset verify error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to reset password',
      },
    });
  }
});

// DELETE /api/user/account
app.delete('/api/user/account', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    if (!decoded) {
      return res.status(401).json({
        error: {
          code: 'INVALID_TOKEN',
          message: 'Invalid or expired token',
        },
      });
    }

    // Find and remove user
    const userIndex = users.findIndex((u) => u.id === decoded.user_id);
    if (userIndex === -1) {
      return res.status(404).json({
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    users.splice(userIndex, 1);

    res.status(200).json({
      message: 'Account deleted successfully',
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to delete account',
      },
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Mock API server is running',
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Mock API server running on http://localhost:${PORT}`);
  console.log(`📝 API Base URL: http://localhost:${PORT}/api`);
  console.log(`\nAvailable endpoints:`);
  console.log(`  POST   /api/auth/register`);
  console.log(`  POST   /api/auth/login`);
  console.log(`  POST   /api/auth/refresh`);
  console.log(`  POST   /api/auth/logout`);
  console.log(`  GET    /api/user/profile`);
  console.log(`  PUT    /api/user/profile`);
  console.log(`  POST   /api/auth/password-reset/request`);
  console.log(`  POST   /api/auth/password-reset/verify`);
  console.log(`  DELETE /api/user/account`);
  console.log(`  GET    /health`);
});




