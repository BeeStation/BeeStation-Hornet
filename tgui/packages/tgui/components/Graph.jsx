import { Component } from 'react';


export class Graph extends Component {
  constructor(props) {
    super(props);
    const {
      funct,
      upperLimit,
      lowerLimit,
      leftLimit,
      rightLimit,
      steps,
      ...rest
    } = props;
    this.distPerStep = (rightLimit - leftLimit) / steps;
  }

  iterateOverNodes(funct, leftLimit, steps) {
    let points = [];
    for (let i = 0; i <= steps; i++) {
      let xPos = i * this.distPerStep + leftLimit;
      points.push([xPos, funct(xPos)]);
    }
    return points;
  }

  render() {
    const {
      funct,
      upperLimit,
      lowerLimit,
      leftLimit,
      rightLimit,
      steps,
      lineColor,
      fillColor,
      strokeWidth,
      ...rest
    } = this.props;
    return (
      <svg
            viewBox={`${leftLimit} ${lowerLimit} ${rightLimit} ${upperLimit}`}
            preserveAspectRatio="none"
  style={{
    position: 'absolute',
    width: '100%',
    height: '100%',
  }}
            {...rest}
          >

            <polyline
              transform={`scale(1, -1) translate(0, -${upperLimit - lowerLimit})`}
              fill={fillColor}
              stroke={lineColor}
              strokeWidth={strokeWidth}
              points={this.iterateOverNodes(funct, leftLimit, steps)}
            />
      </svg>
    );
  }
}
