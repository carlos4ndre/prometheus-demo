import React from "react"
import PropTypes from "prop-types"
import { Container, Image } from "semantic-ui-react"

const PollOption = ({name, image, total_votes, onClick}) => (
  <Container textAlign="center">
    <Image
      avatar
      src={require(`${image}`)}
      size="small"
      centered
      bordered
      onClick={onClick}
      style={{cursor: "pointer"}}
    />
    <div>{name}</div>
    <div>{total_votes}</div>
  </Container>
)

PollOption.propTypes = {
  name: PropTypes.string.isRequired,
  image: PropTypes.string.isRequired,
  total_votes: PropTypes.number.isRequired,
  onClick: PropTypes.func.isRequired
}

export default PollOption
