import { Component } from 'react';

import { Chart } from './Chart';

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
    for(let i = 0; i <= steps; i++) {
      let xPos = (i * this.distPerStep + leftLimit);
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
    ...rest
  } = this.props;
  return (
      <Chart.Line
              data={this.iterateOverNodes(funct, leftLimit, steps)}
              rangeX={[leftLimit, rightLimit]}
              rangeY={[lowerLimit, upperLimit]}
              strokeColor={lineColor}
              fillColor={fillColor}
              {...rest}
            />
  );
  }
}
