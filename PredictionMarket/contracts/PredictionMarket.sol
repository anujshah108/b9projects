pragma solidity ^0.4.11;

contract PredictionMarket{

	struct Bet {
		address sender;
		bytes32 answer;
		uint amount;
		bool withdrawn;
	}

	struct Question {
		address sender;
		bool exists;
		bool answered;
		string question;
		bytes32 answer;
		uint ID;
		uint noAmount;
		uint yesAmount;

		mapping(address => Bet) bets;

	}

	mapping(address => bool) public Admins;
	mapping(address => bool) public TrustedSources;

	mapping(uint => Question) public Questions;

	uint public numOfQuestions;

	bytes32[] public questionIDs;

	event LogQuestionAddition(address sender, uint ID, string question, bool answered);
	event LogTrustedSourceAddition(address sender, address newTrustedSource);
	event LogBetAddition(address sender, uint ID, bytes32 questionAnswer, uint betAmount);
	event LogWithdrawingFunds(address sender, uint ID, uint withdrawAmount);
	event LogAnsweredQuestion(address sender, uint ID, bytes32 answer);

	function PredictionMarket(){
		Admins[msg.sender] = true;
	}

	modifier isAdmin {
        require(Admins[msg.sender]);
        _;
    }

    modifier isTrustedSource {
        require(TrustedSources[msg.sender]);
        _;
    }


	function addQuestion(string _question) 
		isAdmin
		returns(bool ok, uint questionID){

		questionID = numOfQuestions;

		require(Questions[numOfQuestions].exists == false);

		numOfQuestions++;

		 Questions[questionID] = Question({
		 	sender: msg.sender,
            question: _question,
            ID: questionID,
            exists: true,
            answered: false,
            answer: "",
            yesAmount:0,
            noAmount:0
 
        });

		LogQuestionAddition(msg.sender, questionID, _question, false);

		return (true, questionID);

	}

	//working on enums for "Yes" and "No"
	
	function addBet(uint _questionID, bytes32 _answer) 
		payable 
		returns (bool ok){

        require(msg.value > 0);

        Question storage question = Questions[_questionID];

        require(question.exists);
        require(!question.answered);
        require(_answer == "Yes" || _answer == "No");


       	if (_answer == 'Yes') {
        	question.yesAmount+=msg.value;
        }

        if (_answer == 'No') {
        	question.noAmount+=msg.value;
        }

        question.bets[msg.sender] = Bet({
            sender: msg.sender,
            answer: _answer,
            amount: msg.value,
            withdrawn: false
        });

        LogBetAddition(msg.sender, _questionID, _answer, msg.value);

        return true;
    }


	function withdrawWinnings(uint _questionID) 
		returns (bool){

	   	Question storage question = Questions[_questionID];

	   	require(question.exists);

	   	if(!question.answered){
	   		require(!question.bets[msg.sender].withdrawn);
	   		uint amount = question.bets[msg.sender].amount;
	   		question.bets[msg.sender].amount = 0;
	   		question.bets[msg.sender].withdrawn = true;
	   		msg.sender.transfer(amount);
	   		LogWithdrawingFunds(msg.sender, _questionID, amount);
	   		return true;
	   	}

		require(question.bets[msg.sender].answer == question.answer);
		require(question.bets[msg.sender].withdrawn == false);

		question.bets[msg.sender].withdrawn == true;

		// winnings for bets are calculated by the proportion of original bet to the total winning bets over the total of losing bets. 

		uint winningAmount = question.answer == "Yes" ? question.yesAmount : question.noAmount;
	   	uint losingAmount = question.answer == "Yes" ? question.noAmount : question.yesAmount;

	   	question.bets[msg.sender].amount += question.bets[msg.sender].amount/winningAmount * losingAmount;
	    amount = question.bets[msg.sender].amount;
	   	question.bets[msg.sender].amount = 0;
	   	msg.sender.transfer(amount);

	   	LogWithdrawingFunds(msg.sender, _questionID, amount);

	   	return true;
	   	

   	}

   	//want to add enums or true and false for answers instead of hard coded strings like "Yes" or "No"

   	function addAnswer(uint _questionID, bytes32 _answer) 
   		isTrustedSource 
   		returns(bool){

	   	require(_answer == "Yes" || _answer == 'No');

	   	Question storage question = Questions[_questionID];
	   	require(question.exists);
	   	require(!question.answered);

	   	question.answer = _answer;
	   	question.answered = true;

	   	LogAnsweredQuestion(msg.sender, _questionID, _answer);

	   	return true;

   	}

  	function getQuestionInfo(uint _questionID) 
  		constant 
  		returns(uint ID, bool answered, string questionText, uint userbetAmount){

  		Question storage question = Questions[_questionID];
  		require(question.exists);

  		return(question.ID, question.answered, question.question, question.bets[msg.sender].amount);

  	}

  	function addTrustedSource(address trustedSource)
  		isAdmin
  		returns(bool){

  		TrustedSources[trustedSource] = true;
  		LogTrustedSourceAddition(msg.sender, trustedSource);

  		return true;
 

  	}


}
