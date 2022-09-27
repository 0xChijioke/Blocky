import { Container, Heading } from "@chakra-ui/react";
import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import { InputHandler, Player, Background, FlyingEnemy, GroundEnemy, ClimbingEnemy, UI } from "../components/";
import React from "react";
import {
  boom,
  enemy_fly,
  enemy_plant,
  enemy_spider_big,
  fire,
  layer1,
  layer2,
  layer3,
  layer4,
  layer5,
  lives,
  player,
} from "../image";

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
    canvas.width = window.innerWidth - 60;
    canvas.height = 500;

    class Game {
      constructor(width, height) {
        this.width = width;
        this.height = height;
        this.groundMargin = 80;
        this.speed = 0;
        this.maxSpeed = 3;
        this.background = new Background(this);
        this.player = new Player(this);
        this.input = new InputHandler(this);
        this.UI = new UI(this);
        this.enemies = [];
        this.particles = [];
        this.collisions = [];
        this.floatingMessages = [];
        this.maxParticles = 50;
        this.enemyTimer = 0;
        this.enemyInterval = 1000;
        this.debug = false;
        this.score = 0;
        this.fontColor = "black";
        this.time = 0;
        this.maxTime = 120000;
        this.gameOver = false;
        this.lives = 5;
        this.player.currentState = this.player.states[0];
        this.player.currentState.enter();
      }
      update(deltaTime) {
        this.time += deltaTime;
        if (this.time > this.maxTime) this.gameOver = true;
        this.background.update();
        this.player.update(this.input.key, deltaTime);
        // handle enemies
        if (this.enemyTimer > this.enemyInterval) {
          this.addEnemy();
          this.enemyTimer = 0;
        } else {
          this.enemyTimer += deltaTime;
        }
        this.enemies.forEach(enemy => {
          enemy.update(deltaTime);
        });
        // handle message
        this.floatingMessages.forEach(message => {
          message.update();
        });
        // handle particles
        this.particles.forEach((particle, index) => {
          particle.update();
        });
        if (this.particles.length > this.maxParticles) {
          this.particles.length = this.maxParticles;
        }
        // handle collision sprites
        this.collisions.forEach((collision, index) => {
          collision.update(deltaTime);
        });
        this.collisions = this.collisions.filter(collision => !collision.markedForDeletion);
        this.particles = this.particles.filter(particle => !particle.markedForDeletion);
        this.enemies = this.enemies.filter(enemy => !enemy.markedForDeletion);
        this.floatingMessages = this.floatingMessages.filter(message => !message.markedForDeletion);
      }
      draw(context) {
        this.background.draw(context);
        this.player.draw(context);
        this.enemies.forEach(enemy => {
          enemy.draw(context);
        });
        this.particles.forEach(particles => {
          particles.draw(context);
        })
        this.collisions.forEach(collision => {
          collision.draw(context);
        })
        this.floatingMessages.forEach(message => {
          message.draw(context);
        });
        this.UI.draw(context);
      }
      addEnemy() {
        if (this.speed > 0 && Math.random() < 0.5) this.enemies.push(new GroundEnemy(this));
        else if (this.speed < 0) this.enemies.push(new ClimbingEnemy(this));
        this.enemies.push(new FlyingEnemy(this));
      }
    }

    const game = new Game(canvas.width, canvas.height);

    let lastTime = 0;
    function animate(timeStamp) {
      const deltaTime = timeStamp - lastTime;
      lastTime = timeStamp;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      game.update(deltaTime);
      game.draw(ctx);
      if (!game.gameOver) requestAnimationFrame(animate);
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
          fontFamily: "'Caveat', cursive",
        }}
      ></canvas>
      <img style={{ display: "none" }} id="player" alt="player" src={player}></img>
      <img style={{ display: "none" }} id="layer1" alt="layer1" src={layer1}></img>
      <img style={{ display: "none" }} id="layer2" alt="layer2" src={layer2}></img>
      <img style={{ display: "none" }} id="layer3" alt="layer3" src={layer3}></img>
      <img style={{ display: "none" }} id="layer4" alt="layer4" src={layer4}></img>
      <img style={{ display: "none" }} id="layer5" alt="layer5" src={layer5}></img>
      <img style={{ display: "none" }} id="enemy_fly" alt="enemy_fly" src={enemy_fly}></img>
      <img style={{ display: "none" }} id="enemy_plant" alt="enemy_plant" src={enemy_plant}></img>
      <img style={{ display: "none" }} id="enemy_spider_big" alt="layer5" src={enemy_spider_big}></img>
      <img style={{ display: "none" }} id="fire" alt="fire" src={fire}></img>
      <img style={{ display: "none" }} id="boom" alt="boom" src={boom}></img>
      <img style={{ display: "none" }} id="lives" alt="lives" src={lives}></img>
    </Container>
  );
}

export default Home;
