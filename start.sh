#!/bin/sh

set -e

echo "🚀 Starting application startup script..."

# 检查并构建 DATABASE_URL（如果需要）
if [ -z "$DATABASE_URL" ]; then
  echo "⚠️ DATABASE_URL not set, constructing from individual variables..."
  if [ -n "$DATABASE_HOST" ] && [ -n "$DATABASE_USER" ] && [ -n "$DATABASE_PASSWORD" ] && [ -n "$DATABASE_NAME" ]; then
    DATABASE_PORT=${DATABASE_PORT:-3306}
    DATABASE_URL="mysql://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
    export DATABASE_URL
    echo "✅ DATABASE_URL constructed: mysql://${DATABASE_USER}:***@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
  else
    echo "❌ Missing database connection variables. Need DATABASE_HOST, DATABASE_USER, DATABASE_PASSWORD, DATABASE_NAME"
    exit 1
  fi
fi

# 等待数据库就绪
echo "⏳ Waiting for database to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0

# 从 DATABASE_URL 提取主机和端口
DB_HOST=$(echo "$DATABASE_URL" | sed -e 's/.*@//' -e 's/:.*//')
DB_PORT=$(echo "$DATABASE_URL" | sed -e 's/.*@//' -e 's/.*://' -e 's/\/.*//')

# 如果端口提取失败，使用默认值
if [ -z "$DB_PORT" ] || [ "$DB_PORT" = "$DB_HOST" ]; then
  DB_PORT=3306
fi

echo "🔍 Checking database at ${DB_HOST}:${DB_PORT}"

# 使用 Node.js 尝试连接数据库
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if node -e "
    const net = require('net');
    
    const client = net.createConnection({ host: '${DB_HOST}', port: ${DB_PORT} }, () => {
      console.log('✅ Database port is open');
      client.end();
      process.exit(0);
    });
    
    client.on('error', (err) => {
      console.log('⏳ Database not ready yet:', err.message);
      process.exit(1);
    });
    
    client.setTimeout(5000, () => {
      console.log('⏳ Database connection timeout');
      client.destroy();
      process.exit(1);
    });
  " 2>/dev/null; then
    echo "✅ Database is reachable!"
    # 再等待一小段时间确保数据库完全初始化
    sleep 2
    break
  fi
  
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Database did not become ready after ${MAX_RETRIES} attempts"
    exit 1
  fi
  
  echo "⏳ Retrying in 2 seconds... (attempt ${RETRY_COUNT}/${MAX_RETRIES})"
  sleep 2
done

# 执行数据库迁移
echo "🔄 Running database migrations..."
# 使用 npx 运行 prisma，指定版本以确保一致性
if npx prisma@7.3.0 migrate deploy; then
  echo "✅ Database migrations completed successfully!"
else
  echo "❌ Database migrations failed"
  exit 1
fi

# 启动应用
echo "🚀 Starting application..."
exec node server.js
