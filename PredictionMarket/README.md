# Prediction Market Requirements

- An administrator, you can add a yes/no question.
- A regular user you can bet on an outcome of the question.
- A trusted source, you can resolve the question.
- A regular user, you can trigger the mutual-based payouts.




## Installation

1. Install truffle and EthereumJS TestRPC.
    ```javascript
    npm install -g truffle // Version 3.0.5+ required.
    npm install -g ethereumjs-testrpc
    ```

3. Compile and migrate the contracts.
    ```javascript
    truffle compile
    truffle migrate
    ```

4. Run the webpack server for front-end hot reloading. For now, smart contract changes must be manually recompiled and migrated.
    ```javascript
    npm run start
    ```

5. `accounts[0]` in TestRPC will automatically be assigned as an "Admin"

6. In the UI(Mist or MetaMask) or Truffle Console you can assign an address to be "Trusted Source" from an "Admin" account. 

7. You can add your TestRPC accounts to the "Private Network" in MetaMask and switch between "Admin".,"Trusted Source" or "Regular User" and the UI changes views for each of them. 

*Everytime you switch between MetaMask accounts you will have to reload the page for the app to get linked to your account. 



