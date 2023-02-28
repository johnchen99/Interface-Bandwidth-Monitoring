//npm install express axios
//run on PM2

const express = require("express");
const axios = require("axios");
const fs = require("fs");
const path = require("path");
const port = 3000;
const app = express();
app.use(express.json());

const baseDirectory = "/root/icdn-bandwidth_interface"; // Replace with your desired base directory

// Endpoint to receive data from the client
app.post("/bandwidth_interface", async (req, res) => {
  try {
    console.log(`Received:`+ req);

    const { timestamp, devicename, ddns, txbytes } = req.body;  
    
    const new_timestamp = new Date;
    new_timestamp.setTime(parseInt(timestamp)*1000);
    // Get the year, month, and date from the date object
    const yearMonth = new_timestamp.toISOString().slice(0, 7);
    const yearMonthDate = new_timestamp.toISOString().slice(0, 10);
    // Create the directory if it doesn"t exist
    const deviceDirectory = path.join(baseDirectory, ddns+"_"+devicename, yearMonth);
    if (!fs.existsSync(deviceDirectory)) {
      fs.mkdirSync(deviceDirectory, { recursive: true });
    }

    // Generate the filename based on the timestamp
    const filename = yearMonthDate+"_tx.log";
    const filePath = path.join(deviceDirectory, filename);

    // Append the data to the file
    fs.appendFileSync(filePath, `${new_timestamp.toISOString().replace("T","_").slice(0, -5)} ${ddns} ${devicename} ${txbytes}\n`);
    
    res.sendStatus(200);
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}.`);
});
