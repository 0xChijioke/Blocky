export class InputHandler {
  constructor() {
    this.key = [];
    window.addEventListener("keydown", e => {
      console.log(e.key);
      if (
        (e.key === "ArrowDown" ||
          e.key === "ArrowUp" ||
          e.key === "ArrowLeft" ||
          e.key === "ArrowRight" ||
          e.key === "Enter") &&
        this.key.indexOf(e.key) === -1
      ) {
        this.key.push(e.key);
      }
    });
    window.addEventListener("keyup", e => {
      if (
        e.key === "ArrowDown" ||
        e.key === "ArrowUp" ||
        e.key === "ArrowLeft" ||
        e.key === "ArrowRight" ||
        e.key === "Enter"
      ) {
        this.key.splice(this.key.indexOf(e.key), 1);
      }
    });
  }
}
