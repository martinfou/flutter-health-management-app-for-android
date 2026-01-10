# Docker Database Setup for Development

This Docker setup provides a MySQL 8.0 database and phpMyAdmin for local development.

## Services

- **MySQL 8.0**: Database server on port 3306
- **phpMyAdmin**: Web interface on port 8080

## Quick Start

### 1. Start the Database

```bash
docker-compose up -d
```

### 2. Check Status

```bash
docker-compose ps
```

### 3. View Logs

```bash
docker-compose logs -f mysql
```

### 4. Access phpMyAdmin

Open your browser: http://localhost:8080

**Login credentials:**
- Server: `mysql`
- Username: `health_app_user`
- Password: `health_app_password`

## Database Configuration

| Setting | Value |
|---------|-------|
| Host | 127.0.0.1 (localhost) |
| Port | 3306 |
| Database | health_app |
| Username | health_app_user |
| Password | health_app_password |
| Root Password | root_password |

## Useful Commands

### Stop Containers
```bash
docker-compose down
```

### Stop and Remove Data
```bash
docker-compose down -v
```

### Restart Containers
```bash
docker-compose restart
```

### Access MySQL CLI
```bash
docker-compose exec mysql mysql -u health_app_user -phealth_app_password health_app
```

### Access MySQL as Root
```bash
docker-compose exec mysql mysql -u root -proot_password
```

### Import SQL File
```bash
docker-compose exec -T mysql mysql -u health_app_user -phealth_app_password health_app < backup.sql
```

### Export Database
```bash
docker-compose exec mysql mysqldump -u health_app_user -phealth_app_password health_app > backup.sql
```

## Database Schema

The database schema is automatically initialized from:
- `docker/mysql/init/01-schema.sql`

Any `.sql` files in the `docker/mysql/init/` directory will be executed in alphabetical order when the container is first created.

## Data Persistence

Database data is stored in a Docker volume named `mysql_data`. This means:
- Data persists between container restarts
- Data is preserved when you run `docker-compose down`
- Data is only deleted when you run `docker-compose down -v`

## Troubleshooting

### Container won't start
1. Check if port 3306 is already in use: `lsof -i :3306`
2. Stop any existing MySQL processes
3. Try: `docker-compose down -v && docker-compose up -d`

### Can't connect from Laravel
1. Verify container is running: `docker-compose ps`
2. Check Laravel .env has correct credentials
3. Test connection: `docker-compose exec mysql mysql -u health_app_user -phealth_app_password health_app -e "SELECT 1"`

### Reset Database
```bash
docker-compose down -v
docker-compose up -d
```

This will delete all data and recreate the database with the schema.

## Production Notes

⚠️ **DO NOT use these credentials in production!**

For production:
1. Use strong, unique passwords
2. Use environment-specific .env files
3. Configure proper MySQL user permissions
4. Enable SSL/TLS connections
5. Set up regular backups
