#!/bin/bash

# deploy-schema.sh - Deploy database schema to DreamHost
# Usage: ./deploy-schema.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Health App - Database Schema Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Prompt for database credentials
if [ -z "$DB_HOST" ]; then
    read -p "Enter MySQL host: " DB_HOST
fi

if [ -z "$DB_USER" ]; then
    read -p "Enter MySQL user: " DB_USER
fi

if [ -z "$DB_PASS" ]; then
    read -sp "Enter MySQL password: " -s DB_PASS
fi

if [ -z "$DB_NAME" ]; then
    read -p "Enter database name: " DB_NAME
fi

echo -e "${YELLOW}Connecting to MySQL server...${NC}"

# Test connection
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}Connection failed! Please check your credentials.${NC}"
    exit 1
fi

echo -e "${GREEN}Connection successful!${NC}"
echo ""

# Run schema
echo -e "${YELLOW}Running database migrations...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/database/schema.sql"

if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}Schema file not found: $SCHEMA_FILE${NC}"
    exit 1
fi

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Schema deployed successfully!${NC}"
    echo ""
    echo -e "${GREEN}Tables created:${NC}"
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;" | grep -v "Tables_in_" | wc -l
else
    echo -e "${RED}Schema deployment failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
