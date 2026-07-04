const express = require("express");

const app = express();

const PORT = process.env.PORT || 80;
const HOST = "0.0.0.0";

app.get("/", (req, res) => {
    res.send("Hello from Azure Container Instance 🚀");
});

app.listen(PORT, HOST, () => {
    console.log(`Server running on http://${HOST}:${PORT}`);
});