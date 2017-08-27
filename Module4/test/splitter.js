var SplitterManager = artifacts.require("./SplitterManager.sol");

contract('SplitterManager', function(accounts) {
  let instance;
  let original_balance;

  it("splits even amount in two and stores $$", function() {
    return SplitterManager.deployed().then(function(_instance) {
      instance = _instance
      return instance.createSplitter(accounts[2],accounts[1],{from:accounts[0], value:10});
    }).then(function(txHash) {
    return instance.fundsOwed(accounts[2]);
  }).then(function(value){
      assert.equal(value, 5, "value did not get split properly");
    });
  });

   it("sends money to the collector", function() {
    return SplitterManager.deployed().then(function(_instance) {
      instance = _instance
      // console.log(instance.contract._eth.getBalance(accounts[0])) or web3.eth
      console.log(web3.eth.getBalance(instance.address).toString(10))
      return instance.createSplitter(accounts[2],accounts[1],{from:accounts[0], value:10});
    }).then(function(txHash) {
    // original_balance = instance.balance()
    return instance.withdrawFunds({from:accounts[2]});
  }).then(function(txHash){
     return instance.fundsOwed(accounts[2]);
  }).then(function(value){
      assert.equal(value, 0, "value was not withdrawn from account");
     // assert.equal(original_balance-5, instance.balance(), "value was not withdrawn from account");
    });
  });


  
 // it("should send coin correctly", function() {
//     var meta;

//     // Get initial balances of first and second account.
//     var account_one = accounts[0];
//     var account_two = accounts[1];

//     var account_one_starting_balance;
//     var account_two_starting_balance;
//     var account_one_ending_balance;
//     var account_two_ending_balance;

//     var amount = 10;

//     return MetaCoin.deployed().then(function(instance) {
//       meta = instance;
//       return meta.getBalance.call(account_one);
//     }).then(function(balance) {
//       account_one_starting_balance = balance.toNumber();
//       return meta.getBalance.call(account_two);
//     }).then(function(balance) {
//       account_two_starting_balance = balance.toNumber();
//       return meta.sendCoin(account_two, amount, {from: account_one});
//     }).then(function() {
//       return meta.getBalance.call(account_one);
//     }).then(function(balance) {
//       account_one_ending_balance = balance.toNumber();
//       return meta.getBalance.call(account_two);
//     }).then(function(balance) {
//       account_two_ending_balance = balance.toNumber();

//       assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
//       assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
//     });
  // });
});
