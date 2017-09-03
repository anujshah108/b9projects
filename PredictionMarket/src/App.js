import React, { Component } from 'react'
import PredictionContract from '../build/contracts/PredictionMarket.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

//todo add a way to null withdrawals of the wrong bet ("you bet wrong or something")

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      storageValue: 0,
      web3: null,
      instance:{},
      questions:[],
      accounts:[],
      questionToSubmit:"",
      trustedSourceAddress:"",
      betAmount:0,
      betAnswer:"",
      isAdmin: false,
      isTrustedSource:false

    }
    this.addAQuestion = this.addAQuestion.bind(this);
    this.answerQuestion = this.answerQuestion.bind(this);
    this.addABet = this.addABet.bind(this);
    this.withdrawWinnings = this.withdrawWinnings.bind(this);
    this.addATrustedSource = this.addATrustedSource.bind(this);
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {

    const contract = require('truffle-contract')
    const PredictionInstance = contract(PredictionContract)
    PredictionInstance.setProvider(this.state.web3.currentProvider)

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {
      return PredictionInstance.deployed()
            .then((instance) => {
               this.setState({instance:instance, accounts:accounts})
                let numQ;
                instance.numOfQuestions()
                .then(num => {
                   numQ = num.c[0]
                   for(let i=0;i<numQ;i++){
                     instance.getQuestionInfo(i)
                    .then(info => {
                      this.state.questions.push({
                        ID:info[0], 
                        answered:info[1],
                        question:info[2],
                        amount:info[3].c[0]
                      })
                      })
                      .catch(err => console.log("No ID"))
             }})
            .then(isAdmin => instance.Admins(accounts[0]))
            .then(bool => this.setState({isAdmin:bool}))
            .then(isTS => instance.TrustedSources(accounts[0]))
            .then(bool => this.setState({isTrustedSource:bool}))
            
      })
    })
  }

  addAQuestion(event){
    event.preventDefault();
    return this.state.instance.addQuestion(this.state.questionToSubmit, {from:this.state.accounts[0]})
            .then(tx => {
              console.log(tx.logs[0].args)
              tx.logs[0].args.amount = 0
              this.state.questions.push(tx.logs[0].args)
              this.setState({questionToSubmit:""})
            })
  }

  addABet(id){
    return this.state.instance.addBet(id, this.state.betAnswer, {from:this.state.accounts[0], value:this.state.betAmount})
            .then(tx => {
              console.log(tx.logs[0].args)
              this.setState({betAnswer:""})
              this.state.questions[id].amount = this.state.betAmount
              this.setState({betAmout:0})
            })

  }

  answerQuestion(id){
     return this.state.instance.addAnswer(id, this.state.answer, {from:this.state.accounts[0]})
            .then(tx => {
              console.log(tx.logs[0].args)
              this.state.questions[id].answered = true
              this.setState({answer:""})
            })
  }


  withdrawWinnings(id){
    return this.state.instance.withdrawWinnings(id, {from:this.state.accounts[0]})
            .then(tx => {
              console.log(tx.logs[0].args)
            })

  }

  addATrustedSource(event){
    event.preventDefault();
    return this.state.instance.addTrustedSource(this.state.trustedSourceAddress, {from:this.state.accounts[0]})
            .then(tx => {
              console.log(tx.logs[0].args)
            })

  }




  render() {

    let adminScene = this.state.isAdmin ? (  <div><h3>Add A Question </h3>
              <form onSubmit={this.addAQuestion}>            
              <input value={this.state.questionToSubmit} onChange={e => this.setState({ questionToSubmit: e.target.value })}/>
              <button type="submit"> SUBMIT </button>
              </form>
              <br/>
              <h3>Add A Trusted Source </h3>
              <form onSubmit={this.addATrustedSource}>
              <input value={this.state.trustedSourceAddress} onChange={e => this.setState({ trustedSourceAddress: e.target.value })}/>
              <button type="submit"> SUBMIT </button>
              </form> 
              </div>) : (<div> Place a Bet Below </div>) 


    const arrOfQuestions = this.state.questions.map(question => {
            
            return(
                <tr className="collection " key={question.ID}>
                      <td>{question.ID.c[0]}</td>
                      <td>{question.question}</td>
                         <td>{question.answered ? "Answered - No More Bets" : (question.amount < 1 ? <form onSubmit={(e) => {
                                                                                          e.preventDefault()
                                                                                          this.addABet(question.ID.c[0])
                                                                                          }}>
                                                                                    <input placeholder="Amount" onChange={e => this.setState({ betAmount: e.target.value })}/>
                                                                                    <input placeholder="Yes or No" onChange={e => this.setState({ betAnswer: e.target.value })}/>
                                                                                    <button type="submit">Bet</button>
                                                                              </form> : <div> Bet Already Placed </div>)}
                        </td>
                      <td>{question.answered ? "Answered" : (this.state.isTrustedSource ? ( <div><form onSubmit={(e) => {
                                                                                    e.preventDefault()
                                                                                    this.answerQuestion(question.ID.c[0])
                                                                                                                      }}>
                                                                                                              <input placeholder="Yes or No" onChange={e => this.setState({ answer: e.target.value })}/>
                                                                                                              <button>Answer</button>
                                                                                                </form>
                                                                                            </div>) : (<div> Not Answered Yet/Not Trusted Source </div> ))}
                      </td>
                      <td>{question.amount > 0 ? <form onSubmit={(e) => {
                                                  this.withdrawWinnings(question.ID.c[0])}}>
                                                  <button>Withdraw</button>
                                                  </form> : <div> Nothing To Withdraw </div>}
                      </td>
                </tr>
            )
          })

    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Prediction Market</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>Welcome to The Prediction Market!</h1>
              <p>Anybody can place a bet! You can add a question if you an admin or answer if you are a trusted source!</p>
              <h5>Contract Address: {this.state.instance.address}</h5>
              <h5>Your Address: {this.state.accounts[0]}</h5>
              <br/> 
              {adminScene}
              <br/>
              <br/>
              <table width="90%" className="table-bordered">
                    <thead>
                      <tr>
                          <th data-field="id">Question ID</th>
                          <th data-field="text">Question</th>
                          <th data-field="bet">Place Bet</th>
                          <th data-field="answer">Answer Of Question</th>
                          <th data-field="withdraw">Withdraw</th>
                      </tr>
                    </thead>
                     <tbody>
                      {arrOfQuestions}
                  </tbody>
                </table>
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App
