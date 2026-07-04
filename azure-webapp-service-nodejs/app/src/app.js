const express = require("express");

const homeRoute = require("./routes/home");
const healthRoute = require("./routes/health");

const app = express();

app.use(express.json());

app.use("/", homeRoute);
app.use("/health", healthRoute);

module.exports = app;