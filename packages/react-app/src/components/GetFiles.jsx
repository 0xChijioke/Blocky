var ethers = require("ethers");
const Filestorage = require("@skalenetwork/filestorage.js");
const { ADDRESS } = require("../constants");

export async function getFiles(storagePath) {
  //create web3 connection
  const provider = new ethers.providers.JsonRpcProvider(
    "https://eth-online.skalenodes.com/v1/hackathon-content-live-vega",
  );


  //get filestorage instance
  let filestorage = new Filestorage(provider, true);

  //provide your account & private key
  let account = ADDRESS;

  let files = await filestorage.listDirectory(storagePath);

  return files;
}
