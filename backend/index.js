import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import projectRoutes from "./routes/project.routes.js";
import usersRoutes from "./routes/user.routes.js";
import issuesRoutes from "./routes/issue.routes.js";
import commentRoutes from "./routes/comment.routes.js";
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "./swagger.js";

dotenv.config()

const app = express()
const PORT =  process.env.PORT || 8080;

app.use(cors())
app.use (express.json())

//Swagger 
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

//projcet
app.use('/api/projects', projectRoutes);

//User 
app.use('/api/users',  usersRoutes );

//Issues 
app.use('/api/issues',  issuesRoutes );

//Comments
app.use('/api/comments', commentRoutes);

app.get("/", (req, res) => {
  res.json({ message: "Jira Backend API running 🚀" });
   console.log("Jira Backend API running");
});


app.listen(PORT, () => {
  console.log(`⚡ Server is running on port ${PORT}`);
});