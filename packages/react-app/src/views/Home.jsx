import { Container, Heading } from "@chakra-ui/react";
import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import { InputHandler, Player } from "../components";
import React from "react";
import { player } from "../image";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({ yourLocalBalance, readContracts }) {
  // you can also use hooks locally in your component of choice
  window.addEventListener("load", function () {
    const loading = this.document.getElementById("loading");
    loading.style.display = "none";
    const canvas = document.getElementById("canvas1");
    const ctx = canvas.getContext("2d");
    canvas.width = window.innerWidth - 10;
    canvas.height = 400;

    class Game {
      constructor(width, height) {
        this.width = width;
        this.height = height;
        this.player = new Player(this);
        this.input = new InputHandler();
      }
      update() {
        this.player.update(this.input.key);
      }
      draw(context) {
        this.player.draw(context);
      }
    }

    const game = new Game(canvas.width, canvas.height);

    let lastTime = 0;
    function animate(timeStamp) {
      const deltaTime = timeStamp - lastTime;
      lastTime = timeStamp;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      game.update();
      game.draw(ctx);
      requestAnimationFrame(animate);
    }
    animate(0);
  });

  return (
    <Container w={"100%"} h={"full"} m={0} p={0} align={"center"}>
      <canvas
        id="canvas1"
        style={{
          border: "5px solid black",
          margin: 0,
          padding: 0,
        }}
      ></canvas>
      <img style={{ display: "none" }} id="player" alt="player" src={player}></img>
    </Container>
  );
}

export default Home;
