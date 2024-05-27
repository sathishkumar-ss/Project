const pinataSDK = require('@pinata/sdk');
const fs = require('fs');

// Step 2: Install the Pinata SDK (already done)
// npm i --save @pinata/sdk

// Step 3: Authentication Setup
const apiKey = '1267748dcde38fce4cd0'; // Replace with your Pinata API Key
const apiSecret = '851e03d8e0daed92f46b8500e48a0c871b9bb61542ffa851581c1639cce2bb71'; // Replace with your Pinata Secret API Key

const pinata = pinataSDK(apiKey, apiSecret);


// Step 4: Pinning a File
const filePath = 'Poster.pdf'; // Replace with your file's path
const fileName = 'poster'; // Replace with your desired file name

// Create a readable stream
const readableStreamForFile = fs.createReadStream(filePath);

// Specify options for pinning
const options = {
  pinataMetadata: {
    name: fileName,
    keyvalues: {
      key_1: 'value_1',
      key_2: 'value_2'
    }
  },
  pinataOptions: {
    cidVersion: 0 // Replace with the desired CID version
  }
};

// Call the pinFileToIPFS API method
pinata.pinFileToIPFS(readableStreamForFile, options)
  .then((result) => {
    // Handle the results here
    console.log(result);
  })
  .catch((err) => {
    // Handle errors here
    console.error(err);
  });
