// #! /usr/bin/env node

// const Filestorage = require("@skalenetwork/filestorage.js");
// const fs = require("fs");
// const dotenv = require("dotenv");
// const { PRIVATE_KEY, ADDRESS } = require("../constants");


// dotenv.config();

// // If not using the SDK, replace the endpoint below with your SKALE Chain endpoint
// let filestorage = new Filestorage("https://eth-online.skalenodes.com/fs/hackathon-content-live-vega");

// let provider = new ethers.providers.JsonRpcProvider("https://eth-online.skalenodes.com/v1/hackathon-content-live-vega");

// // If not using the SDK, replace with the SKALE Chain owner key and address.
// let privateKey = process.env.PRIVATE_KEY || PRIVATE_KEY;
// let address = process.env.ADDRESS || ADDRESS;

// let directoryPath = "test-skale";

// // Bytes of filestorage space to allocate to an address
// // reservedSpace must be >= sum of uploaded files
// const reservedSpace = 3 * 10 ** 8;

// const files = fs.readdirSync(directoryPath);

// async function upload() {
//   // Owner must reserve space to an address
//   await filestorage.reserveSpace(address, address, reservedSpace, privateKey);
//   for (let i = 0; i < files.length; ++i) {
//     let content;
//     let contentPath;
//     content = await fs.readFileSync(directoryPath + "/" + files[i]);
//     contentPath = await filestorage.uploadFile(address, files[i], content, privateKey);
//     console.log(contentPath);
//   }
// }

// upload();
