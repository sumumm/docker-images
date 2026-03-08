const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// 中间件
app.use(express.json());

// 基础路由
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker in Docker!',
    timestamp: new Date().toISOString(),
    container: process.env.HOSTNAME || 'unknown'
  });
});

// 健康检查端点
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// API 端点
app.get('/api/info', (req, res) => {
  res.json({
    name: 'DinD Example App',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    platform: process.platform,
    nodeVersion: process.version
  });
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${port}`);
  console.log(`📊 Health check: http://localhost:${port}/health`);
  console.log(`ℹ️  API info: http://localhost:${port}/api/info`);
});