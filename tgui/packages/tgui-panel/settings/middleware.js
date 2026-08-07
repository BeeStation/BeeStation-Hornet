/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';

import { setClientTheme } from '../themes';
import {
  addHighlightSetting,
  loadSettings,
  removeHighlightSetting,
  updateHighlightSetting,
  updateSettings,
} from './actions';
import { FONTS_DISABLED } from './constants';
import { selectSettings } from './selectors';

const setGlobalFontSize = (fontSize) => {
  document.documentElement.style.setProperty('font-size', fontSize + 'px');
  document.body.style.setProperty('font-size', fontSize + 'px');
};

const setGlobalFontFamily = (fontFamily) => {
  if (fontFamily === FONTS_DISABLED) fontFamily = null;

  document.documentElement.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-family', fontFamily);
};

export const settingsMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get('panel-settings').then((settings) => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (
      type === updateSettings.type ||
      type === loadSettings.type ||
      type === addHighlightSetting.type ||
      type === removeHighlightSetting.type ||
      type === updateHighlightSetting.type
    ) {
      // Set client theme
      const theme = payload?.theme;
      if (theme) {
        setClientTheme(theme);
      } else if (type === loadSettings.type) {
        updateSettings({
          theme: 'blue',
        });
      }
      // Pass action to get an updated state
      next(action);
      const settings = selectSettings(store.getState());
      // Update global UI font size
      setGlobalFontSize(settings.fontSize);
      setGlobalFontFamily(settings.fontFamily);
      // Save settings to the web storage
      storage.set('panel-settings', settings);
      return;
    }
    return next(action);
  };
};
