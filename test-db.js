const { PrismaClient } = require('@prisma/client');
require('dotenv').config();

const prisma = new PrismaClient();

async function testConnection() {
  try {
    console.log('Testing database connection...');
    console.log('DATABASE_URL:', process.env.DATABASE_URL);
    
    // ทดสอบ connection
    await prisma.$connect();
    console.log('✅ Database connected successfully!');
    
    // ทดสอบ query sederhana
    const result = await prisma.$queryRaw`SELECT 1 as test`;
    console.log('✅ Query test:', result);
    
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testConnection();

