pragma solidity ^0.4.11;


contract Owned {

    address owner;

    function Owned() {
        owner = msg.sender;
    }

}

contract RemittanceManager is Owned {

	struct Remittance {
		address sender;
		uint amount;
		uint deadline;
	}


	mapping (bytes32 => Remittance) pendingRemittances;

	event LogNewRemittance(address sender, uint amount, uint blockTime, bytes32 password);
	event LogCollectedRemittance(address collector, uint amount, bytes32 password, uint blockNumber);
	event LogExpiredRemittance(address sender, bytes32 password, uint blockNumber);

	// sender of the remittance does hash of codeA, codeB beforehand - perhaps on frontend
	function newRemittance(bytes32 password, uint timeValid) payable returns (bool) {
		
		//require(!pendingRemittances[password]) do a check if they exist already (need to see if this will work)

		//cost to deploy is 506231 wei, therefore we will charge 506230

		uint _amount = msg.value - 506230

		pendingRemittances[password] = Remittance({

			sender: msg.sender,
			amount: _amount,
			deadline: block.number + timeValid

			});

		LogNewRemittance(msg.sender,_amount,timeValid,password);
		return (true);

	}

	//thinking of adding a way to hash codes on front end so they are not sent to blockchain but then would need to still verify sender
	function collectRemittance(bytes32 codeA, bytes32 codeB) returns(bool){
		bytes32 password = keccak256(codeA, codeB);

		//require(!pendingRemittances[password]); again check if this is possible or needed

		Remittance storage currentRemittance = pendingRemittances[password];

		require(currentRemittance.deadline > block.number);

		uint amount = currentRemittance.amount;
		delete currentRemittance.amount;

		msg.sender.transfer(amount);

		LogCollectedRemittance(msg.sender, amount, password, block.number);
		return (true);
	}

	function returnExpiredRemittance(bytes32 password) returns (bool){
		Remittance storage currentRemittance = pendingRemittances[password];

		require(currentRemittance.deadline <= block.number);
		require(msg.sender == currentRemittance.sender);

		uint amount = currentRemittance.amount;
		delete currentRemittance.amount;

		currentRemittance.sender.transfer(amount);

		LogExpiredRemittance(currentRemittance.sender, password, block.number);
		return (true);
	}

	function killSwitch() returns (bool) {
        if (msg.sender == owner) {
           selfdestruct(owner);
            return true;
        }
    }

}

