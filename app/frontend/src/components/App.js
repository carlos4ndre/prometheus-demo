import React, { Component } from "react"
import Poll from "./Poll"
import Settings from "../settings"


export default class App extends Component {

  constructor(props) {
    super(props)
    this.state = {
      poll: {
        topic: "power-rangers",
        question: "Who's your favourite power ranger?",
        options: [
          {name: "red", image: "./images/red.jpg", total_votes: 0},
          {name: "blue", image: "./images/blue.jpg", total_votes: 0},
          {name: "black", image: "./images/black.jpg", total_votes: 0},
          {name: "green", image: "./images/green.jpg", total_votes: 0},
          {name: "yellow", image: "./images/yellow.jpg", total_votes: 0},
          {name: "pink", image: "./images/pink.jpg", total_votes: 0}
        ]
      }
    }
  }

  handleClick = (option) => {
    let topicName = this.state.poll.topic
    let optionName = option.name

    this.vote(topicName, optionName)
  }

  vote(topicName, optionName) {
    // prepare data
    let url = `${Settings.RATING_API_BASE_URL}/${topicName}`
    let data = {"option": optionName}

    // vote on topic
    fetch(url, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data)
    }).then(response => {
        // update local state to avoid any delays
        let poll = this.state.poll
        let option_idx = poll.options.findIndex(obj => obj.name === optionName)
        poll.options[option_idx].total_votes++
        this.setState({poll})
      })
      .catch(error => console.error("Error: ", error))
  }

  refreshVotesCounter(topicName) {
    // prepare data
    let url = `${Settings.RATING_API_BASE_URL}/${topicName}`

    // get latest vote updates
    fetch(url, {
      method: "GET",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      }
    }).then(response => response.json())
      .then(response => {
        // update votes based on response
        let options = this.state.poll.options
        let votes = response.votes

        for(let option in votes) {
          let option_idx = options.findIndex(obj => obj.name === option)
          options[option_idx].total_votes = votes[option]
        }

        // propagate changes to rates
        this.setState({
          poll: {
            ...this.state.poll,
            options
          }
        })
      })
      .catch(error => console.error("Error: ", error))
  }

  componentDidMount() {
    let topicName = this.state.poll.topic

    this.refreshVotesCounter(topicName)
    this.timer = setInterval(() => this.refreshVotesCounter(topicName), 5000)
  }

  componentWillUnmount() {
    this.timer = null;
  }

  render() {
    return <Poll {...this.state.poll} onClick={this.handleClick.bind(this)}/>
  }
}
