import React from "react"
import PropTypes from "prop-types"
import { Grid, Header } from "semantic-ui-react"
import PollOption from "./PollOption"

const Poll = ({topic, question, options, onClick}) => (
  <Grid centered stretched padded>
    <Grid.Row>
      <Grid.Column>
        <Header textAlign="center" size="huge">{question}</Header>
      </Grid.Column>
    </Grid.Row>
    <Grid.Row>
      <Grid columns={options.length}>
        <Grid.Row stretched>
          {options.map((option, i) =>
            <Grid.Column key={i} stretched>
              <PollOption {...option} onClick={(e) => onClick(option)}/>
            </Grid.Column>
          )}
        </Grid.Row>
      </Grid>
    </Grid.Row>
  </Grid>
)

Poll.propTypes = {
  topic: PropTypes.string.isRequired,
  question: PropTypes.string.isRequired,
  options: PropTypes.array.isRequired,
  onClick: PropTypes.func.isRequired
}

export default Poll
