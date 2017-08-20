var DefaultBuilder = require("truffle-default-builder");

module.exports = {
    build: new DefaultBuilder({
    "index.html": "index.html",
    "app.js": "app.js"
 			 }), 
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
