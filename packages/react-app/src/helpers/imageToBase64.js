const imageToBase64 = require("image-to-base64");
const fs = require("fs");
imageToBase64("img/1kb.png")
  .then(data => {
    fs.writeFile("1kb_png.md", data, err => {
      console.log(err);
    });
  })
  .catch(err => console.log(err));
