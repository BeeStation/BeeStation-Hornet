import { Component } from 'react';

type Props = {
  funct: number;
  upperLimit: number;
  lowerLimit: number;
  leftLimit: number;
  rightLimit: number;
  steps: number;
  lineColor: string;
  fillColor: string;
  strokeWidth: number;
};

export class Graph extends Component<Props> {
  constructor(props) {
    super(props);
  }

  iterateOverNodes(
    funct: (i: number) => number,
    distPerStep: number,
    leftLimit: number,
    steps: number,
  ) {
    let points: number[][] = [];
    for (let i = 0; i <= steps; i++) {
      let xPos = i * distPerStep + leftLimit;
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
    } = this.props;
    let distPerStep = (rightLimit - leftLimit) / steps;
    return (
      <svg
        viewBox={`${leftLimit} ${lowerLimit} ${rightLimit} ${upperLimit}`}
        preserveAspectRatio="none"
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
        }}
      >
        <polyline
          transform={`scale(1, -1) translate(0, -${upperLimit - lowerLimit})`}
          fill={fillColor}
          stroke={lineColor}
          strokeWidth={strokeWidth}
          points={this.iterateOverNodes(funct, distPerStep, leftLimit, steps)}
        />
      </svg>
    );
  }
}
