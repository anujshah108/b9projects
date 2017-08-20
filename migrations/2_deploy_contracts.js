var RemittanceManager = artifacts.require("./RemittanceManager.sol");
var SplitterManager = artifacts.require("./SplitterManager.sol");
//var ConvertLib = artifacts.require("./ConvertLib.sol");
//var MetaCoin = artifacts.require("./MetaCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(RemittanceManager);
  deployer.deploy(SplitterManager);
  //deployer.deploy(ConvertLib);
  //deployer.link(ConvertLib, MetaCoin);
  //deployer.deploy(MetaCoin);
};
