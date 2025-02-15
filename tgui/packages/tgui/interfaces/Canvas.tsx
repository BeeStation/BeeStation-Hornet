import { Color } from 'common/color';
import { decodeHtmlEntities } from 'common/string';
import { Component, createRef, RefObject } from 'react';
import { useBackend } from '../backend';
import { Tooltip, Icon, Box, Button, Flex } from '../components';
import { Window } from '../layouts';

const PX_PER_UNIT = 24;

const LEFT_CLICK = 0;

type PaintCanvasProps = Partial<{
  onCanvasModifiedHandler: (data: PointData[]) => void;
  onCanvasDropperHandler: (x: number, y: number) => void;
  value: string[][];
  width: number;
  height: number;
  imageWidth: number;
  imageHeight: number;
  editable: boolean;
  drawing_color: string | null;
  has_palette: boolean;
  show_grid: boolean;
}>;

type PointData = {
  x: number;
  y: number;
  color: Color;
};

const fromDM = (data: string[][]) => {
  return data.map((inner) => inner.map((v) => Color.fromHex(v)));
};

const toMassPaintFormat = (data: PointData[]) => {
  return data.map((p) => ({ x: p.x + 1, y: p.y + 1 })); // 1-based index dm side
};

class PaintCanvas extends Component<PaintCanvasProps> {
  canvasRef: RefObject<HTMLCanvasElement>;
  baseImageData: Color[][];
  is_grid_shown: boolean;
  modifiedElements: PointData[];
  onCanvasModified: (data: PointData[]) => void;
  onCanvasDropper: (x: number, y: number) => void;
  drawing: boolean;
  drawing_color: string;

  constructor(props) {
    super(props);
    this.canvasRef = createRef<HTMLCanvasElement>();
    this.modifiedElements = [];
    this.is_grid_shown = false;
    this.drawing = false;
    this.onCanvasModified = props.onCanvasModifiedHandler;
    this.onCanvasDropper = props.onCanvasDropperHandler;

    this.handleStartDrawing = this.handleStartDrawing.bind(this);
    this.handleDrawing = this.handleDrawing.bind(this);
    this.handleEndDrawing = this.handleEndDrawing.bind(this);
    this.handleDropper = this.handleDropper.bind(this);
  }

  componentDidMount() {
    this.prepareCanvas();
    this.syncCanvas();
  }

  componentDidUpdate() {
    // eslint-disable-next-line max-len
    if (
      (this.props.value !== undefined && JSON.stringify(this.baseImageData) !== JSON.stringify(fromDM(this.props.value))) ||
      this.is_grid_shown !== this.props.show_grid
    ) {
      this.syncCanvas();
    }
  }

  prepareCanvas() {
    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext('2d');
    const width = this.props.width || canvas.width || 360;
    const height = this.props.height || canvas.height || 360;
    const x_resolution = this.props.imageWidth || 36;
    const y_resolution = this.props.imageHeight || 36;
    const x_scale = Math.round(width / x_resolution);
    const y_scale = Math.round(height / y_resolution);
    ctx?.setTransform(1, 0, 0, 1, 0, 0);
    ctx?.scale(x_scale, y_scale); // This clears the canvas.
  }

  syncCanvas() {
    if (this.props.value === undefined) {
      return;
    }
    this.baseImageData = fromDM(this.props.value);
    this.is_grid_shown = !!this.props.show_grid;
    this.modifiedElements = [];

    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext('2d')!;
    for (let x = 0; x < this.baseImageData.length; x++) {
      const element = this.baseImageData[x];
      for (let y = 0; y < element.length; y++) {
        const color = element[y];
        ctx.fillStyle = color.toString();
        ctx.fillRect(x, y, 1, 1);
        if (this.is_grid_shown) {
          ctx.strokeStyle = '#888888';
          ctx.lineWidth = 0.05;
          ctx.strokeRect(x, y, 1, 1);
        }
      }
    }
  }

  eventToCoords(event: MouseEvent) {
    const canvas = this.canvasRef.current!;
    const width = this.props.width || canvas.width || 360;
    const height = this.props.height || canvas.height || 360;
    const x_resolution = this.props.imageWidth || 36;
    const y_resolution = this.props.imageHeight || 36;
    const x_scale = Math.round(width / x_resolution);
    const y_scale = Math.round(height / y_resolution);

    const rect = canvas.getBoundingClientRect();
    const x = Math.floor((event.clientX - rect.left) / x_scale);
    const y = Math.floor((event.clientY - rect.top) / y_scale);
    return { x, y };
  }

  handleStartDrawing(event: MouseEvent) {
    if (
      !this.props.editable ||
      this.props.drawing_color === undefined ||
      this.props.drawing_color === null ||
      event.button !== LEFT_CLICK
    ) {
      return;
    }
    this.modifiedElements = [];
    this.drawing = true;
    this.drawing_color = this.props.drawing_color;
    const coords = this.eventToCoords(event);
    this.drawPoint(coords.x, coords.y, this.drawing_color);
  }

  drawPoint(x: number, y: number, color: any) {
    let p: PointData = { x, y, color: Color.fromHex(color) };
    this.modifiedElements.push(p);
    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext('2d')!;
    ctx.fillStyle = color;
    ctx.fillRect(x, y, 1, 1);
    if (this.is_grid_shown) {
      ctx.strokeStyle = '#888888';
      ctx.lineWidth = 0.05;
      ctx.strokeRect(x, y, 1, 1);
    }
  }

  handleDrawing(event: MouseEvent) {
    if (!this.drawing) {
      return;
    }
    const coords = this.eventToCoords(event);
    this.drawPoint(coords.x, coords.y, this.drawing_color);
  }

  handleEndDrawing(event: MouseEvent) {
    if (!this.drawing) {
      return;
    }
    this.drawing = false;
    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext('2d')!;
    if (this.onCanvasModified !== undefined) {
      this.onCanvasModified(this.modifiedElements);
    }
  }

  handleDropper(event: MouseEvent) {
    event.preventDefault();
    if (!this.props.has_palette) {
      return;
    }
    const coords = this.eventToCoords(event);
    this.onCanvasDropper(coords.x + 1, coords.y + 1); // 1-based index dm side
  }

  render() {
    const { value, width = 300, height = 300, imageWidth = 36, imageHeight = 36, ...rest } = this.props;
    return (
      <canvas
        ref={this.canvasRef}
        width={width}
        height={height}
        {...rest}
        onMouseDown={this.handleStartDrawing as any}
        onMouseMove={this.handleDrawing as any}
        onMouseUp={this.handleEndDrawing as any}
        onMouseOut={this.handleEndDrawing as any}
        onContextMenu={this.handleDropper as any}>
        Canvas failed to render.
      </canvas>
    );
  }
}

const getImageSize = (value) => {
  const width = value.length;
  const height = width !== 0 ? value[0].length : 0;
  return [width, height];
};

type PaletteColor = {
  color: string;
  is_selected: boolean;
};

type CanvasData = {
  grid: string[][];
  finalized: boolean;
  name: string;
  editable: boolean;
  paint_tool_color: string | null;
  paint_tool_palette: PaletteColor[] | null;
  author: string | null;
  medium: string | null;
  patron: string | null;
  date: string | null;
  show_plaque: boolean;
  show_grid: boolean;
};

export const Canvas = (props) => {
  const { act, data } = useBackend<CanvasData>();
  const [width, height] = getImageSize(data.grid);
  const scaled_width = width * PX_PER_UNIT;
  const scaled_height = height * PX_PER_UNIT;
  const average_plaque_height = 90;
  const palette_height = 44;
  const griddy = !!data.show_grid && !!data.editable && !!data.paint_tool_color;
  return (
    <Window
      width={scaled_width + 72}
      height={
        scaled_height +
        75 +
        (data.show_plaque ? average_plaque_height : 0) +
        (data.editable && data.paint_tool_palette ? palette_height : 0)
      }>
      <Window.Content>
        <Flex align="start" direction="row">
          {!!data.paint_tool_palette && (
            <Flex.Item>
              <Tooltip
                content={
                  `
                  You can Right-Click the canvas to change the color of
                  the painting tool to that of the clicked pixel.
                ` +
                  (data.editable
                    ? `
                  \n You can also select a color from the
                  palette at the bottom of the UI,
                  or input a new one with Right-Click.
                `
                    : '')
                }>
                <Icon name="question-circle" color="blue" size={1.5} m={0.5} />
              </Tooltip>
            </Flex.Item>
          )}
          {!!data.editable && !!data.paint_tool_color && (
            <Flex.Item>
              <Button
                title="Grid Toggle"
                icon="th-large"
                backgroundColor={data.show_grid ? 'green' : 'red'}
                onClick={() => act('toggle_grid')}
                size={1.5}
                m={0.5}
              />
            </Flex.Item>
          )}
        </Flex>
        <Box textAlign="center">
          <PaintCanvas
            value={data.grid}
            imageWidth={width}
            imageHeight={height}
            width={scaled_width}
            height={scaled_height}
            drawing_color={data.paint_tool_color}
            show_grid={griddy}
            onCanvasModifiedHandler={(changed) => act('paint', { data: toMassPaintFormat(changed) })}
            onCanvasDropperHandler={(x, y) => act('select_color_from_coords', { px: x, py: y })}
            editable={data.editable}
            has_palette={!!data.paint_tool_palette}
          />
          <Flex align="center" justify="center" direction="column">
            {!!data.editable && !!data.paint_tool_palette && (
              <Flex.Item>
                {data.paint_tool_palette.map((element, index) => (
                  <Button
                    key={`${index}`}
                    backgroundColor={element.color}
                    style={{
                      width: '24px',
                      height: '24px',
                      borderStyle: 'solid',
                      borderColor: element.is_selected ? 'lightblue' : 'black',
                      borderWidth: '2px',
                    }}
                    onClick={() =>
                      act('select_color', {
                        selected_color: element.color,
                      })
                    }
                    onContextMenu={(e) => {
                      e.preventDefault();
                      act('change_palette', {
                        color_index: index + 1,
                        old_color: element.color,
                      });
                    }}
                  />
                ))}
              </Flex.Item>
            )}
            {!data.finalized && (
              <Flex.Item>
                <Button.Confirm onClick={() => act('finalize')} content="Finalize" />
              </Flex.Item>
            )}
            {!!data.finalized && !!data.show_plaque && (
              <Flex.Item
                basis="content"
                p={2}
                width="60%"
                textColor="black"
                textAlign="left"
                backgroundColor="white"
                style={{ borderStyle: 'inset' }}>
                <Box mb={1} fontSize="18px" bold>
                  {decodeHtmlEntities(data.name)}
                </Box>
                <Box bold>
                  {data.author}
                  {!!data.date && `- ${new Date(data.date).getFullYear() + 540}`}
                </Box>
                <Box italic>{data.medium}</Box>
                <Box italic>
                  {!!data.patron && `Sponsored by ${data.patron} `}
                  <Button icon="hand-holding-usd" color="transparent" iconColor="black" onClick={() => act('patronage')} />
                </Box>
              </Flex.Item>
            )}
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
