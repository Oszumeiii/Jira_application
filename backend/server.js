const express = require('express');
const cors = require('cors');
require('dotenv').config();

const userRoutes = require('./src/routes/user.routes');
const friendRoutes = require('./src/routes/friend.routes');
const chatRoutes = require('./src/routes/chat.routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/users', userRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/chats', chatRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Chat API is running!' });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});