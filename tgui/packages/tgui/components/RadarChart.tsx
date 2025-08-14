import { hexToRgba } from 'common/color';
import { Component } from 'react';

const toDegrees = function (rad: number): number {
  return (rad / Math.PI) * 180;
};

interface RadarChartProps {
  width?: number;
  height?: number;
  outlineWidth?: number;
  color?: string;
  fontSize?: number;
  fontFamily?: string;
  tickWidth?: number;
  axes: string[] | string;
  stages: string[] | string;
  values: number[] | string;
  areaColor?: string;
}

const trimMap = (value: string): string => value.trim();
const parseIntMap = (value: string): number => parseInt(value, 10);

export class RadarChart extends Component<RadarChartProps> {
  fillColor: string;
  strokeColor: string;
  axes: string[];
  stages: string[];
  values: number[];

  constructor(props) {
    super(props);
    const { areaColor = '#f36e36', axes, stages, values } = props;
    const rgba = hexToRgba(areaColor);
    this.fillColor = `rgba(${rgba.r}, ${rgba.g}, ${rgba.b}, 0.5)`;
    this.strokeColor = areaColor;

    this.axes =
      typeof axes === 'string'
        ? axes.split(',').map(trimMap)
        : (axes as string[]);
    this.stages =
      typeof axes === 'string'
        ? stages.split(',').map(trimMap)
        : (stages as string[]);
    this.values =
      typeof values === 'string'
        ? values.split(',').map(trimMap).map(parseIntMap)
        : (values as number[]);
    this.values = this.values.map((value: number) =>
      Math.min(value, this.stages.length),
    );
  }

  render() {
    const {
      width = 400,
      height = 400,
      outlineWidth = 2,
      color = 'white',
      fontSize = width / 12,
      fontFamily = 'Verdana',
      tickWidth = 4,
    } = this.props;
    const { axes, stages, values } = this;

    if (axes.length < 3) {
      // insufficient data
      return;
    }

    let elements: any[] = [];

    const midX = width / 2;
    const midY = height / 2;
    const radarSize = width / 3;
    const stepSize = radarSize / (stages.length + 1);

    let areaPoints = '';
    let angle = Math.PI / 2;
    for (let i = 0; i < axes.length; i++) {
      const x = midX + Math.cos(angle) * stepSize * values[i];
      const y = midY - Math.sin(angle) * stepSize * values[i];
      if (i !== 0) {
        areaPoints += ' ';
      }
      areaPoints += x.toString() + ',' + y.toString();
      angle -= (2 * Math.PI) / axes.length;
    }

    const polygon = (
      <polygon
        points={areaPoints}
        // makes fill transparent
        fill={this.fillColor}
        stroke={this.strokeColor}
        stroke-width={outlineWidth}
      />
    );
    elements.push(polygon);

    const innerCircle = (
      <circle
        cx={midX}
        cy={midY}
        r={radarSize}
        stroke={color}
        fill={'rgba(0, 0, 0, 0)'}
      />
    );
    elements.push(innerCircle);

    const outerCircle = (
      <circle
        cx={midX}
        cy={midY}
        r={width / 1.9}
        stroke={color}
        fill={'rgba(0, 0, 0, 0)'}
      />
    );
    elements.push(outerCircle);

    for (let i = 0; i < axes.length; i++) {
      const valueOffset = radarSize + fontSize * 0.75;
      const valueText = (
        <text
          x={midX + Math.cos(angle) * valueOffset}
          y={midY - Math.sin(angle) * valueOffset + fontSize / 3}
          fill={color}
          stroke={'black'}
          stroke-width={'0.1'}
          font-family={fontFamily}
          font-size={fontSize}
          text-anchor={'middle'}
          dominant-baseline={'middle'}
        >
          {stages[values[i] - 1]}
        </text>
      );
      elements.push(valueText);

      const keyOffset = radarSize + fontSize * 1.5;
      const keyX = midX + Math.cos(angle) * keyOffset;
      const keyY = midY - Math.sin(angle) * keyOffset + fontSize / 6;
      let rotation = -toDegrees(angle - Math.PI / 2) % 360;
      if (rotation > 90 && rotation < 270) {
        rotation += 180;
      }
      let rounding = 180 / axes.length;
      const keyText = (
        <text
          x={keyX}
          y={keyY}
          fill={color}
          stroke={'black'}
          stroke-width={'0.1'}
          font-family={fontFamily}
          font-size={Math.round(fontSize / 1.75)}
          text-anchor={'middle'}
          dominant-baseline={'middle'}
          transform={
            'rotate(' +
            Math.round(Math.ceil(rotation / rounding) * rounding) +
            ' ' +
            keyX +
            ' ' +
            keyY +
            ')'
          }
        >
          {axes[i]}
        </text>
      );
      elements.push(keyText);

      const lineX = midX + Math.cos(angle) * radarSize;
      const lineY = midY - Math.sin(angle) * radarSize;
      const line = (
        <line x1={midX} y1={midY} x2={lineX} y2={lineY} stroke={color} />
      );
      elements.push(line);

      for (let j = 1; j <= stages.length; j++) {
        const tickMidX = midX + Math.cos(angle) * stepSize * j;
        const tickMidY = midY - Math.sin(angle) * stepSize * j;
        const crossAngle = angle - Math.PI / 2;
        const tickX1 = tickMidX - Math.cos(crossAngle) * tickWidth;
        const tickY1 = tickMidY + Math.sin(crossAngle) * tickWidth;
        const tickX2 = tickMidX + Math.cos(crossAngle) * tickWidth;
        const tickY2 = tickMidY - Math.sin(crossAngle) * tickWidth;
        const tickLine = (
          <line
            x1={tickX1}
            y1={tickY1}
            x2={tickX2}
            y2={tickY2}
            stroke={color}
          />
        );
        elements.push(tickLine);

        if (i === 0) {
          const stageX = tickX2 + tickWidth;
          const stageY = tickY2;
          const stageText = (
            <text
              x={stageX}
              y={stageY}
              stroke={'black'}
              stroke-width={'0.1'}
              fill={color}
              font-size={fontSize / 2.3}
              font-family={fontFamily}
            >
              {stages[j - 1]}
            </text>
          );
          elements.push(stageText);
        }
      }

      angle -= (2 * Math.PI) / axes.length;
    }

    return (
      <svg width={width} height={height}>
        {elements}
      </svg>
    );
  }
}
