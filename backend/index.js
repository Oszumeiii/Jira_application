import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'

dotenv.config()

const app = express()
const PORT =  process.env.PORT || 8080;

app.use(cors())
app.use (express.json())
app.get("/", (req, res) => {
  res.json({ message: "Jira Backend API running 🚀" });
   console.log("Jira Backend API running");
});

app.listen(PORT, () => {
  console.log(`⚡ Server is running on port ${PORT}`);
});