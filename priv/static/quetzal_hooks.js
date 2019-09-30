/*

Quetzal - Analytical web apps, beautiful, fast and easy using Elixir. No Javascript required.

Hooks used by Quetzal in order to accomplish live upgrades over components

*/

export class Quetzal {
  constructor() {}

  this.Hooks = {};

  Hooks.Graph = {
    updated() {
      eval('fn_' + this.el.getAttribute('id'))();
    }
  }
}
