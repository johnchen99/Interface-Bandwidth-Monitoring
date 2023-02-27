//run on PM2

const express = require('express');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

const baseDirectory = "/root/icdn-bandwidth_interface"; // Replace with your desired base directory

// Endpoint to receive data from the client
app.post('/bandwidth_interface', async (req, res) => {
  try {
    const { timestamp, devicename, ddns, txbytes } = req.body; // Assuming your client sends these two fields in the request body
    
    //console.log(`Received ${txbytes} bytes from ${devicename}.`);
    
    // Create the directory if it doesn't exist
    const deviceDirectory = path.join(baseDirectory, devicename, timestamp.substring(0, 7));
    if (!fs.existsSync(deviceDirectory)) {
      fs.mkdirSync(deviceDirectory, { recursive: true });
    }

    // Generate the filename based on the timestamp
    const filename = `${timestamp.substring(0, 10)}_tx.log`;
    const filePath = path.join(deviceDirectory, filename);

    // Append the data to the file
    fs.appendFileSync(filePath, `${timestamp} ${txbytes}\n`);
    
    res.sendStatus(200);
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}.`);
});
