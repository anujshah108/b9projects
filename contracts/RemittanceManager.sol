pragma solidity ^0.4.6;


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

	// sender of the remittance does hash of codeA, codeB and collector address beforehand
	function newRemittance(bytes32 password, uint timeValid) payable returns (bool) {
		pendingRemittances[password] = Remittance({

			sender: msg.sender,
			amount: msg.value,
			deadline: block.number + timeValid

			});

		LogNewRemittance(msg.sender,msg.value,timeValid,password);
		return (true);

	}

	//thinking of adding a way to hash codes on front end so they are not sent to blockchain but then would need to still verify sender
	function collectRemittance(bytes32 codeA, bytes32 codeB) returns(bool){
		bytes32 password = keccak256(codeA, codeB, msg.sender);
		Remittance storage currentRemittance = pendingRemittances[password];

		require(currentRemittance.deadline > block.number);

		uint amount = currentRemittance.amount;
		currentRemittance.amount = 0;

		msg.sender.transfer(amount);

		LogCollectedRemittance(msg.sender, amount, password, block.number);
		return (true);
	}

	function returnExpiredRemittance(bytes32 password) returns (bool){
		Remittance storage currentRemittance = pendingRemittances[password];

		require(currentRemittance.deadline <= block.number);
		require(msg.sender == currentRemittance.sender);

		uint amount = currentRemittance.amount;
		currentRemittance.amount = 0;

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

