// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "./Utils.res.mjs";
import * as Js_dict from "rescript/lib/es6/js_dict.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";

function parseFrame(src) {
  if (!Array.isArray(src) && (src === null || typeof src !== "object") && typeof src !== "number" && typeof src !== "string" && typeof src !== "boolean") {
    return {
            TAG: "Error",
            _0: ""
          };
  }
  if (!(typeof src === "object" && !Array.isArray(src))) {
    return {
            TAG: "Error",
            _0: ""
          };
  }
  var match = Js_dict.get(src, "line_no");
  var match$1 = Js_dict.get(src, "file_name");
  var match$2 = Js_dict.get(src, "func_name");
  var match$3 = Js_dict.get(src, "return_val");
  var match$4 = Js_dict.get(src, "locals");
  if (match === undefined) {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (!Array.isArray(match) && (match === null || typeof match !== "object") && typeof match !== "number" && typeof match !== "string" && typeof match !== "boolean") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (typeof match !== "number") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (match$1 === undefined) {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (!Array.isArray(match$1) && (match$1 === null || typeof match$1 !== "object") && typeof match$1 !== "number" && typeof match$1 !== "string" && typeof match$1 !== "boolean") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (typeof match$1 !== "string") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (match$2 === undefined) {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (!Array.isArray(match$2) && (match$2 === null || typeof match$2 !== "object") && typeof match$2 !== "number" && typeof match$2 !== "string" && typeof match$2 !== "boolean") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (typeof match$2 !== "string") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (match$3 === undefined) {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (match$4 === undefined) {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (!Array.isArray(match$4) && (match$4 === null || typeof match$4 !== "object") && typeof match$4 !== "number" && typeof match$4 !== "string" && typeof match$4 !== "boolean") {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  if (!(typeof match$4 === "object" && !Array.isArray(match$4))) {
    return {
            TAG: "Error",
            _0: "Malformed Playback File"
          };
  }
  var frame_line_no = match | 0;
  var frame_return_val = match$3;
  var frame = {
    line_no: frame_line_no,
    file_name: match$1,
    func_name: match$2,
    return_val: frame_return_val,
    local_vars: match$4
  };
  return {
          TAG: "Ok",
          _0: frame
        };
}

function parseFileMap(src) {
  var newDict = {};
  Belt_Array.forEach(Js_dict.entries(src), (function (param) {
          var v = param[1];
          if (!Array.isArray(v) && (v === null || typeof v !== "object") && typeof v !== "number" && typeof v !== "string" && typeof v !== "boolean") {
            return ;
          }
          if (typeof v !== "string") {
            return ;
          }
          newDict[param[0]] = v;
        }));
  return {
          TAG: "Ok",
          _0: newDict
        };
}

function parsePlayback(src) {
  if (!Array.isArray(src) && (src === null || typeof src !== "object") && typeof src !== "number" && typeof src !== "string" && typeof src !== "boolean") {
    return {
            TAG: "Error",
            _0: "Failed to parse"
          };
  }
  if (!(typeof src === "object" && !Array.isArray(src))) {
    return {
            TAG: "Error",
            _0: "Failed to parse"
          };
  }
  var match = Js_dict.get(src, "files");
  var match$1 = Js_dict.get(src, "stack");
  if (match === undefined) {
    return {
            TAG: "Error",
            _0: "Required Fields `files` and `stack` are not present"
          };
  }
  if (!Array.isArray(match) && (match === null || typeof match !== "object") && typeof match !== "number" && typeof match !== "string" && typeof match !== "boolean") {
    return {
            TAG: "Error",
            _0: "Required Fields `files` and `stack` are not present"
          };
  }
  if (!(typeof match === "object" && !Array.isArray(match))) {
    return {
            TAG: "Error",
            _0: "Required Fields `files` and `stack` are not present"
          };
  }
  if (match$1 === undefined) {
    return {
            TAG: "Error",
            _0: "Required Fields `files` and `stack` are not present"
          };
  }
  if (!Array.isArray(match$1) && (match$1 === null || typeof match$1 !== "object") && typeof match$1 !== "number" && typeof match$1 !== "string" && typeof match$1 !== "boolean") {
    return {
            TAG: "Error",
            _0: "Required Fields `files` and `stack` are not present"
          };
  }
  if (!Array.isArray(match$1)) {
    return {
            TAG: "Error",
            _0: "Required Fields `files` and `stack` are not present"
          };
  }
  var e = parseFileMap(match);
  if (e.TAG !== "Ok") {
    return {
            TAG: "Error",
            _0: e._0
          };
  }
  var playback_stack = Utils.Utils.keepOks(match$1.map(parseFrame));
  var playback_files = e._0;
  var playback = {
    stack: playback_stack,
    files: playback_files
  };
  return {
          TAG: "Ok",
          _0: playback
        };
}

var Playback = {
  parseFrame: parseFrame,
  parseFileMap: parseFileMap,
  parsePlayback: parsePlayback
};

export {
  Playback ,
}
/* No side effect */
