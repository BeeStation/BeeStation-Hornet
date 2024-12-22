/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Middleware, Reducer, Store, applyMiddleware, combineReducers, createStore } from 'common/redux';
import { backendMiddleware, backendReducer } from './backend';
import { debugMiddleware, debugReducer, relayMiddleware } from './debug';

import { Component } from 'inferno';
import { assetMiddleware } from './assets';
import { createLogger } from './logging';
import { flow } from 'common/fp';

type ConfigureStoreOptions = {
  sideEffects?: boolean;
  reducer?: Reducer;
  middleware?: {
    pre?: Middleware[];
    post?: Middleware[];
  };
};

type StackAugmentor = (stack: string, error?: Error) => string;

type StoreProviderProps = {
  store: Store;
  children: any;
};

const logger = createLogger('store');

export const configureStore = (options: ConfigureStoreOptions = {}): Store => {
  const { sideEffects = true, reducer, middleware } = options;
  const rootReducer: Reducer = flow([
    combineReducers({
      debug: debugReducer,
      backend: backendReducer,
    }),
    reducer,
  ]);

  const middlewares: Middleware[] = !sideEffects
    ? []
    : [
      ...(middleware?.pre || []),
      assetMiddleware,
      backendMiddleware,
      ...(middleware?.post || []),
    ];

  if (process.env.NODE_ENV !== 'production') {
    // We are using two if statements because Webpack is capable of
    // removing this specific block as dead code.
    if (sideEffects) {
      middlewares.unshift(loggingMiddleware, debugMiddleware, relayMiddleware);
    }
  }

  const enhancer = applyMiddleware(...middlewares);
  const store = createStore(rootReducer, enhancer);

  // Globals
  window.__store__ = store;
  window.__augmentStack__ = createStackAugmentor(store);

  return store;
};

const loggingMiddleware: Middleware = (store) => (next) => (action) => {
  const { type } = action;
  logger.debug(
    'action',
    type === 'update' || type === 'backend/update' ? { type } : action
  );
  return next(action);
};

/**
 * Creates a function, which can be assigned to window.__augmentStack__
 * to augment reported stack traces with useful data for debugging.
 */
const createStackAugmentor =
  (store: Store): StackAugmentor =>
  (stack, error) => {
    error = error || new Error(stack.split('\n')[0]);
    error.stack = error.stack || stack;

    logger.log('FatalError:', error);
    const state = store.getState();
    const config = state?.backend?.config;

    return (
      stack +
      '\nUser Agent: ' +
      navigator.userAgent +
      '\nState: ' +
      JSON.stringify({
        ckey: config?.client?.ckey,
        interface: config?.interface,
        window: config?.window,
      })
    );
  };

/**
 * Store provider for Inferno apps.
 */
export class StoreProvider extends Component<StoreProviderProps> {
  getChildContext() {
    const { store } = this.props;
    return { store };
  }

  render() {
    return this.props.children;
  }
}
