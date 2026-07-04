const express = require("express");

const router = express.Router();

router.get("/", (req, res) => {

    res.status(200).json({

        application: "Azure Container Demo",

        version: "1.0.0",

        environment: process.env.NODE_ENV || "development",

        message: "Application is running successfully."

    });

});

module.exports = router;