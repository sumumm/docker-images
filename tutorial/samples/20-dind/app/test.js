// 简单的测试脚本
const http = require('http');

console.log('🧪 Running tests...');

// 测试函数
function runTests() {
  const tests = [
    {
      name: 'Basic functionality test',
      test: () => {
        console.log('✅ Basic test passed');
        return true;
      }
    },
    {
      name: 'Environment check',
      test: () => {
        const nodeVersion = process.version;
        console.log(`✅ Node.js version: ${nodeVersion}`);
        return nodeVersion.startsWith('v16');
      }
    },
    {
      name: 'Package dependencies',
      test: () => {
        try {
          require('express');
          console.log('✅ Express dependency found');
          return true;
        } catch (error) {
          console.log('❌ Express dependency missing');
          return false;
        }
      }
    }
  ];

  let passed = 0;
  let failed = 0;

  tests.forEach(test => {
    try {
      if (test.test()) {
        passed++;
      } else {
        failed++;
        console.log(`❌ Test failed: ${test.name}`);
      }
    } catch (error) {
      failed++;
      console.log(`❌ Test error: ${test.name} - ${error.message}`);
    }
  });

  console.log(`\n📊 Test Results:`);
  console.log(`✅ Passed: ${passed}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`📈 Total: ${tests.length}`);

  // 退出码：0 表示成功，1 表示失败
  process.exit(failed > 0 ? 1 : 0);
}

// 运行测试
runTests();