/*

Quetzal - Analytical web apps, beautiful, fast, easy and real-time using Elixir. No Javascript required.

Hooks used by Quetzal in order to accomplish live upgrades over components

*/
export class Quetzal {
  constructor() {
    this.Hooks = {};
    this.Hooks.Graph = {
      updated() {
        eval('fn_' + this.el.getAttribute('id'))();
      }
    }
  }
}

export default Quetzal;
