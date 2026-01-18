#!/bin/bash

# FR-008 Sync Testing Script
# Quick commands for manual testing

# Configuration
API_URL="http://localhost:8000/api/v1"
TOKEN="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_usage() {
    echo "Usage: $0 <TOKEN> [command]"
    echo ""
    echo "Commands:"
    echo "  meals-create    - Create a test meal"
    echo "  meals-list      - List all meals"
    echo "  meals-sync      - Sync meal changes"
    echo "  meals-delete    - Delete a meal (soft delete)"
    echo "  exercises-create - Create a test exercise"
    echo "  exercises-list   - List all exercises"
    echo "  exercises-sync   - Sync exercise changes"
    echo "  meds-create     - Create a test medication"
    echo "  meds-list       - List all medications"
    echo "  delta-sync      - Test delta sync"
    echo "  conflict-test   - Test conflict resolution"
    echo ""
    echo "Example:"
    echo "  $0 'YOUR_JWT_TOKEN' meals-create"
}

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Error: JWT token required${NC}"
    print_usage
    exit 1
fi

COMMAND="${2:-}"

# Helper function for API calls
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3

    if [ -z "$data" ]; then
        curl -s -X $method \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            "$API_URL$endpoint" | jq .
    else
        curl -s -X $method \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_URL$endpoint" | jq .
    fi
}

# Meal commands
case $COMMAND in
    meals-create)
        echo -e "${BLUE}Creating test meal...${NC}"
        api_call POST "/meals/sync" '{
            "changes": [
                {
                    "client_id": "'$(uuidgen)'",
                    "date": "'$(date +%Y-%m-%d)'",
                    "meal_type": "breakfast",
                    "name": "Test Meal - '$RANDOM'",
                    "calories": 350,
                    "protein_g": 25,
                    "fats_g": 15,
                    "carbs_g": 30,
                    "created_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
                    "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }
            ]
        }'
        ;;

    meals-list)
        echo -e "${BLUE}Listing all meals...${NC}"
        api_call GET "/meals"
        ;;

    meals-sync)
        echo -e "${BLUE}Syncing meals (delta sync)...${NC}"
        api_call POST "/meals/sync" '{
            "last_sync_timestamp": "'$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)'"
        }'
        ;;

    meals-delete)
        echo -e "${BLUE}Testing soft delete...${NC}"
        # First create a meal
        CREATE_RESPONSE=$(curl -s -X POST \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d '{
                "changes": [{
                    "client_id": "'$(uuidgen)'",
                    "date": "'$(date +%Y-%m-%d)'",
                    "meal_type": "lunch",
                    "name": "Meal to Delete",
                    "calories": 500,
                    "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }]
            }' \
            "$API_URL/meals/sync")

        echo -e "${GREEN}Created meal. Now deleting...${NC}"

        # Delete it
        api_call POST "/meals/sync" '{
            "changes": [
                {
                    "client_id": "test-delete-'$(uuidgen)'",
                    "deleted_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
                    "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }
            ]
        }'
        ;;

    exercises-create)
        echo -e "${BLUE}Creating test exercise...${NC}"
        api_call POST "/exercises/sync" '{
            "exercises": [
                {
                    "type": "cardio",
                    "name": "Test Run - '$RANDOM'",
                    "date": "'$(date +%Y-%m-%d)'",
                    "duration_minutes": 30,
                    "calories_burned": 350,
                    "distance_km": 5,
                    "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }
            ]
        }'
        ;;

    exercises-list)
        echo -e "${BLUE}Listing all exercises...${NC}"
        api_call GET "/exercises"
        ;;

    exercises-sync)
        echo -e "${BLUE}Syncing exercises...${NC}"
        api_call POST "/exercises/sync" '{
            "exercises": [
                {
                    "type": "strength",
                    "name": "Bench Press",
                    "is_template": true,
                    "sets": 4,
                    "reps": 8,
                    "weight_kg": 100,
                    "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }
            ]
        }'
        ;;

    meds-create)
        echo -e "${BLUE}Creating test medication...${NC}"
        api_call POST "/medications/sync" '{
            "changes": [
                {
                    "client_id": "'$(uuidgen)'",
                    "name": "Test Med - '$RANDOM'",
                    "dosage": 100,
                    "unit": "mg",
                    "frequency": "Once daily",
                    "start_date": "'$(date +%Y-%m-%d)'",
                    "active": true,
                    "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }
            ]
        }'
        ;;

    meds-list)
        echo -e "${BLUE}Listing all medications...${NC}"
        api_call GET "/medications"
        ;;

    delta-sync)
        echo -e "${BLUE}Testing delta sync (meals changed in last hour)...${NC}"
        CUTOFF_TIME=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)
        echo -e "${BLUE}Using cutoff time: $CUTOFF_TIME${NC}"
        api_call POST "/meals/sync" '{
            "last_sync_timestamp": "'$CUTOFF_TIME'"
        }'
        ;;

    conflict-test)
        echo -e "${BLUE}Testing conflict resolution...${NC}"
        CLIENT_ID=$(uuidgen)
        echo -e "${GREEN}Using client_id: $CLIENT_ID${NC}"

        # Step 1: Create meal
        echo -e "\n${BLUE}Step 1: Creating initial meal with timestamp 12:00...${NC}"
        api_call POST "/meals/sync" '{
            "changes": [
                {
                    "client_id": "'$CLIENT_ID'",
                    "date": "'$(date +%Y-%m-%d)'",
                    "meal_type": "lunch",
                    "name": "Conflict Test Meal",
                    "calories": 500,
                    "updated_at": "2026-01-18T12:00:00Z"
                }
            ]
        }'

        # Step 2: Update with newer timestamp
        echo -e "\n${BLUE}Step 2: Updating with newer timestamp 13:00 (should succeed)...${NC}"
        api_call POST "/meals/sync" '{
            "changes": [
                {
                    "client_id": "'$CLIENT_ID'",
                    "date": "'$(date +%Y-%m-%d)'",
                    "meal_type": "lunch",
                    "name": "Conflict Test Meal - UPDATED",
                    "calories": 600,
                    "updated_at": "2026-01-18T13:00:00Z"
                }
            ]
        }'

        # Step 3: Try update with older timestamp
        echo -e "\n${BLUE}Step 3: Trying update with older timestamp 11:00 (should be rejected)...${NC}"
        api_call POST "/meals/sync" '{
            "changes": [
                {
                    "client_id": "'$CLIENT_ID'",
                    "date": "'$(date +%Y-%m-%d)'",
                    "meal_type": "lunch",
                    "name": "Conflict Test Meal - OLD VERSION",
                    "calories": 400,
                    "updated_at": "2026-01-18T11:00:00Z"
                }
            ]
        }'

        echo -e "\n${GREEN}Conflict test complete. Check if Step 3 was rejected (updated_count should be 0).${NC}"
        ;;

    *)
        if [ -n "$COMMAND" ]; then
            echo -e "${RED}Unknown command: $COMMAND${NC}"
        fi
        print_usage
        exit 1
        ;;
esac
