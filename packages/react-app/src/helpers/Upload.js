import { player } from "../image";
import { PRIVATE_KEY, ADDRESS } from "../constants";
import { useState } from "react";
const Filestorage = require("@skalenetwork/filestorage.js");
const Web3 = require("web3");

export async function Upload(e) {
  e.preventDefault();
  const web3Provider = new Web3.providers.HttpProvider(
    "https://eth-online.skalenodes.com/v1/hackathon-content-live-vega",
  );

  let web3 = new Web3(web3Provider);
  let filestorage = new Filestorage(web3, true);
  let privateKey = PRIVATE_KEY;
  let account = ADDRESS;
  let file = document.getElementById("files").files[0];
  let reader = new FileReader();
  //file storage method to upload file
  reader.onload = async function (e) {
    const arrayBuffer = reader.result;
    const bytes = new Uint8Array(arrayBuffer);
    let link = filestorage.uploadFile(account, file.name, bytes, privateKey);
  };
  reader.readAsArrayBuffer(file);
}
