/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./admin/ThemeOptionPage.jsx"
/*!***********************************!*\
  !*** ./admin/ThemeOptionPage.jsx ***!
  \***********************************/
(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (/* binding */ ThemeOptionsPage)
/* harmony export */ });
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @wordpress/element */ "@wordpress/element");
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_wordpress_element__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/i18n */ "@wordpress/i18n");
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @wordpress/api-fetch */ "@wordpress/api-fetch");
/* harmony import */ var _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _wordpress_components__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @wordpress/components */ "@wordpress/components");
/* harmony import */ var _wordpress_components__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_wordpress_components__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _components_MyCard__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./components/MyCard */ "./admin/components/MyCard.jsx");
function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
function ownKeys(e, r) { var t = Object.keys(e); if (Object.getOwnPropertySymbols) { var o = Object.getOwnPropertySymbols(e); r && (o = o.filter(function (r) { return Object.getOwnPropertyDescriptor(e, r).enumerable; })), t.push.apply(t, o); } return t; }
function _objectSpread(e) { for (var r = 1; r < arguments.length; r++) { var t = null != arguments[r] ? arguments[r] : {}; r % 2 ? ownKeys(Object(t), !0).forEach(function (r) { _defineProperty(e, r, t[r]); }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(t)) : ownKeys(Object(t)).forEach(function (r) { Object.defineProperty(e, r, Object.getOwnPropertyDescriptor(t, r)); }); } return e; }
function _defineProperty(e, r, t) { return (r = _toPropertyKey(r)) in e ? Object.defineProperty(e, r, { value: t, enumerable: !0, configurable: !0, writable: !0 }) : e[r] = t, e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == _typeof(i) ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != _typeof(t) || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r || "default"); if ("object" != _typeof(i)) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }
function _toConsumableArray(r) { return _arrayWithoutHoles(r) || _iterableToArray(r) || _unsupportedIterableToArray(r) || _nonIterableSpread(); }
function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _iterableToArray(r) { if ("undefined" != typeof Symbol && null != r[Symbol.iterator] || null != r["@@iterator"]) return Array.from(r); }
function _arrayWithoutHoles(r) { if (Array.isArray(r)) return _arrayLikeToArray(r); }
function _slicedToArray(r, e) { return _arrayWithHoles(r) || _iterableToArrayLimit(r, e) || _unsupportedIterableToArray(r, e) || _nonIterableRest(); }
function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
function _iterableToArrayLimit(r, l) { var t = null == r ? null : "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (null != t) { var e, n, i, u, a = [], f = !0, o = !1; try { if (i = (t = t.call(r)).next, 0 === l) { if (Object(t) !== t) return; f = !1; } else for (; !(f = (e = i.call(t)).done) && (a.push(e.value), a.length !== l); f = !0); } catch (r) { o = !0, n = r; } finally { try { if (!f && null != t["return"] && (u = t["return"](), Object(u) !== u)) return; } finally { if (o) throw n; } } return a; } }
function _arrayWithHoles(r) { if (Array.isArray(r)) return r; }





var SETTINGS_KEYS = ['sarbacane_api_key'];
var DEFAULT_SETTINGS = {
  sarbacane_api_key: ''
};
function ThemeOptionsPage() {
  var _useState = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.useState)(DEFAULT_SETTINGS),
    _useState2 = _slicedToArray(_useState, 2),
    settings = _useState2[0],
    setSettings = _useState2[1];
  var _useState3 = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.useState)(true),
    _useState4 = _slicedToArray(_useState3, 2),
    isLoading = _useState4[0],
    setIsLoading = _useState4[1];
  var _useState5 = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.useState)(false),
    _useState6 = _slicedToArray(_useState5, 2),
    isSaving = _useState6[0],
    setIsSaving = _useState6[1];
  var _useState7 = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.useState)([]),
    _useState8 = _slicedToArray(_useState7, 2),
    notices = _useState8[0],
    setNotices = _useState8[1];
  function addNotice(status, message) {
    var id = String(Date.now());
    setNotices(function (prev) {
      return [].concat(_toConsumableArray(prev), [{
        id: id,
        content: message,
        status: status
      }]);
    });
    if (status === 'success') {
      setTimeout(function () {
        return setNotices(function (prev) {
          return prev.filter(function (n) {
            return n.id !== id;
          });
        });
      }, 3000);
    }
  }
  function removeNotice(id) {
    setNotices(function (prev) {
      return prev.filter(function (n) {
        return n.id !== id;
      });
    });
  }
  (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.useEffect)(function () {
    _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_2___default()({
      path: '/wp/v2/settings'
    }).then(function (data) {
      setSettings(function (prev) {
        var next = _objectSpread({}, prev);
        SETTINGS_KEYS.forEach(function (key) {
          if (data[key] !== undefined) {
            next[key] = data[key];
          }
        });
        return next;
      });
    })["catch"](function () {
      addNotice('error', (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__.__)('Impossible de charger les paramètres.', 'paris'));
    })["finally"](function () {
      setIsLoading(false);
    });
  }, []);
  function handleChange(key, value) {
    setSettings(function (prev) {
      return _objectSpread(_objectSpread({}, prev), {}, _defineProperty({}, key, value));
    });
  }
  function handleSave() {
    setIsSaving(true);
    var payload = {};
    SETTINGS_KEYS.forEach(function (key) {
      payload[key] = settings[key];
    });
    _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_2___default()({
      path: '/wp/v2/settings',
      method: 'POST',
      data: payload
    }).then(function () {
      addNotice('success', (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__.__)('Paramètres enregistrés.', 'paris'));
    })["catch"](function () {
      addNotice('error', (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__.__)("Une erreur est survenue lors de l'enregistrement.", 'paris'));
    })["finally"](function () {
      setIsSaving(false);
    });
  }
  return wp.element.createElement("div", {
    className: "wrap"
  }, wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_3__.SnackbarList, {
    notices: notices,
    onRemove: removeNotice,
    className: "wp-admin-theme-name-theme-options-page__snackbar-list"
  }), isLoading ? wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_3__.Spinner, null) : wp.element.createElement(wp.element.Fragment, null, wp.element.createElement("div", {
    className: "wp-admin-theme-name-theme-options-page__cards"
  }, wp.element.createElement(_components_MyCard__WEBPACK_IMPORTED_MODULE_4__["default"], {
    settings: settings,
    onChange: handleChange
  })), wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_3__.Button, {
    variant: "primary",
    onClick: handleSave,
    isBusy: isSaving,
    disabled: isSaving,
    className: "wp-admin-theme-name-theme-options-page__submit-button"
  }, (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__.__)('Enregistrer les modifications', 'theme-name'))));
}

/***/ },

/***/ "./admin/components/MyCard.jsx"
/*!*************************************!*\
  !*** ./admin/components/MyCard.jsx ***!
  \*************************************/
(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (/* binding */ StickyButtonCard)
/* harmony export */ });
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @wordpress/i18n */ "@wordpress/i18n");
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_wordpress_i18n__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_components__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/components */ "@wordpress/components");
/* harmony import */ var _wordpress_components__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__);


function StickyButtonCard(_ref) {
  var settings = _ref.settings,
    _onChange = _ref.onChange;
  return wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__.Card, {
    className: "wp-admin-theme-name-theme-options-page__card"
  }, wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__.CardHeader, {
    className: "wp-admin-theme-name-theme-options-page__card-header"
  }, wp.element.createElement("h2", {
    className: "wp-admin-theme-name-theme-options-page__card-header-title"
  }, (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_0__.__)("Carte d'exemple", 'theme-name'))), wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__.CardDivider, null), wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__.CardBody, {
    className: "wp-admin-theme-name-theme-options-page__card-body"
  }, wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__.Flex, {
    direction: "column",
    gap: 4
  }, wp.element.createElement(_wordpress_components__WEBPACK_IMPORTED_MODULE_1__.TextControl, {
    label: (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_0__.__)('Label', 'theme-name'),
    help: (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_0__.__)("Texte d'aide", 'theme-name'),
    value: settings.sarbacane_api_key,
    onChange: function onChange(val) {
      return _onChange('sarbacane_api_key', val);
    },
    __next40pxDefaultSize: true,
    __nextHasNoMarginBottom: true
  }))));
}

/***/ },

/***/ "@wordpress/api-fetch"
/*!**********************************!*\
  !*** external ["wp","apiFetch"] ***!
  \**********************************/
(module) {

module.exports = wp.apiFetch;

/***/ },

/***/ "@wordpress/components"
/*!************************************!*\
  !*** external ["wp","components"] ***!
  \************************************/
(module) {

module.exports = wp.components;

/***/ },

/***/ "@wordpress/element"
/*!*********************************!*\
  !*** external ["wp","element"] ***!
  \*********************************/
(module) {

module.exports = wp.element;

/***/ },

/***/ "@wordpress/i18n"
/*!******************************!*\
  !*** external ["wp","i18n"] ***!
  \******************************/
(module) {

module.exports = wp.i18n;

/***/ }

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		if (!(moduleId in __webpack_modules__)) {
/******/ 			delete __webpack_module_cache__[moduleId];
/******/ 			var e = new Error("Cannot find module '" + moduleId + "'");
/******/ 			e.code = 'MODULE_NOT_FOUND';
/******/ 			throw e;
/******/ 		}
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry needs to be wrapped in an IIFE because it needs to be isolated against other entry modules.
(() => {
var __webpack_exports__ = {};
/*!************************!*\
  !*** ./admin/admin.js ***!
  \************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @wordpress/element */ "@wordpress/element");
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_wordpress_element__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _ThemeOptionPage__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./ThemeOptionPage */ "./admin/ThemeOptionPage.jsx");


document.addEventListener('DOMContentLoaded', function () {
  var root = document.getElementById('wp-admin-theme-name-theme-options-page__root');
  if (!root) {
    return;
  }
  (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.createRoot)(root).render((0,_wordpress_element__WEBPACK_IMPORTED_MODULE_0__.createElement)(_ThemeOptionPage__WEBPACK_IMPORTED_MODULE_1__["default"]));
});
})();

// This entry needs to be wrapped in an IIFE because it needs to be isolated against other entry modules.
(() => {
/*!*************************!*\
  !*** ./scss/admin.scss ***!
  \*************************/
__webpack_require__.r(__webpack_exports__);
// extracted by mini-css-extract-plugin

})();

/******/ })()
;
//# sourceMappingURL=admin.bundle.js.map