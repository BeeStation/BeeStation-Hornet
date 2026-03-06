import { Component, createRef } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  DraggableClickableControl,
  Flex,
  Section,
} from '../components';
import { Window } from '../layouts';

class ReagentGrid extends Component {
  constructor(props) {
    super(props);
    this.svgRef = createRef();

    this.hovered_reagent = null;
    this.last_hovered_reagent = null;
    this.selected_reagent = null;

    this.mousePosition = { x: 0, y: 0 };
    this.svgPosition = { x: 0, y: 0 };
    this.svgDimensions = { width: 250, height: 250 };
    this.svgGridSize = { width: 10, height: 10 };

    this.gridRestPosition = { x: 0, y: 0 };

    this.dynamicXOffset = 0;
    this.dynamicYOffset = 0;

    this.lockedZoomScale = 1;

    this.hitbox_scale = 1;
  }

  checkReagent(index, reagent_id) {
    return (
      this.hovered_reagent === reagent_id ||
      this.selected_reagent === reagent_id ||
      (index === reagent_id &&
        (this.selected_reagent === null || this.selected_reagent === index))
    );
  }

  setHovered(reagent_id) {
    this.hovered_reagent = reagent_id;
    this.last_hovered_reagent =
      this.hovered_reagent || this.last_hovered_reagent;
  }

  setSelected(reagent_id) {
    this.selected_reagent = reagent_id;

    let last_reagent = this.last_hovered_reagent;
    this.last_hovered_reagent = null;

    this.gridRestPosition.x = !reagent_id
      ? 0
      : this.svgPosition.x / 10 + Math.floor(this.dynamicXOffset / 10);
    this.gridRestPosition.y = !reagent_id
      ? 0
      : this.svgPosition.y / 10 +
        Math.floor(Math.floor(this.dynamicYOffset / 10));
    this.gridRestPosition.x += this.dynamicXOffset < 0 ? 1 : 0;
    this.gridRestPosition.y += this.dynamicYOffset < 0 ? 1 : 0;

    return last_reagent;
  }

  setZoomScale(newZoom) {
    this.lockedZoomScale = newZoom;
    this.lockedZoomScale = Math.max(Math.min(this.lockedZoomScale, 2), 0.5);
    this.forceUpdate();
  }

  useMousePosition = (ev) => {
    // Update mouse position
    this.mousePosition.x = ev.clientX;
    this.mousePosition.y = ev.clientY;
    // Convert to SVG space
    let rect = this.svgRef.current.getBoundingClientRect();
    // X
    this.svgPosition.x = Math.round(
      (Math.max(this.mousePosition.x - rect.left, 0) /
        (rect.right - rect.left)) *
        (this.svgDimensions.width / this.lockedZoomScale),
    );
    this.svgPosition.x += this.dynamicXOffset % 10;
    this.svgPosition.x =
      Math.round(this.svgPosition.x / this.svgGridSize.width) *
      this.svgGridSize.width;
    // Y
    this.svgPosition.y = Math.round(
      (Math.max(this.mousePosition.y - rect.top, 0) /
        (rect.bottom - rect.top)) *
        (this.svgDimensions.height / this.lockedZoomScale),
    );
    this.svgPosition.y += this.dynamicYOffset % 10;
    this.svgPosition.y =
      Math.round(this.svgPosition.y / this.svgGridSize.height) *
      this.svgGridSize.height;

    this.forceUpdate();
  };

  render() {
    const { act } = useBackend();
    const { reagent_data, selected_reagent, accuracy } = this.props;

    return (
      <Flex height="100.1%" width="100%" direction="column">
        <Section height="100%" width="100%">
          This is a prototype for the plant reagent system, like all the UIs, it
          is unfinished and subject to change via your feedback
          <br />
          {`${this.dynamicXOffset} : ${this.svgPosition.x} : ${this.svgPosition.x + Math.round(this.dynamicXOffset / 10) * 10} : ${this.gridRestPosition.x}`}
          <br />
          {`${this.dynamicYOffset} : ${this.svgPosition.y} : ${this.svgPosition.y + this.dynamicYOffset} : ${this.gridRestPosition.y}`}
          <br />
          {`${this.selected_reagent}`}
          <Button
            className="plant__button--beacon"
            position="absolute"
            icon="search-plus"
            right="20px"
            top="15px"
            fontSize="18px"
            color="grey"
            onClick={() => this.setZoomScale(this.lockedZoomScale * 2)}
          />
          <Button
            className="plant__button--beacon"
            position="absolute"
            icon="search-minus"
            right="60px"
            top="15px"
            fontSize="18px"
            color="grey"
            onClick={() => this.setZoomScale(this.lockedZoomScale / 2)}
          />
        </Section>
        <Section height="100%" width="100%">
          <DraggableClickableControl
            position="absolute"
            value={this.dynamicXOffset}
            dragMatrix={[-1, 0]}
            step={1}
            stepPixelSize={3 * this.lockedZoomScale}
            onDrag={(e, value) => {
              this.dynamicXOffset = value;
            }}
            onClick={() => {
              act('select_reagent', {
                key: this.setSelected(this.last_hovered_reagent),
                grid_x: this.gridRestPosition.x,
                grid_y: this.gridRestPosition.y,
              });
            }}
            updateRate={5}
          >
            {(control) => (
              <DraggableClickableControl
                position="absolute"
                value={this.dynamicYOffset}
                dragMatrix={[0, -1]}
                step={1}
                stepPixelSize={3 * this.lockedZoomScale}
                onDrag={(e, value) => {
                  this.dynamicYOffset = value;
                }}
                onClick={() => {}}
                updateRate={5}
              >
                {(control1) => (
                  <svg
                    ref={this.svgRef}
                    viewBox={`0 0 ${this.svgDimensions.width / this.lockedZoomScale} ${this.svgDimensions.height / this.lockedZoomScale}`}
                    onMouseMove={(e) => {
                      this.useMousePosition(e);
                    }}
                    onMouseDown={(e) => {
                      control.handleDragStart(e);
                      control1.handleDragStart(e);
                    }}
                  >
                    {/* Pattern defs */}
                    {/* Terrain defs */}
                    <filter id="test">
                      <feTurbulence baseFrequency={0.009} numOctaves={5} />
                      <feComponentTransfer>
                        <feFuncA
                          type="discrete"
                          tableValues="1 0 1 0 1 0 1 0 1 0"
                        />
                      </feComponentTransfer>
                      <feConvolveMatrix
                        kernelMatrix="1 0 1
                                                      0 -4 0
                                                      1 0 1"
                      />
                      <feColorMatrix
                        values="0 0 0 -1 1
                                            0 0 0 -1 1
                                            0 0 0 -1 1
                                            0 0 0 0 1"
                      />
                      <feColorMatrix
                        values="-1 0 0 0.1 0
                                            0 -1 0 0.16 0
                                            0 0 -1 0.26 0
                                            0 0 0  1 1"
                      />
                    </filter>
                    <defs>
                      <pattern
                        x={-this.dynamicXOffset - 1}
                        y={-this.dynamicYOffset - 1}
                        id="terrain_fill"
                        width={this.svgDimensions.width / this.lockedZoomScale}
                        height={
                          this.svgDimensions.height / this.lockedZoomScale
                        }
                        patternUnits="userSpaceOnUse"
                      >
                        <rect
                          width={
                            this.svgDimensions.width / this.lockedZoomScale
                          }
                          height={
                            this.svgDimensions.height / this.lockedZoomScale
                          }
                          fill="#7777ff"
                          filter="url(#test)"
                        />
                      </pattern>
                    </defs>
                    {/*   Grid Pattern */}
                    <defs>
                      <pattern
                        x={-5.2 - this.dynamicXOffset}
                        y={-5.2 - this.dynamicYOffset}
                        id="grid"
                        width={this.svgGridSize.width}
                        height={this.svgGridSize.height}
                        patternUnits="userSpaceOnUse"
                      >
                        <rect
                          width={this.svgGridSize.width}
                          height={this.svgGridSize.height}
                          fill="url(#smallgrid)"
                        />
                        <path
                          d={`M ${this.svgGridSize.width} 0 L 0 0 0 ${this.svgGridSize.height}`}
                          fill="none"
                          stroke="#7a5178"
                          stroke-width="1"
                        />
                      </pattern>
                      <pattern
                        id="smallgrid"
                        width={this.svgDimensions.width}
                        height={this.svgDimensions.height}
                        patternUnits="userSpaceOnUse"
                      >
                        <rect
                          width={this.svgDimensions.width}
                          height={this.svgDimensions.height}
                          fill="#ff000000"
                        />
                      </pattern>
                    </defs>

                    <defs>
                      <pattern
                        x={-5.2}
                        y={-5.2}
                        id="grid2"
                        width={this.svgGridSize.width}
                        height={this.svgGridSize.height}
                        patternUnits="userSpaceOnUse"
                      >
                        <rect
                          width={this.svgGridSize.width}
                          height={this.svgGridSize.height}
                          fill="url(#smallgrid)"
                        />
                        <path
                          d={`M ${this.svgGridSize.width} 0 L 0 0 0 ${this.svgGridSize.height}`}
                          fill="none"
                          stroke="#7a5178"
                          stroke-width="1"
                        />
                      </pattern>
                    </defs>
                    {/* Cloud fill Pattern */}
                    <defs>
                      <pattern
                        x={-this.dynamicXOffset - 5}
                        y={-this.dynamicYOffset - 5}
                        id="square_fill"
                        width={10}
                        height={10}
                        patternUnits="userSpaceOnUse"
                      >
                        <path
                          d={`M 1 1 L 4 1 L 1 4 L 1 1`}
                          fill="none"
                          stroke="#f2ff82"
                          stroke-width="0.5"
                        />
                      </pattern>
                    </defs>
                    {/* Crosshair Pattern */}
                    <defs>
                      <pattern
                        x={-this.dynamicXOffset - 5}
                        y={-this.dynamicYOffset - 5}
                        id="crosshair"
                        width={10}
                        height={10}
                        patternUnits="userSpaceOnUse"
                      >
                        <path
                          d={`M 9 9 L 6 9 L 9 6 L 9 9`}
                          fill="none"
                          stroke="#82cdff"
                          stroke-width="0.5"
                        />
                      </pattern>
                    </defs>

                    <defs>
                      <pattern
                        x={-this.dynamicXOffset - 5}
                        y={-this.dynamicYOffset - 5}
                        id="crosshair_planted"
                        width={10}
                        height={10}
                        patternUnits="userSpaceOnUse"
                      >
                        <path
                          d={`M 9 1 L 9 4 L 6 1 L 9 1`}
                          fill="none"
                          stroke="#86ff82"
                          stroke-width="0.5"
                        />
                      </pattern>
                    </defs>
                    {/* Selected Pattern */}
                    <defs>
                      <pattern
                        x={-this.dynamicXOffset}
                        y={-this.dynamicYOffset}
                        id="selected"
                        width={10}
                        height={10}
                        patternUnits="userSpaceOnUse"
                      >
                        <path
                          d={
                            'M0,5 h80 M5,0 v20 M25,0 v20 M40,0 v20 M55,0 v20 M70,0 v20'
                          }
                          fill="none"
                          stroke="#ffff77"
                          stroke-width="0.5"
                        />
                      </pattern>
                    </defs>
                    {/* Graphics */}
                    {/* Grid */}
                    <rect
                      width={this.svgDimensions.width / this.lockedZoomScale}
                      height={this.svgDimensions.height / this.lockedZoomScale}
                      fill="url(#terrain_fill)"
                    />
                    <rect
                      x="0%"
                      y="0%"
                      width="100%"
                      height="100%"
                      fill="url(#grid)"
                      onMouseEnter={() => {
                        this.last_hovered_reagent = null;
                        this.hovered_reagent = null;
                      }}
                    />
                    {/* Reagent clouds */}
                    {Object.entries(reagent_data).map(
                      ([data_list_key, data_list]) => (
                        <>
                          {/* probability square */}
                          <rect
                            pointer-events="none"
                            width={
                              Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) * 10
                            }
                            height={
                              Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) * 10
                            }
                            stroke-width="0.5"
                            x={
                              data_list['GRID_REAGENT_POSITION'][0] * 10 -
                              this.dynamicXOffset -
                              5 -
                              Math.floor(
                                Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) / 2,
                              ) *
                                10 +
                              Math.max(
                                data_list['REAGENT_OFFSET'][0] - accuracy,
                                0,
                              ) *
                                10
                            }
                            y={
                              data_list['GRID_REAGENT_POSITION'][1] * 10 -
                              this.dynamicYOffset -
                              5 -
                              Math.floor(
                                Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) / 2,
                              ) *
                                10 +
                              Math.max(
                                data_list['REAGENT_OFFSET'][1] - accuracy,
                                0,
                              ) *
                                10
                            }
                            fill={'url(#square_fill)'}
                            rx={data_list['GRID_REAGENT_SIZE'] * 2 + 5}
                            stroke={`${this.checkReagent(selected_reagent, data_list_key) ? '#ffff77' : '#00000000'}`}
                            strokeWidth={0.5}
                          />
                          {/* select / hover square */}
                          <rect
                            pointer-events="none"
                            width={
                              Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) * 10
                            }
                            height={
                              Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) * 10
                            }
                            stroke-width="0.5"
                            x={
                              data_list['GRID_REAGENT_POSITION'][0] * 10 -
                              this.dynamicXOffset -
                              5 -
                              Math.floor(
                                Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) / 2,
                              ) *
                                10 +
                              Math.max(
                                data_list['REAGENT_OFFSET'][0] - accuracy,
                                0,
                              ) *
                                10
                            }
                            y={
                              data_list['GRID_REAGENT_POSITION'][1] * 10 -
                              this.dynamicYOffset -
                              5 -
                              Math.floor(
                                Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) / 2,
                              ) *
                                10 +
                              Math.max(
                                data_list['REAGENT_OFFSET'][1] - accuracy,
                                0,
                              ) *
                                10
                            }
                            fill={'#ffffff00'}
                            stroke={`${this.checkReagent(selected_reagent, data_list_key) ? '#ffff77' : '#00000000'}`}
                            strokeWidth={0.5}
                          />
                          {/* selection square */}
                          <rect
                            width={
                              (Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) /
                                this.hitbox_scale) *
                              10
                            }
                            height={
                              (Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) /
                                this.hitbox_scale) *
                              10
                            }
                            stroke-width="0.5"
                            x={
                              data_list['GRID_REAGENT_POSITION'][0] * 10 -
                              this.dynamicXOffset -
                              5 -
                              Math.floor(
                                Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) / 2,
                              ) *
                                10 +
                              Math.max(
                                data_list['REAGENT_OFFSET'][0] - accuracy,
                                0,
                              ) *
                                10 +
                              ((Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) /
                                2) *
                                10 -
                                ((Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) /
                                  this.hitbox_scale) *
                                  10) /
                                  2)
                            }
                            y={
                              data_list['GRID_REAGENT_POSITION'][1] * 10 -
                              this.dynamicYOffset -
                              5 -
                              Math.floor(
                                Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) / 2,
                              ) *
                                10 +
                              Math.max(
                                data_list['REAGENT_OFFSET'][1] - accuracy,
                                0,
                              ) *
                                10 +
                              ((Math.max(
                                data_list['GRID_REAGENT_SIZE'] - accuracy,
                                1,
                              ) /
                                2) *
                                10 -
                                ((Math.max(
                                  data_list['GRID_REAGENT_SIZE'] - accuracy,
                                  1,
                                ) /
                                  this.hitbox_scale) *
                                  10) /
                                  2)
                            }
                            opacity={0}
                            onMouseEnter={() => {
                              this.setHovered(data_list_key);
                            }}
                            onMouseLeave={() => {
                              this.setHovered(null);
                            }}
                          />
                        </>
                      ),
                    )}
                    {/* Crosshair */}
                    <rect
                      pointer-events="none"
                      x={this.svgPosition.x - (this.dynamicXOffset % 10) - 5.2}
                      y={this.svgPosition.y - (this.dynamicYOffset % 10) - 5.2}
                      width={10}
                      height={10}
                      fill="url(#crosshair)"
                      stroke="#82cdff"
                      stroke-width="0.5"
                    >
                      <animate
                        attributeName="opacity"
                        values="0;0;5;5;0;0"
                        dur="0.5s"
                        repeatCount="indefinite"
                      />
                    </rect>
                    {/* Planted Crosshair */}
                    <rect
                      pointer-events="none"
                      opacity={this.selected_reagent !== null ? 1 : 0}
                      x={
                        this.gridRestPosition.x * 10 - this.dynamicXOffset - 5.2
                      }
                      y={
                        this.gridRestPosition.y * 10 - this.dynamicYOffset - 5.2
                      }
                      width={10}
                      height={10}
                      fill={
                        this.selected_reagent !== null
                          ? 'url(#crosshair_planted)'
                          : 'none'
                      }
                      stroke={
                        this.selected_reagent !== null ? '#86ff82' : 'none'
                      }
                      stroke-width="0.5"
                    >
                      <animate
                        attributeName="opacity"
                        values="0;0;5;5;0;0"
                        dur="0.5s"
                        repeatCount="indefinite"
                      />
                    </rect>
                  </svg>
                )}
              </DraggableClickableControl>
            )}
          </DraggableClickableControl>
        </Section>
      </Flex>
    );
  }
}

export const ReagentGridAlt = (props) => {
  const { act, data } = useBackend();
  const { reagent_data, selected_reagent, accuracy } = data;
  return (
    <Window width={900} height={830} theme="plant_menu">
      <Window.Content scrollable={0}>
        {/* Column elements */}
        <Flex height="100%" width="100%" direction="column">
          {/* Row elements */}
          <Flex direction="row" width="100%">
            {/* Grid */}
            <Flex.Item height="100%" width="70%">
              <ReagentGrid
                reagent_data={reagent_data}
                selected_reagent={selected_reagent}
                accuracy={accuracy}
              />
            </Flex.Item>
            {/* Data */}
            <Flex direction="column" height="100%" width="30%">
              <Flex.Item>
                <Section width="100%">
                  {selected_reagent
                    ? reagent_data[selected_reagent]['GRID_REAGENT_NAME']
                    : 'Lorem'}
                </Section>
              </Flex.Item>
              <Flex.Item height="100%">
                <Section height="100%" width="100%">
                  {selected_reagent}
                  <br />
                  <Button
                    className="plant__button--beacon"
                    icon="save"
                    fontSize="18px"
                    color="grey"
                    onClick={() => {
                      act('upload_coords');
                    }}
                  />
                </Section>
              </Flex.Item>
            </Flex>
          </Flex>
          {/* Fluff command section */}
          <Flex.Item height="100%">
            <Box height="100%" />
          </Flex.Item>
          <Flex.Item>
            <Section textAlign={'start'} width="100%">
              <Box>Yamato OS [Version 19.89.3.5]</Box>
              <Box>© 2554 Yamato. All Rights Reserved.</Box>
              <br />
              <Box>
                {'C:\\Users\\admin>'}e<span className={'terminal'}>|</span>
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
