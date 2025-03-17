// Entry point for the build script in your package.json
import '@hotwired/turbo-rails';
import './controllers';

const cors = require('cors');
const express = require('express');
const app = express();

// CORSを有効にする
app.use(cors());

const port = 3000;
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
