open Utils
type json = Js.Json.t

module Playback = {
  type frame = {
    frame_type: string,
    line_no: int,
    file_name: string,
    fn_name: string,
    locals: Js.Dict.t<json>,
    time_taken: option<float>
  }

  type full = {
    frames: array<frame>,
    files: Js.Dict.t<string>,
  }

  let parseFrame: json => result<frame, string> = src => {
    switch src {
    | Object(potentialFrame) =>
      switch (
        Js.Dict.get(potentialFrame, "frame_type"),
        Js.Dict.get(potentialFrame, "line_no"),
        Js.Dict.get(potentialFrame, "file_name"),
        Js.Dict.get(potentialFrame, "fn_name"),
        Js.Dict.get(potentialFrame, "locals"),
        Js.Dict.get(potentialFrame, "time_taken"),
      ) {
      | (
          Some(String(frame_type)),
          Some(Number(line)),
          Some(String(file_name)),
          Some(String(fn_name)),
          Some(Object(locals)),
          time_taken,
        ) => {
          let frame = {
            frame_type: frame_type,
            line_no: Belt.Float.toInt(line),
            fn_name,
            file_name,
            locals,
            time_taken: switch time_taken{
              | Some(Number(tt)) => Some(tt)
              | None | Some(_) => None
            }
          }
          Ok(frame)
        }
      | _ => Error("Malformed Playback File")
      }
    | _ => Error("Err")
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
      switch (Js.Dict.get(d, "files"), Js.Dict.get(d, "frames")) {
      | (Some(Object(fileMap)), Some(Array(framesToParse))) =>
        switch parseFileMap(fileMap) {
        | Error(e) => Error(e)
        | Ok(fmap) => {
            let playback = {
              frames: framesToParse->Array.map(parseFrame)->Utils.keepOks,
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
