# Post-MVP Features List

## Overview

This document lists all features that were planned but deferred to post-MVP phases. These features are designed and documented but not implemented in the MVP release (version 1.0.0).

**MVP Status**: The MVP is a local-only application with no cloud sync, no authentication, and no LLM integration. All data is stored locally on the device.

---

## 1. Cloud Sync & Multi-Device Support

### Description
Multi-device data synchronization using DreamHost PHP/MySQL backend with Slim Framework, enabling users to access their health data across multiple devices.

### Features
- **Cloud Sync**: Optional cloud sync for multi-device access
- **Backend**: DreamHost PHP/MySQL backend with Slim Framework
- **Authentication**: JWT-based authentication
- **Offline-First**: App works fully offline, sync happens in background
- **Conflict Resolution**: Timestamp-based (last write wins) with merge strategies
- **Incremental Sync**: Only sync changed data since last sync
- **Bidirectional Sync**: Sync from server to device and device to server

### Documentation
- `artifacts/phase-3-integration/sync-architecture-design.md` - Complete sync architecture
- `artifacts/phase-3-integration/api-documentation.md` - API documentation
- `docs/api/api-documentation.md` - API reference

### Status
**Post-MVP Phase 1** - Architecture designed, ready for implementation

---

## 2. User Authentication

### Description
User account system with JWT authentication, allowing users to create accounts, log in, and securely access their data across devices.

### Features
- **User Registration**: Create user accounts with email and password
- **User Login**: JWT-based authentication
- **Password Security**: Secure password hashing (bcrypt or Argon2)
- **Token Refresh**: JWT token refresh mechanism
- **Account Management**: User profile management
- **Password Reset**: Password recovery functionality

### Documentation
- `artifacts/phase-3-integration/api-documentation.md` - Authentication endpoints
- `artifacts/phase-3-integration/sync-architecture-design.md` - Auth implementation

### Status
**Post-MVP Phase 1** - Required for cloud sync

---

## 3. LLM Integration

### Description
Cost-effective large language model API integration for personalized health insights, meal suggestions, workout adaptations, and weekly reviews.

### Features
- **LLM API Abstraction Layer**: Provider pattern to easily switch between LLM providers (DeepSeek, OpenAI, Anthropic, etc.)
- **Weekly Reviews**: LLM-powered weekly progress reviews with personalized insights
- **Meal Suggestions**: LLM-powered meal plan suggestions based on preferences, goals, and progress
- **Workout Adaptations**: LLM-powered workout modifications based on progress, feedback, and joint concerns
- **Sale-Based Meal Planning**: LLM-powered meal plans based on grocery store sales and promotions
- **Coaching Insights**: Personalized weekly review summaries and motivational insights
- **Pattern Analysis**: LLM analysis of health patterns and correlations
- **Natural Language Insights**: Human-readable insights and recommendations

### LLM Provider Abstraction
- Abstract interface for LLM API calls
- Easy switching between providers (DeepSeek recommended for cost-effectiveness)
- Support for OpenAI, Anthropic, open-source alternatives
- No code changes required when switching providers

### Documentation
- `artifacts/phase-3-integration/integration-specifications.md` - LLM integration specs
- `artifacts/requirements.md` - LLM API interface specification

### Status
**Post-MVP Phase 1** - Architecture designed with abstraction layer

---

## 4. Advanced Analytics Module

### Description
Comprehensive analytics module providing advanced trend analysis, predictive analytics, correlation analysis, and personalized recommendations.

### Features
- **Advanced Trend Analysis**:
  - Multi-metric trend analysis
  - Seasonal pattern detection
  - Weight loss velocity analysis
  - Plateaus and breakthroughs identification
  - Macro trend correlations

- **Correlation Analysis**:
  - Cross-metric correlations
  - Cause-effect analysis
  - Pattern recognition
  - Nutrition-weight correlations
  - Exercise-health correlations
  - Medication-health correlations
  - Lifestyle-health correlations

- **Predictive Analytics**:
  - Weight loss predictions
  - Goal achievement projections
  - Trend forecasting
  - Optimal strategy recommendations
  - Projected weight loss based on current trends
  - Goal achievement timeline
  - Plateau risk assessment

- **LLM-Powered Insights**:
  - Natural language insights
  - Personalized recommendations
  - Pattern explanation
  - Actionable advice
  - Weekly analytics reports
  - Custom insights on demand

### Documentation
- `artifacts/phase-2-features/analytics-module-specification.md` - Complete analytics spec

### Status
**Post-MVP Phase 1** - Full specification complete

---

## 5. Grocery Store API Integration

### Description
Integration with grocery store APIs or web scraping for current sale items and promotions to enable sale-based meal planning.

### Features
- **Grocery Store APIs**: Integration with grocery store APIs (Kroger, Walmart, Maxi/Loblaw for Quebec, etc.)
- **Sale Item Data**: Automatic fetching of current sales and promotions
- **Sale-Based Meal Planning**: LLM-powered meal plans based on current sales
- **Cost Optimization**: Prioritize cost-effective ingredients while maintaining macro targets
- **Manual Entry Fallback**: Manual sale item entry (available in MVP)

### Supported Stores
- Kroger API
- Walmart API
- Maxi/Loblaw (Quebec)
- Other regional stores (extensible)

### Documentation
- `artifacts/requirements.md` - Grocery store integration requirements
- `artifacts/phase-2-features/nutrition-module-specification.md` - Sale-based meal planning

### Status
**Post-MVP Phase 2** - Manual entry available in MVP, API integration deferred

---

## 6. iOS Support

### Description
Extend the Flutter application to support iOS platform in addition to Android.

### Features
- **iOS App**: Full iOS version of the app
- **Platform-Specific Features**: iOS-specific integrations (HealthKit)
- **Cross-Platform Sync**: Sync data between Android and iOS devices
- **iOS Design Guidelines**: Follow iOS Human Interface Guidelines

### Documentation
- `artifacts/requirements.md` - iOS support mentioned as future phase
- `artifacts/orchestration-analysis-report/project-summary.md` - iOS in future phase

### Status
**Post-MVP Phase 2** - Android-only in MVP

---

## 7. Social Features (Optional)

### Description
Optional social features for sharing progress, connecting with others, and community support.

### Features
- **Progress Sharing**: Share progress photos and achievements
- **Community Features**: Connect with other users
- **Challenges**: Participate in health challenges
- **Social Feed**: View community updates

### Status
**Post-MVP Phase 2** - Optional future consideration

---

## 8. Enhanced Content Management

### Description
Advanced content management system for recipes, exercises, and educational content.

### Features
- **Content Updates**: System for adding new recipes, exercises, and educational materials
- **Content Curation**: Curated content updates
- **User-Generated Content**: Allow users to share recipes and exercises
- **Content Moderation**: Content review and moderation system

### Status
**Post-MVP Phase 2** - Basic content available in MVP

---

## Implementation Priority

### Phase 1 (Post-MVP - High Priority)
1. **Cloud Sync & Multi-Device Support** - Enables data access across devices
2. **User Authentication** - Required for cloud sync
3. **LLM Integration** - Core differentiator for personalized insights
4. **Advanced Analytics Module** - Enhanced user value

### Phase 2 (Post-MVP - Medium Priority)
5. **Grocery Store API Integration** - Cost optimization feature
6. **iOS Support** - Platform expansion
7. **Social Features** - Community engagement (optional)
8. **Enhanced Content Management** - Content expansion

---

## MVP vs Post-MVP Comparison

### MVP (Version 1.0.0)
- ✅ Local-only storage (Hive database)
- ✅ No user accounts or authentication
- ✅ No cloud sync
- ✅ No LLM integration
- ✅ Manual sale item entry
- ✅ Basic progress tracking
- ✅ Android-only
- ✅ Pre-populated recipe and exercise library

### Post-MVP
- ❌ Cloud sync (DreamHost PHP/MySQL)
- ❌ User authentication (JWT)
- ❌ LLM integration (weekly reviews, meal suggestions, workout adaptations)
- ❌ Grocery store API integration
- ❌ Advanced analytics
- ❌ iOS support
- ❌ Social features (optional)

---

## Technical Architecture for Post-MVP

### Backend Stack
- **Framework**: Slim Framework 4.x (PHP)
- **Database**: MySQL (DreamHost)
- **Authentication**: JWT tokens (firebase/php-jwt)
- **API**: REST API with JSON
- **Security**: HTTPS/SSL (Let's Encrypt via DreamHost)
- **Hosting**: DreamHost shared hosting

### LLM Integration
- **Abstraction Layer**: Provider pattern for easy switching
- **Default Provider**: DeepSeek (cost-effective)
- **Alternative Providers**: OpenAI, Anthropic, open-source alternatives
- **Interface**: Abstract interface for all LLM calls

### Sync Architecture
- **Strategy**: Offline-first with background sync
- **Conflict Resolution**: Timestamp-based with merge strategies
- **Sync Frequency**: Background sync when app is active
- **Data Privacy**: User must opt-in, can disable at any time

---

## References

### Documentation Files
- `artifacts/requirements.md` - Complete requirements and MVP decisions
- `artifacts/phase-2-features/analytics-module-specification.md` - Analytics module
- `artifacts/phase-3-integration/sync-architecture-design.md` - Sync architecture
- `artifacts/phase-3-integration/integration-specifications.md` - LLM integration
- `artifacts/phase-3-integration/api-documentation.md` - API documentation
- `artifacts/orchestration-analysis-report/project-summary.md` - Project summary
- `artifacts/final-product/executive-summary.md` - Executive summary

### Key Decisions
- **MVP Scope**: Subset of core modules, no LLM, no cloud sync, no authentication
- **Post-MVP Priority**: Cloud sync and authentication first, then LLM integration
- **LLM Provider**: DeepSeek recommended for cost-effectiveness
- **Backend**: DreamHost PHP/MySQL with Slim Framework
- **iOS Support**: Future phase, not in MVP

---

**Last Updated**: 2025-01-02  
**Version**: 1.0  
**Status**: Post-MVP Features Documentation Complete

