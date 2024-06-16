open Utils
type json = Js.Json.t

module Playback = {
  type frame = {
    line_no: int,
    file_name: string,
    func_name: string,
    return_val: option<json>,
    local_vars: Js.Dict.t<json>,
  }

  type full = {
    stack: array<frame>,
    files: Js.Dict.t<string>,
  }

  let parseFrame: json => result<frame, string> = src => {
    switch src {
    | Object(potentialFrame) =>
      switch (
        Js.Dict.get(potentialFrame, "line_no"),
        Js.Dict.get(potentialFrame, "file_name"),
        Js.Dict.get(potentialFrame, "func_name"),
        Js.Dict.get(potentialFrame, "return_val"),
        Js.Dict.get(potentialFrame, "locals"),
      ) {
      | (
          Some(Number(line)),
          Some(String(file_name)),
          Some(String(func_name)),
          Some(return_val),
          Some(Object(local_vars)),
        ) => {
          let frame = {
            line_no: Belt.Float.toInt(line),
            func_name,
            file_name,
            return_val: Some(return_val),
            local_vars,
          }
          Ok(frame)
        }
      | _ => Error("Malformed Playback File")
      }
    | _ => Error("")
    }
  }
  let parseFileMap: Js.Dict.t<json> => result<Js.Dict.t<string>, string> = src => {
    let newDict = Js.Dict.empty()
    Js.Dict.entries(src)->Belt.Array.forEach(((k, v)) => {
      switch v {
        | String(strVal) => Js.Dict.set(newDict, k, strVal)
        | _ => ()
      }
    })
    Ok(newDict)
  }

  let parsePlayback: json => result<full, string> = src => {
    switch src {
    | Object(d) =>
      switch (Js.Dict.get(d, "files"), Js.Dict.get(d, "stack")) {
      | (Some(Object(fileMap)), Some(Array(framesToParse))) =>
        switch parseFileMap(fileMap) {
        | Error(e) => Error(e)
        | Ok(fmap) => {
            let playback = {
              stack: framesToParse->Array.map(parseFrame)->Utils.keepOks,
              files: fmap,
            }
            Ok(playback)
          }
        }
      | _ => Error("Required Fields `files` and `stack` are not present")
      }
    | _ => Error("Failed to parse")
    }
  }
}
