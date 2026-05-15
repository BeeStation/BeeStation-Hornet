/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { PropsWithChildren, ReactNode, useEffect } from 'react';

import { backendSuspendStart, useBackend } from '../backend';
import { globalStore } from '../backend';
import { BoxProps } from '../components/Box';
import { UI_DISABLED, UI_INTERACTIVE } from '../constants';
import { useDebug } from '../debug';
import {
  dragStartHandler,
  recallWindowGeometry,
  resizeStartHandler,
  setWindowKey,
} from '../drag';
import { createLogger } from '../logging';
import { Layout } from './Layout';
import { TitleBar } from './TitleBar';

const logger = createLogger('Window');

const DEFAULT_SIZE: [number, number] = [400, 600];

type Props = Partial<{
  buttons: ReactNode;
  canClose: BooleanLike;
  height: number;
  theme: string;
  title: string;
  width: number;
  override_bg: string;
}> &
  PropsWithChildren;

export const Window = (props: Props) => {
  const {
    canClose = true,
    theme,
    title,
    children,
    buttons,
    width,
    height,
    override_bg,
  } = props;

  const { config, suspended } = useBackend();
  const { debugLayout = false } = useDebug();

  useEffect(() => {
    if (!suspended) {
      const updateGeometry = () => {
        const options = {
          ...config.window,
          size: DEFAULT_SIZE,
        };

        if (width && height) {
          options.size = [width, height];
        }
        if (config.window?.key) {
          setWindowKey(config.window.key);
        }
        recallWindowGeometry(options);
      };

      Byond.winset(Byond.windowId, {
        'can-close': Boolean(canClose),
      });
      logger.log('mounting');
      updateGeometry();

      return () => {
        logger.log('unmounting');
      };
    }
  }, [width, height]);

  const dispatch = globalStore.dispatch;

  // Determine when to show dimmer
  const showDimmer =
    config.user &&
    (config.user.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE);

  return suspended ? null : (
    <Layout className="Window" theme={theme} backgroundColor={override_bg}>
      <TitleBar
        title={title || decodeHtmlEntities(config.title)}
        status={config.status}
        onDragStart={dragStartHandler}
        onClose={() => {
          logger.log('pressed close');
          dispatch(backendSuspendStart());
        }}
        canClose={canClose}
      >
        {buttons}
      </TitleBar>
      <div className={classes(['Window__rest', debugLayout && 'debug-layout'])}>
        {!suspended && children}
        {showDimmer && <div className="Window__dimmer" />}
      </div>
      <div
        className="Window__resizeHandle__e"
        onMouseDown={resizeStartHandler(1, 0) as any}
      />
      <div
        className="Window__resizeHandle__s"
        onMouseDown={resizeStartHandler(0, 1) as any}
      />
      <div
        className="Window__resizeHandle__se"
        onMouseDown={resizeStartHandler(1, 1) as any}
      />
    </Layout>
  );
};

type ContentProps = Partial<{
  className: string;
  fitted: boolean;
  scrollable: boolean;
  vertical: boolean;
}> &
  BoxProps &
  PropsWithChildren;

const WindowContent = (props: ContentProps) => {
  const { className, fitted, children, ...rest } = props;

  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}
    >
      {(fitted && children) || (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;
