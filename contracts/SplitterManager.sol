pragma solidity ^0.4.11;


contract Owned {

    address owner;

    function Owned() {
        owner = msg.sender;
    }

}


contract SplitterManager is Owned {

	mapping(address => uint) public fundsOwed;

	event LogCreatingSplitter(address sender, address receiverOne, address receiverTwo, uint amountForOne, uint amountForTwo);
	event LogWithdrawingFunds(address receiver, uint amount);

	function createSplitter(address receiver1, address receiver2) payable returns (bool){

        require(msg.value > 0);
        require(receiver1 != 0);
        require(receiver2 != 0);

        uint amountFor1 = msg.value / 2;
        uint amountFor2 = amountFor1;

        // takes care of odd division by adding 1 to amountFor1
        if (msg.value % 2 == 1) amountFor1++; 

        fundsOwed[receiver1] += amountFor1;
        fundsOwed[receiver2] += amountFor2;

        LogCreatingSplitter(msg.sender, receiver1, receiver2, amountFor1, amountFor2);

        return(true);
    }


    function withdrawFunds() returns (bool){

        require(fundsOwed[msg.sender] > 0);

        uint amount = fundsOwed[msg.sender];
        delete fundsOwed[msg.sender];

        msg.sender.transfer(amount);

        LogWithdrawingFunds(msg.sender, amount);

        return(true);

    }

    function killSwitch() returns (bool) {
        if (msg.sender == owner) {
           selfdestruct(owner);
            return true;
        }
    }

}