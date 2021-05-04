/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

export const setTabs = createAction('stat/setTab');
export const setStatTabs = createAction('stat/setStatTabs');
export const setPanelInfomation = createAction('stat/setPanelInfomation');
export const antagPopup = createAction('stat/antagPopup');
export const clearAntagPopup = createAction('stat/clearAntagPopup');
export const alertPopup = createAction('stat/alertPopup');
export const clearAlertPopup = createAction('stat/clearAlertPopup');
export const deadPopup = createAction('stat/deadPopup');
export const clearDeadPopup = createAction('stat/clearDeadPopup');
