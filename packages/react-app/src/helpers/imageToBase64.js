#! /usr/bin/env node
const imageToBase64 = require("image-to-base64");
const fs = require("fs");
imageToBase64("../assets/player.png")
  .then(data => {
    fs.writeFile("player_png.md", data, err => {
      console.log(data);
      console.log(err);
    });
  })
  .catch(err => console.log(err));
