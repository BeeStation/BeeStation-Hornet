"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = void 0;

var _loadjs = _interopRequireDefault(require("loadjs"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var corsImport = function corsImport(url) {
  if (!url) {
    return new Promise(function (resolve, reject) {
      return reject('no url in corsImport');
    });
  }

  if (_loadjs["default"].isDefined(url)) {
    return new Promise(function (resolve, reject) {
      resolve();
    });
  }

  (0, _loadjs["default"])(url, url);
  return new Promise(function (resolve, reject) {
    _loadjs["default"].ready(url, {
      success: resolve,
      error: reject
    });
  });
};

var _default = corsImport;
exports["default"] = _default;