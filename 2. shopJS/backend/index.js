const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors()); // CORS config
app.use(express.json());

app.use('/api/products', require('./routes/products'));
app.use('/api/categories', require('./routes/categories'));
app.use('/api/transactions', require('./routes/transactions'));


const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
