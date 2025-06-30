// Load environment variables first
require("dotenv").config();

const express = require("express");
const { PrismaClient } = require("@prisma/client");
const cors = require("cors");

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

// Add a health check endpoint to verify environment
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    database_configured: !!process.env.DATABASE_URL,
  });
});

// Add this right after your /health endpoint
app.get("/", (req, res) => {
  res.json({ 
    message: "BackJob API is running!",
    timestamp: new Date().toISOString(),
    port: process.env.PORT || 5000
  });
});

/**
 * [GET] /api/jobs (Query all jobs) ✅
 * [GET] /api/jobs/:id (Query info job) ✅
 * [GET] /api/query/position (Get all position [FOR SEARCH]) ✅
 * [GET] /api/query/position-group (Get all position group) ✅
 * [POST] /api/job-skills (Replace all job skills data) ✅
 */

// ✅ ดึงตำแหน่งงานทั้งหมด
app.get("/api/jobs", async (req, res) => {
  let {
    page = 0,
    size = 13,
    sortTrending = "asc",
    groupOfPos = "",
    search = "",
    language = "",
  } = req.query;
  if (size >= 100) size = 100;
  console.log(`Trending: ${sortTrending} | Group pos IDS: ${groupOfPos}`);
  // Transform data group
  // 0,1,2,3,4 => ['0','1','2','3','4'] => [0,1,2,3,4] => [1,2,3,4]
  const groupIds = groupOfPos // 0,1,2,3,4
    .split(",") // ['0','1','2','3','4']
    .map((i) => Number(i)) //  [0,1,2,3,4]
    .filter((i) => i > 0); // [1,2,3,4]

  const queryBase = {
    ...(groupIds.length > 0
      ? {
          position: {
            group_id: {
              in: groupIds,
            },
          },
        }
      : {}),
    ...(language !== ""
      ? {
          position: {
            job_skills: {
              some: {
                skill_id: Number(language),
              },
            },
          },
        }
      : {}),
  };

  const whereQuery = {
    ...(search != ""
      ? {
          OR: [
            {
              position: {
                name: {
                  contains: search,
                },
              },
            },
            {
              position: {
                job_skills: {
                  some: {
                    skills: {
                      name: {
                        contains: search,
                      },
                    },
                  },
                },
              },
            },
          ],
          ...queryBase,
        }
      : {
          ...queryBase,
        }),
  };

  try {
    const jobs = await prisma.position_details.findMany({
      skip: page * size, // you were skipping 0 before; now dynamic
      take: Number(size),
      where: whereQuery, // <-- this applies your filters
      orderBy: {
        trending: {
          level: sortTrending,
        },
      },
      select: {
        id: true,
        description: true,
        created_at: true,
        updated_at: true,
        trending: {
          select: { name: true },
        },
        position: {
          select: {
            id: true,
            name: true,
            group_id: true,
            job_skills: {
              select: {
                job_id: true,
                skill_id: true,
                score: true,
                skills: {
                  select: {
                    id: true,
                    name: true,
                    group: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    console.log(JSON.stringify(jobs, null, 2)); // Pretty print result
    // Get total job query
    const totalData = await prisma.position_details.count({
      where: whereQuery,
    });

    res.json({
      items: jobs,
      pagination: {
        total: totalData,
        pageTotal: Math.ceil(totalData / size), // Fixed: use Math.ceil instead of Math.trunc
      },
    });
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ ดึงข้อมูลตำแหน่งงานเฉพาะ ID
app.get("/api/jobs/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const job = await prisma.position_details.findUnique({
      where: { id: parseInt(id) },
      select: {
        id: true,
        trending: { select: { name: true } },
        created_at: true,
        updated_at: true,
        description: true,
        responsibilities: true,
        position: {
          select: {
            id: true,
            name: true,
            group_id: true,
            job_skills: {
              select: {
                job_id: true,
                skill_id: true,
                score: true,
                skills: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
    });
    console.log(JSON.stringify(job, null, 2));
    if (!job) return res.status(404).json({ message: "Job not found" });
    res.json(job);
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/query/position", async (req, res) => {
  try {
    const result = await prisma.position.findMany({
      select: { id: true, name: true },
    });
    res.json(result);
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/query/position-group", async (req, res) => {
  try {
    const result = await prisma.position_group.findMany({
      select: { id: true, name: true },
    });
    res.json(result);
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/query/mainpageScore", async (req, res) => {
  try {
    const result = await prisma.job_skills.findMany({
      select: {
        score: true,
        skills: {
          select: {
            name: true,
          },
        },
      },
    });
    const transformed = result.map((item) => ({
      skill: item.skills?.name ?? "Unknown", // เผื่อกรณี null
      score: item.score,
    }));

    res.json(transformed);
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * [POST] /api/job-skills (Replace all job skills data completely) ✅
 */
app.post("/api/job-skills", async (req, res) => {
  try {
    const jobSkillsData = req.body;
    
    // Validate input - should be an array
    if (!Array.isArray(jobSkillsData)) {
      return res.status(400).json({ 
        error: "Request body must be an array of job skills objects" 
      });
    }

    // Allow empty array to clear all data
    if (jobSkillsData.length === 0) {
      // Use transaction to safely delete all records
      const result = await prisma.$transaction(async (tx) => {
        const deleteResult = await tx.job_skills.deleteMany({});
        return { deleted_count: deleteResult.count, inserted_count: 0 };
      });

      console.log(`✅ Cleared all job skills data. Deleted ${result.deleted_count} records`);
      
      return res.status(200).json({
        message: "All job skills data cleared successfully",
        deleted_count: result.deleted_count,
        inserted_count: 0,
        data: []
      });
    }

    // Validate each job skill object
    for (let i = 0; i < jobSkillsData.length; i++) {
      const item = jobSkillsData[i];
      
      if (!item.job_id || !item.skill_id) {
        return res.status(400).json({ 
          error: `Missing required fields (job_id, skill_id) at index ${i}` 
        });
      }

      if (typeof item.job_id !== 'number' || typeof item.skill_id !== 'number') {
        return res.status(400).json({ 
          error: `job_id and skill_id must be numbers at index ${i}` 
        });
      }

      if (item.score && (typeof item.score !== 'number' || item.score < 0 || item.score > 100)) {
        return res.status(400).json({ 
          error: `Score must be a number between 0-100 at index ${i}` 
        });
      }
    }

    // Check if positions and skills exist
    const jobIds = [...new Set(jobSkillsData.map(item => item.job_id))];
    const skillIds = [...new Set(jobSkillsData.map(item => item.skill_id))];

    const existingPositions = await prisma.position.findMany({
      where: { id: { in: jobIds } },
      select: { id: true }
    });

    const existingSkills = await prisma.skills.findMany({
      where: { id: { in: skillIds } },
      select: { id: true }
    });

    const existingPositionIds = existingPositions.map(p => p.id);
    const existingSkillIds = existingSkills.map(s => s.id);

    // Check for non-existent positions
    const invalidJobIds = jobIds.filter(id => !existingPositionIds.includes(id));
    if (invalidJobIds.length > 0) {
      return res.status(400).json({ 
        error: `Position IDs not found: ${invalidJobIds.join(', ')}` 
      });
    }

    // Check for non-existent skills
    const invalidSkillIds = skillIds.filter(id => !existingSkillIds.includes(id));
    if (invalidSkillIds.length > 0) {
      return res.status(400).json({ 
        error: `Skill IDs not found: ${invalidSkillIds.join(', ')}` 
      });
    }

    // Prepare data for insertion
    const dataToInsert = jobSkillsData.map(item => ({
      job_id: item.job_id,
      skill_id: item.skill_id,
      score: item.score || 0
    }));

    // Use transaction to replace all data atomically
    const result = await prisma.$transaction(async (tx) => {
      // First, delete all existing job_skills records
      const deleteResult = await tx.job_skills.deleteMany({});
      console.log(`🗑️ Deleted ${deleteResult.count} existing job skills records`);

      // Then, insert the new data
      const insertResult = await tx.job_skills.createMany({
        data: dataToInsert
      });
      console.log(`✅ Inserted ${insertResult.count} new job skills records`);

      return {
        deleted_count: deleteResult.count,
        inserted_count: insertResult.count
      };
    });

    console.log(`✅ Successfully replaced all job skills data`);
    console.log(`   - Deleted: ${result.deleted_count} records`);
    console.log(`   - Inserted: ${result.inserted_count} records`);

    res.status(200).json({
      message: "Job skills data replaced successfully",
      deleted_count: result.deleted_count,
      inserted_count: result.inserted_count,
      data: dataToInsert
    });

  } catch (error) {
    console.error("Database error:", error);
    
    // Handle specific Prisma errors
    if (error.code === 'P2002') {
      res.status(409).json({ 
        error: "Duplicate entry: Some job_id and skill_id combinations are duplicated in the request" 
      });
    } else if (error.code === 'P2003') {
      res.status(400).json({ 
        error: "Foreign key constraint failed: Invalid job_id or skill_id" 
      });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// Keep the single insert endpoint for adding individual records without replacing all data
app.post("/api/job-skills/add", async (req, res) => {
  try {
    const { job_id, skill_id, score = 0 } = req.body;

    // Validate required fields
    if (!job_id || !skill_id) {
      return res.status(400).json({ 
        error: "job_id and skill_id are required" 
      });
    }

    // Validate data types
    if (typeof job_id !== 'number' || typeof skill_id !== 'number') {
      return res.status(400).json({ 
        error: "job_id and skill_id must be numbers" 
      });
    }

    if (score && (typeof score !== 'number' || score < 0 || score > 100)) {
      return res.status(400).json({ 
        error: "Score must be a number between 0-100" 
      });
    }

    // Check if position and skill exist
    const position = await prisma.position.findUnique({
      where: { id: job_id }
    });

    const skill = await prisma.skills.findUnique({
      where: { id: skill_id }
    });

    if (!position) {
      return res.status(404).json({ error: `Position with ID ${job_id} not found` });
    }

    if (!skill) {
      return res.status(404).json({ error: `Skill with ID ${skill_id} not found` });
    }

    // Insert single job skill (or update if exists)
    const result = await prisma.job_skills.upsert({
      where: {
        // Note: You might need to add a unique constraint on job_id + skill_id combination
        // For now, we'll use the id field, but this might need adjustment based on your schema
        id: 0 // This will always create a new record since id 0 doesn't exist
      },
      update: {
        score: score
      },
      create: {
        job_id,
        skill_id,
        score
      },
      include: {
        position: {
          select: { id: true, name: true }
        },
        skills: {
          select: { id: true, name: true }
        }
      }
    });

    console.log(`✅ Added job skill: ${JSON.stringify(result, null, 2)}`);

    res.status(201).json({
      message: "Job skill added successfully",
      data: result
    });

  } catch (error) {
    console.error("Database error:", error);
    
    if (error.code === 'P2002') {
      res.status(409).json({ 
        error: "Job skill combination already exists" 
      });
    } else if (error.code === 'P2003') {
      res.status(400).json({ 
        error: "Foreign key constraint failed: Invalid job_id or skill_id" 
      });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`✅ Host: 0.0.0.0`);
  console.log(`✅ Database URL configured: ${!!process.env.DATABASE_URL}`);
  console.log(`✅ Environment: ${process.env.NODE_ENV || 'development'}`);
});