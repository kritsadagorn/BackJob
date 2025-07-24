// Load environment variables first
require("dotenv").config()

const express = require("express")
const { PrismaClient } = require("@prisma/client")
const cors = require("cors")

const app = express()
const prisma = new PrismaClient()

app.use(cors())
app.use(express.json())

// Add a health check endpoint to verify environment
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    database_configured: !!process.env.DATABASE_URL,
  })
})

// Add this right after your /health endpoint
app.get("/", (req, res) => {
  res.json({
    message: "BackJob API is running!",
    timestamp: new Date().toISOString(),
    port: process.env.PORT || 5000,
  })
})

/**
 * [GET] /api/jobs (Query all jobs) ✅
 * [GET] /api/jobs/:positionId (Query info job by position ID and language) ✅
 * [GET] /api/query/position (Get all position [FOR SEARCH]) ✅
 * [GET] /api/query/position-group (Get all position group) ✅
 *
 */

// ✅ ดึงตำแหน่งงานทั้งหมด
app.get("/api/jobs", async (req, res) => {
  let {
    page = 0,
    size = 13,
    sortTrending = "asc",
    groupOfPos = "",
    search = "",
    language = "en", // Default to English
  } = req.query

  if (size >= 100) size = 100
  console.log(`Trending: ${sortTrending} | Group pos IDS: ${groupOfPos} | Language: ${language}`)

  // Transform data group
  const groupIds = groupOfPos
    .split(",")
    .map((i) => Number(i))
    .filter((i) => i > 0)

  const queryBase = {
    language: language, // Filter by language
    ...(groupIds.length > 0
      ? {
          position: {
            group_id: {
              in: groupIds,
            },
          },
        }
      : {}),
  }

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
  }

  try {
    const jobs = await prisma.position_details.findMany({
      skip: page * size,
      take: Number(size),
      where: whereQuery,
      orderBy: {
        trending: {
          level: sortTrending,
        },
      },
      select: {
        id: true,
        position_id: true,
        language: true,
        description: true,
        responsibilities: true,
        created_at: true,
        updated_at: true,
        trending: {
          select: {
            id: true,
            name: true,
            level: true,
          },
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
    })

    console.log(`Found ${jobs.length} jobs for language: ${language}`)

    // Get total job query
    const totalData = await prisma.position_details.count({
      where: whereQuery,
    })

    res.json({
      items: jobs,
      pagination: {
        total: totalData,
        pageTotal: Math.ceil(totalData / size),
      },
    })
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

// ✅ ดึงข้อมูลตำแหน่งงานเฉพาะ Position ID และภาษา
app.get("/api/jobs/:positionId", async (req, res) => {
  const { positionId } = req.params
  const { lang = "en" } = req.query // Default to English

  console.log(`Fetching position ${positionId} in language: ${lang}`)

  try {
    // First, try to get the position details in the requested language
    let positionDetails = await prisma.position_details.findFirst({
      where: {
        position_id: Number.parseInt(positionId),
        language: lang,
      },
      select: {
        id: true,
        position_id: true,
        language: true,
        description: true,
        responsibilities: true,
        created_at: true,
        updated_at: true,
        trending: {
          select: {
            id: true,
            name: true,
            level: true,
          },
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
    })

    // If not found in requested language, fallback to English
    if (!positionDetails && lang !== "en") {
      console.log(`Position ${positionId} not found in ${lang}, falling back to English`)
      positionDetails = await prisma.position_details.findFirst({
        where: {
          position_id: Number.parseInt(positionId),
          language: "en",
        },
        select: {
          id: true,
          position_id: true,
          language: true,
          description: true,
          responsibilities: true,
          created_at: true,
          updated_at: true,
          trending: {
            select: {
              id: true,
              name: true,
              level: true,
            },
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
      })
    }

    if (!positionDetails) {
      return res.status(404).json({
        message: "Position not found",
        positionId: positionId,
        requestedLanguage: lang,
      })
    }

    console.log(`Found position details in language: ${positionDetails.language}`)
    res.json(positionDetails)
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

// Get available languages for a specific position
app.get("/api/positions/:positionId/languages", async (req, res) => {
  const { positionId } = req.params

  try {
    const languages = await prisma.position_details.findMany({
      where: { position_id: Number.parseInt(positionId) },
      select: { language: true },
      distinct: ["language"],
    })

    res.json(languages.map((l) => l.language))
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

// Get all available languages in the system
app.get("/api/languages", async (req, res) => {
  try {
    const languages = await prisma.position_details.findMany({
      select: { language: true },
      distinct: ["language"],
    })

    res.json(languages.map((l) => l.language))
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

app.get("/api/query/position", async (req, res) => {
  try {
    const result = await prisma.position.findMany({
      select: { id: true, name: true },
    })
    res.json(result)
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

app.get("/api/query/position-group", async (req, res) => {
  try {
    const result = await prisma.position_group.findMany({
      select: { id: true, name: true },
    })
    res.json(result)
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

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
    })
    const transformed = result.map((item) => ({
      skill: item.skills?.name ?? "Unknown",
      score: item.score,
    }))

    res.json(transformed)
  } catch (error) {
    console.error("Database error:", error)
    res.status(500).json({ error: error.message })
  }
})

const PORT = process.env.PORT || 5000

app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server running on port ${PORT}`)
  console.log(`✅ Host: 0.0.0.0`)
  console.log(`✅ Database URL configured: ${!!process.env.DATABASE_URL}`)
  console.log(`✅ Environment: ${process.env.NODE_ENV || "development"}`)
})
