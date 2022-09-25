export class UI {
  constructor(game) {
    this.game = game;
    this.fontSize = 50;
    this.fontFamily = "Helvetica";
  }
  draw(context) {
    context.font = this.fontSize + "px " + this.fontFamily;
    this.textAlign = "left";
    context.fillStyle = this.game.fontColor;
    context.fillText("Score: " + this.game.score, 20, 50);
  }
}
