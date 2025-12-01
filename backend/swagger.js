import swaggerJSDoc from "swagger-jsdoc";

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Project API",
      version: "1.0.0",
      description: "API documentation for Node.js + Firebase + Project Management App",
    },

    components: {
      securitySchemes: {
        BearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },

      schemas: {
        Project: {
          type: "object",
          properties: {
            id: { type: "string", example: "p12345" },
            name: { type: "string", example: "Study Manager" },
            priority: {
              type: "string",
              enum: ["Low", "Medium", "High"],
              example: "Medium",
            },
            projectType: { type: "string", example: "Software" },
            sumary: { type: "string", example: "Short summary..." },
            description: {
              type: "string",
              example: "This is a project description.",
            },
            ownerId: { type: "string", example: "user123" },
            members: {
              type: "array",
              items: { type: "string" },
              example: ["user123", "user456"],
            },
            status: {
              type: "string",
              enum: ["active", "archived", "deleted"],
              example: "active",
            },
            createdAt: {
              type: "string",
              format: "date-time",
              example: "2025-01-01T12:00:00Z",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
              example: "2025-01-10T15:30:00Z",
            },
          },
        },


        Comment: {
          type: "object",
          properties: {
            id: {
              type: "string",
              example: "cmt98765",
            },
            taskId: {
              type: "string",
              example: "task123",
              description: "ID của task mà comment thuộc về",
            },
            userId: {
              type: "string",
              example: "user456",
              description: "Người tạo comment",
            },
            content: {
              type: "string",
              example: "This feature looks good, please proceed!",
            },
            userName: {
              type: "string",
              example: "Nguyễn Hoàng Long",
              description: "Tên người bình luận",
            },
            userAvatar: {
              type: "string",
              example: "https://example.com/avatar.png",
              description: "Avatar của user",
            },
            createdAt: {
              type: "string",
              format: "date-time",
              example: "2025-01-01T12:00:00Z",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
              example: "2025-01-01T13:00:00Z",
            },
          },
        },    
        
        
        Issue: {
          type: "object",
          properties: {
            id: {
              type: "string",
              example: "issue_abc123"
            },
            projectId: {
              type: "string",
              example: "project_001"
            },
            title: {
              type: "string",
              example: "Fix login bug"
            },
            summary: {
              type: "string",
              example: "Login fails when using Google OAuth"
            },
            description: {
              type: "string",
              example: "Detailed explanation of the bug..."
            },
            type: {
              type: "string",
              enum: ["task", "bug", "story"],
              example: "task"
            },
            priority: {
              type: "string",
              enum: ["Low", "Medium", "High"],
              example: "High"
            },
            status: {
              type: "string",
              enum: ["todo", "in-progress", "review", "done"],
              example: "in-progress"
            },
            assigneeId: {
              type: "string",
              nullable: true,
              example: "user123"
            },
            reporterId: {
              type: "string",
              example: "user456"
            },
            parentId: {
              type: "string",
              nullable: true,
              example: null
            },
            subTasks: {
              type: "array",
              items: { type: "string" },
              example: ["issue_sub_001", "issue_sub_002"]
            },
            createdAt: {
              type: "string",
              format: "date-time",
              example: "2025-01-01T12:00:00Z"
            },
            updatedAt: {
              type: "string",
              format: "date-time",
              example: "2025-01-02T14:30:00Z"
            }
          }
        },        

        ApiResponse: {
          type: "object",
          properties: {
            status: { type: "string", example: "success" },
            message: { type: "string", example: "Thành công" },
            data: { type: "object" },
          },
        },
      },
      




      
    },
  },

  // Nơi swagger tìm @swagger comment
  apis: [
    "./controllers/*.js",
    "./routes/*.js",
  ],
};

export const swaggerSpec = swaggerJSDoc(options);
