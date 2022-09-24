import { Player } from "../image";
import { PRIVATE_KEY, ADDRESS } from "../constants";
const Filestorage = require("@skalenetwork/filestorage.js");

// Directly with http(s)/ws(s) endpoints
let filestorage = new Filestorage("https://eth-online.skalenodes.com/fs/hackathon-content-live-vega");

//JavaScript function for handling the file upload
export async function Upload(specificDirectory = "") {
  //provide your account & private key
  //note this must include the 0x prefix
  let privateKey = PRIVATE_KEY;
  let account = ADDRESS;

  //get file data from file upload input field
  let file = Player;
  let reader = new FileReader();

  //file path in account tree (dirA/file.name)
  let filePath;
  if (specificDirectory === "") {
    filePath = file.name;
  } else {
    filePath = specificDirectory + "/" + file.name;
  }

  //file storage method to upload file
  reader.onload = async function (e) {
    const arrayBuffer = reader.result;
    const bytes = new Uint8Array(arrayBuffer);
    let link = filestorage.uploadFile(account, filePath, bytes, privateKey);
    console.log(link);
    console.log(Player);
  };
  reader.readAsArrayBuffer(file);
  console.log(reader.readAsArrayBuffer(file))
}
