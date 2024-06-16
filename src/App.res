open Playback
type json = Js.Json.t

type window
type e = {key: string}
@val @scope("JSON") external parseJson: string => json = "parse"
@val external window: window = "window"
@scope("window") @val
external addEventListener: (string, e => unit) => unit = "addEventListener"
@scope("window") @val
external removeEventListener: (string, e => unit) => unit = "removeEventListener"

module FileReader = {
  type t
  type f

  @new external new: unit => t = "FileReader"
  @set external setOnLoad: (t, _ => unit) => unit = "onload"
  @get external getResult: t => Nullable.t<string> = "result"
  @send external readAsText: (t, f) => unit = "readAsText"
}

@react.component
let make = () => {
  let (fileContent: option<Playback.full>, setFileContent) = React.useState(() => None)
  let (selectedIx, setSelectedIx) = React.useState(() => 0)

  let handleKeyDown = (e, maxBounds) => {
    switch e.key {
    | "ArrowRight" => setSelectedIx(prev => Js.Math.min_int(prev + 1, maxBounds))
    | "ArrowLeft" => setSelectedIx(prev => Js.Math.max_int(prev - 1, 0))
    | _ => ()
    }
  }
  React.useEffect(() => {
    switch fileContent {
    | None => None
    | Some(f) => {
        let maxBounds = Belt.Array.length(f.stack) - 1
        addEventListener("keydown", e => e->handleKeyDown(maxBounds))
        Some(() => removeEventListener("keydown", e => e->handleKeyDown(maxBounds)))
      }
    }
  }, [fileContent])

  let read_file = f => {
    let reader = FileReader.new()
    FileReader.setOnLoad(reader, () => {
      switch Nullable.toOption(FileReader.getResult(reader)) {
      | None => ()
      | Some(result) =>
        switch Playback.parsePlayback(parseJson(result)) {
        | Ok(val) => setFileContent(_ => Some(val))
        | _ => ()
        }
      }
    })
    FileReader.readAsText(reader, f)
  }

  let handleFile = e => {
    let file_list = ReactEvent.Form.currentTarget(e)["files"]
    switch file_list[0] {
    | None => ()
    | Some(f) => f->read_file
    }
  }

  <div className="h-screen w-full p-6 bg-zinc-900 fixed">
    {switch fileContent {
    | Some(_) => <> </>
    | None => <input type_="file" onChange=handleFile />
    }}
    <div className="w-full flex">
      {switch fileContent {
      | None => <> </>
      | Some(f) =>
        <div className="w-3/12 h-36 absolute bottom-8 right-8 bg-zinc-800 rounded-xl">
          {
            let els =
              Belt.Option.getUnsafe(f.stack[selectedIx]).local_vars
              ->Js.Dict.entries
              ->Array.map(((name, val)) =>
                <div className="px-4 text-zinc-300">
                  <span> {`${name}: `->React.string} </span>
                  <span> {val->Js.Json.stringify->React.string} </span>
                </div>
              )
            Array.push(
              els,
              switch Belt.Option.getUnsafe(f.stack[selectedIx]).return_val {
              | None => <> </>
              | Some(rv) =>
                switch rv {
                | Null => <> </>
                | val =>
                  <div className="px-4 text-zinc-300">
                    <span> {"return_val: "->React.string} </span>
                    <span> {val->Js.Json.stringify->React.string} </span>
                  </div>
                }
              },
            )
            els->React.array
          }
        </div>
      }}
      <div className="w-4/12 flex flex-col">
        {switch fileContent {
        | None => <> </>
        | Some(f) =>
          f.stack
          ->Array.mapWithIndex((el, ix) => <Frame isSelected={ix == selectedIx} frame=el />)
          ->React.array
        }}
      </div>
      <div className="w-8/12 text-zinc-300 px-8">
        <pre className="text-zinc-300 w-full">
          {switch fileContent {
          | None => <> </>
          | Some(f) =>
            switch Js.Dict.get(f.files, Belt.Option.getUnsafe(f.stack[selectedIx]).file_name) {
            | None => <span> {React.string("")} </span>
            | Some(code) =>
              code
              ->Js.String2.split("\n")
              ->Array.mapWithIndex((el, ix) =>
                <React.Fragment key={ix->Belt.Int.toString}>
                  <span
                    className={`${ix == Belt.Option.getUnsafe(f.stack[selectedIx]).line_no - 1
                        ? "bg-red-500"
                        : ""}`}>
                    {el->React.string}
                  </span>
                  <br />
                </React.Fragment>
              )
              ->React.array
            }
          }}
        </pre>
      </div>
    </div>
  </div>
}
