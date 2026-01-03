# Feature Request: FR-020 - Backend Infrastructure

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 21  
**Created**: 2025-01-27  
**Updated**: 2025-01-27  
**Assigned Sprint**: Sprint 14 (Backend must be completed before FR-009 User Authentication and FR-008 Cloud Sync)

## Description

Build the complete backend infrastructure for the health management app using PHP with Slim Framework on DreamHost. This backend will provide REST API endpoints for authentication, data synchronization, and cloud storage, enabling multi-device support and cloud sync functionality. The backend must be fully operational before implementing user authentication (FR-009) and cloud sync (FR-008) features.

## User Story

As a developer, I want a fully functional backend API infrastructure, so that the mobile app can authenticate users, sync data across devices, and store user data securely in the cloud.

## Acceptance Criteria

### Infrastructure Setup
- [ ] DreamHost hosting account configured
- [ ] MySQL database created and configured
- [ ] PHP 8.1+ environment verified
- [ ] SSL certificate installed (Let's Encrypt via DreamHost)
- [ ] Domain/subdomain configured for API
- [ ] Composer dependencies installed
- [ ] Environment variables configured (.env file)
- [ ] .htaccess routing configured

### Database Schema
- [ ] Users table created with proper indexes
- [ ] Health metrics table created with proper indexes
- [ ] Medications table created with proper indexes
- [ ] Meals table created with proper indexes
- [ ] Exercises table created with proper indexes
- [ ] Meal plans table created with proper indexes
- [ ] Sync status table created with proper indexes
- [ ] Foreign key constraints configured
- [ ] Database migrations script created (if applicable)

### Core Backend Structure
- [ ] Slim Framework 4.x project structure created
- [ ] Middleware layer implemented (Auth, CORS, Error handling)
- [ ] Controllers layer implemented (Auth, HealthMetrics, Medications, Meals, Exercises, MealPlans, Sync)
- [ ] Services layer implemented (Database, Auth, Sync, ConflictResolver)
- [ ] Models layer implemented (User, HealthMetric, Medication, Meal, Exercise, MealPlan, SyncStatus)
- [ ] Utils layer implemented (JwtHelper, ResponseHelper)
- [ ] Configuration files created (database.php, app.php, .env)

### Authentication Endpoints
- [ ] POST /api/auth/register - User registration endpoint
- [ ] POST /api/auth/login - User login endpoint
- [ ] POST /api/auth/refresh - JWT token refresh endpoint
- [ ] POST /api/auth/verify-google-oauth - Google OAuth token verification endpoint (for FR-009)
- [ ] POST /api/auth/logout - User logout endpoint
- [ ] GET /api/auth/profile - Get user profile endpoint
- [ ] PUT /api/auth/profile - Update user profile endpoint
- [ ] DELETE /api/auth/account - Delete user account endpoint (GDPR compliance)

### Health Metrics Endpoints
- [ ] GET /api/health-metrics - Fetch health metrics with pagination
- [ ] POST /api/health-metrics - Create health metric
- [ ] PUT /api/health-metrics/:id - Update health metric
- [ ] DELETE /api/health-metrics/:id - Delete health metric
- [ ] POST /api/health-metrics/sync - Sync health metrics (bulk upload)
- [ ] GET /api/health-metrics/sync - Fetch health metrics for sync (incremental)

### Medications Endpoints
- [ ] GET /api/medications - Fetch medications
- [ ] POST /api/medications - Create medication
- [ ] PUT /api/medications/:id - Update medication
- [ ] DELETE /api/medications/:id - Delete medication
- [ ] POST /api/medications/sync - Sync medications (bulk upload)

### Meals Endpoints
- [ ] GET /api/meals - Fetch meals with date filtering
- [ ] POST /api/meals - Create meal
- [ ] PUT /api/meals/:id - Update meal
- [ ] DELETE /api/meals/:id - Delete meal
- [ ] POST /api/meals/sync - Sync meals (bulk upload)

### Exercises Endpoints
- [ ] GET /api/exercises - Fetch exercises
- [ ] POST /api/exercises - Create exercise
- [ ] PUT /api/exercises/:id - Update exercise
- [ ] DELETE /api/exercises/:id - Delete exercise
- [ ] POST /api/exercises/sync - Sync exercises (bulk upload)

### Meal Plans Endpoints
- [ ] GET /api/meal-plans - Fetch meal plans
- [ ] POST /api/meal-plans - Create meal plan
- [ ] PUT /api/meal-plans/:id - Update meal plan
- [ ] DELETE /api/meal-plans/:id - Delete meal plan
- [ ] POST /api/meal-plans/sync - Sync meal plans (bulk upload)

### Sync Endpoints
- [ ] POST /api/sync/bulk - Bulk sync all entity types
- [ ] GET /api/sync/status - Get sync status for user
- [ ] POST /api/sync/resolve-conflicts - Resolve sync conflicts

### Security Features
- [ ] JWT token generation and validation implemented
- [ ] Password hashing with bcrypt
- [ ] Google OAuth ID token verification (using google/apiclient library)
- [ ] HTTPS enforcement via .htaccess
- [ ] Input validation and sanitization
- [ ] SQL injection prevention (prepared statements)
- [ ] CORS middleware configured
- [ ] Rate limiting implemented (100 requests/minute per user)
- [ ] Authentication middleware protecting all endpoints

### Error Handling
- [ ] Standard error response format implemented
- [ ] HTTP status codes properly used (200, 201, 400, 401, 403, 404, 409, 422, 429, 500)
- [ ] Validation error responses with detailed messages
- [ ] Error logging implemented
- [ ] Error middleware for global error handling

### Conflict Resolution
- [ ] Timestamp-based conflict resolution (last write wins)
- [ ] Conflict detection logic implemented
- [ ] Custom merge strategies for complex entities
- [ ] Conflict response format with client/server versions

### Testing & Documentation
- [ ] API documentation complete (matches api-documentation.md)
- [ ] Postman/API testing collection created
- [ ] Database schema documentation
- [ ] Deployment documentation
- [ ] Environment setup guide
- [ ] Basic integration tests for critical endpoints

### Performance & Monitoring
- [ ] Database indexes optimized
- [ ] Query performance optimized
- [ ] Pagination implemented for large result sets
- [ ] Basic logging for API requests
- [ ] Error logging with stack traces

### CI/CD & Deployment
- [ ] GitHub Actions workflow created for automated deployment
- [ ] Deployment script for DreamHost (SFTP/SSH)
- [ ] Environment-specific configuration (development, staging, production)
- [ ] Automated Composer dependency installation on deployment
- [ ] Database migration script execution (if applicable)
- [ ] Pre-deployment validation checks
- [ ] Rollback mechanism for failed deployments
- [ ] Deployment notification system (email/Slack)
- [ ] Health check endpoint for deployment verification
- [ ] Deployment documentation and runbook

## Business Value

The backend infrastructure is foundational for enabling cloud sync and multi-device support, which are critical post-MVP features. Without this backend, users cannot:
- Access their data across multiple devices
- Securely store their health data in the cloud
- Benefit from cloud-based features like LLM integration
- Have data backup and recovery options

This infrastructure is a prerequisite for FR-008 (Cloud Sync) and FR-009 (User Authentication), making it a high-priority blocker for post-MVP Phase 1 features.

## Technical Requirements

### Technology Stack
- **Backend Framework**: Slim Framework 4.x
- **Language**: PHP 8.1+
- **Database**: MySQL (DreamHost)
- **Authentication**: JWT tokens (firebase/php-jwt library)
- **OAuth Verification**: Google API Client Library for PHP (google/apiclient via Composer)
- **API Style**: REST API with JSON
- **Security**: HTTPS/SSL (Let's Encrypt via DreamHost)
- **Hosting**: DreamHost shared hosting

### Project Structure
```
api/
├── public/
│   ├── index.php              # Entry point
│   └── .htaccess              # Apache routing
├── src/
│   ├── Middleware/
│   │   ├── AuthMiddleware.php      # JWT validation
│   │   ├── CorsMiddleware.php      # CORS handling
│   │   └── ErrorMiddleware.php     # Error handling
│   ├── Controllers/
│   │   ├── AuthController.php      # Authentication endpoints
│   │   ├── HealthMetricsController.php
│   │   ├── MedicationsController.php
│   │   ├── MealsController.php
│   │   ├── ExercisesController.php
│   │   ├── MealPlansController.php
│   │   └── SyncController.php     # Bulk sync endpoint
│   ├── Services/
│   │   ├── DatabaseService.php     # Database operations
│   │   ├── AuthService.php         # Authentication logic
│   │   ├── SyncService.php         # Sync logic
│   │   └── ConflictResolver.php    # Conflict resolution
│   ├── Models/
│   │   ├── User.php
│   │   ├── HealthMetric.php
│   │   ├── Medication.php
│   │   └── SyncStatus.php
│   └── Utils/
│       ├── JwtHelper.php
│       └── ResponseHelper.php
├── config/
│   ├── database.php           # Database configuration
│   ├── app.php                # App configuration
│   └── .env                   # Environment variables
├── .github/
│   └── workflows/
│       └── deploy.yml         # GitHub Actions deployment workflow
├── scripts/
│   ├── deploy.sh              # Deployment script for DreamHost
│   ├── deploy-dreamhost.sh    # DreamHost-specific deployment
│   ├── setup-env.sh           # Environment setup script
│   └── health-check.sh        # Health check script
├── vendor/                    # Composer dependencies
├── composer.json
├── composer.lock
└── .htaccess                   # Root .htaccess
```

### Database Requirements
- MySQL database with UTF-8 encoding (utf8mb4)
- All tables with proper indexes for performance
- Foreign key constraints for data integrity
- Soft delete support (deleted_at timestamps)
- JSON columns for flexible data storage

### Security Requirements
- All API endpoints use HTTPS
- JWT tokens expire after 24 hours (access token) and 30 days (refresh token)
- Passwords hashed with bcrypt (cost factor 10+)
- Google OAuth ID tokens verified using Google API Client Library
- Input validation on all endpoints
- SQL injection prevention via prepared statements
- Rate limiting: 100 requests/minute per user (except auth endpoints: 5/minute)
- CORS configured for mobile app domain

### Performance Requirements
- API response time < 500ms for standard operations
- Database queries optimized with proper indexes
- Pagination for endpoints returning large datasets (default limit: 100)
- Connection pooling for database connections
- Efficient JSON serialization/deserialization

### API Requirements
- RESTful API design
- JSON request/response format
- Consistent error response format
- Standard HTTP status codes
- API versioning (v1)
- Base URL: `https://api.healthapp.example.com/v1` (production)

### CI/CD Requirements
- **CI/CD Platform**: GitHub Actions
- **Deployment Method**: SFTP or SSH to DreamHost
- **Deployment Triggers**: 
  - Manual deployment from GitHub Actions
  - Automatic deployment on push to `main` branch (optional)
  - Tag-based releases for production
- **Deployment Steps**:
  1. Run tests (if applicable)
  2. Install Composer dependencies (`composer install --no-dev --optimize-autoloader`)
  3. Upload files to DreamHost via SFTP/SSH
  4. Run database migrations (if applicable)
  5. Verify deployment with health check endpoint
  6. Send deployment notification
- **Environment Management**: 
  - Separate `.env` files for development, staging, production
  - Environment variables stored as GitHub Secrets
  - `.env` file not committed to repository
- **Rollback Strategy**: 
  - Keep previous deployment version
  - Quick rollback script to restore previous version
  - Database migration rollback support
- **Health Check**: 
  - GET `/api/health` endpoint for deployment verification
  - Returns API status, database connectivity, version info

## Reference Documents

- `../../project-management-old/artifacts/phase-3-integration/sync-architecture-design.md` - Complete backend architecture design
- `../../app/docs/api/api-documentation.md` - Complete API endpoint specifications
- `../../app/docs/post-mvp-features.md` - Post-MVP features overview
- `../FR-009-user-authentication.md` - User authentication requirements (depends on this)
- `../FR-008-cloud-sync-multi-device-support.md` - Cloud sync requirements (depends on this)

## Technical References

- **Slim Framework**: https://www.slimframework.com/docs/v4/
- **JWT Library**: firebase/php-jwt (via Composer)
- **Google API Client**: google/apiclient (via Composer) - for OAuth verification
- **Database Schema**: See sync-architecture-design.md for complete schema
- **API Endpoints**: See api-documentation.md for complete endpoint specifications
- **Backend Structure**: See sync-architecture-design.md for project structure
- **Authentication Flow**: See FR-009 for Google OAuth integration details

## Dependencies

### Prerequisites (Must Complete First)
- DreamHost hosting account must be active
- Domain/subdomain must be configured
- SSL certificate must be installed
- MySQL database must be created

### Blocks (Cannot Start Until This Is Complete)
- FR-009 (User Authentication) - Requires backend authentication endpoints
- FR-008 (Cloud Sync & Multi-Device Support) - Requires complete backend API
- FR-010 (LLM Integration) - May require backend endpoints for LLM API calls

### Parallel Work Possible
- Frontend sync service implementation can begin once API endpoints are defined
- API documentation can be finalized in parallel
- Database schema can be designed in parallel with backend development

## Notes

- **Critical Path Item**: This is a blocker for FR-008 and FR-009, making it high priority
- **Post-MVP Phase 1**: This is the first post-MVP infrastructure feature
- **DreamHost Compatibility**: Must work within DreamHost shared hosting constraints
- **Google OAuth**: Backend must verify Google OAuth ID tokens (not Firebase Auth) - see FR-009
- **JWT Implementation**: Use existing firebase/php-jwt library for JWT generation/validation
- **Database Design**: JSON columns used for flexible data storage (matches Flutter Hive structure)
- **Conflict Resolution**: Timestamp-based (last write wins) with custom merge for complex cases
- **Offline-First Support**: Backend must support incremental sync (since parameter)
- **GDPR Compliance**: Account deletion must remove all user data (cascade deletes)
- **Rate Limiting**: Implement to prevent abuse and manage server resources
- **Error Logging**: Critical for debugging production issues
- **Testing**: Basic integration tests recommended before deployment
- **Documentation**: API documentation must be complete and accurate for frontend integration
- **CI/CD**: Automated deployment via GitHub Actions to DreamHost using SFTP/SSH
- **Deployment Scripts**: Shell scripts for DreamHost deployment, environment setup, and health checks
- **Environment Variables**: Sensitive data (DB credentials, JWT secret) stored as GitHub Secrets
- **Deployment Safety**: Health check endpoint required before marking deployment as successful

## CI/CD Deployment Scripts

### GitHub Actions Workflow

The deployment workflow should be located at `.github/workflows/deploy.yml` and include:

**Key Features**:
- Trigger on push to `main` branch or manual workflow dispatch
- Install PHP dependencies via Composer
- Upload files to DreamHost via SFTP or SSH
- Run database migrations (if applicable)
- Execute health check to verify deployment
- Send deployment notifications

**Example Workflow Structure**:
```yaml
name: Deploy to DreamHost

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
      - name: Install Composer dependencies
        run: composer install --no-dev --optimize-autoloader
      - name: Deploy to DreamHost
        uses: SamKirkland/FTP-Deploy-Action@4.3.0
        with:
          server: ${{ secrets.DREAMHOST_FTP_SERVER }}
          username: ${{ secrets.DREAMHOST_FTP_USER }}
          password: ${{ secrets.DREAMHOST_FTP_PASSWORD }}
          local-dir: ./
          server-dir: /api/
          exclude: |
            **/.git*
            **/.git*/**
            **/node_modules/**
            **/.env
            **/.env.*
      - name: Health Check
        run: |
          curl -f https://api.healthapp.example.com/api/health || exit 1
```

### Deployment Scripts

**`scripts/deploy-dreamhost.sh`**:
- SFTP/SSH connection to DreamHost
- File upload with exclusions (.git, node_modules, .env files)
- Composer dependency installation on server
- Database migration execution
- Health check verification
- Rollback on failure

**`scripts/setup-env.sh`**:
- Environment variable setup
- .env file generation from template
- Database connection verification
- SSL certificate verification

**`scripts/health-check.sh`**:
- API health endpoint check
- Database connectivity test
- Response time validation
- Return appropriate exit codes

### DreamHost Deployment Considerations

- **SFTP Access**: DreamHost provides SFTP access for file uploads
- **SSH Access**: May require enabling SSH access in DreamHost panel
- **Composer**: Must be available on DreamHost server or install via deployment script
- **File Permissions**: Ensure proper file permissions (644 for files, 755 for directories)
- **.htaccess**: Must be uploaded and configured correctly
- **Environment Variables**: .env file must be created on server (not committed to repo)
- **Database**: Connection details stored in .env file on server

### Security for CI/CD

- **GitHub Secrets**: Store all sensitive data (FTP credentials, DB passwords, JWT secrets) as GitHub Secrets
- **Environment Files**: Never commit .env files to repository
- **Deployment Keys**: Use secure SFTP/SSH credentials
- **Access Control**: Limit GitHub Actions permissions to necessary scopes

## History

- 2025-01-27 - Created
- 2025-01-27 - Added CI/CD deployment scripts and GitHub Actions workflow requirements

