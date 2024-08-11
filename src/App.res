open Playback
type json = Js.Json.t

// type window
type e = {key: string}
@val @scope("JSON") external parseJson: string => json = "parse"
// @val external window: window = "window"

@scope("window") @val
external addEventListener: (string, e => unit) => unit = "addEventListener"
@scope("window") @val
external removeEventListener: (string, e => unit) => unit = "removeEventListener"

type scrollIntoViewOptions = {
  behaviour: string,
  block: string,
  inline: string,
}

@send external scrollIntoView: (Dom.element, scrollIntoViewOptions) => unit = "scrollIntoView"

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
  let selectedLineRef = React.useRef(Nullable.null)

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
        let maxBounds = Belt.Array.length(f.frames) - 1
        addEventListener("keydown", e => e->handleKeyDown(maxBounds))
        Some(() => removeEventListener("keydown", e => e->handleKeyDown(maxBounds)))
      }
    }
  }, [fileContent])

  React.useEffect1(() => {
    switch selectedLineRef.current->Js.Nullable.toOption {
    | Some(el) => scrollIntoView(el, {behaviour: "smooth", block: "center", inline: "center"})
    | None => ()
    }
    None
  }, [selectedIx])

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
        <div className="w-3/12 h-36 flex flex-col absolute bottom-8 right-8 bg-zinc-800 rounded-xl ">
          <span className="text-lg mx-4 my-2 text-zinc-300 font-medium"> {""->React.string} </span>
          {
            let els =
              Belt.Option.getUnsafe(f.frames[selectedIx]).locals
              ->Js.Dict.entries
              ->Array.map(((name, val)) =>
                <div className="px-4 text-zinc-300">
                  <span> {`${name}: `->React.string} </span>
                  <span> {val->Js.Json.stringify->React.string} </span>
                </div>
              )
            Array.push(
              els,
              switch Belt.Option.getUnsafe(f.frames[selectedIx]).time_taken {
              | None => <> </>
              | Some(rv) =>
                switch rv {
                | val =>
                  <div className="px-4 text-zinc-200 font-semibold">
                    <span> {"Time Taken: "->React.string} </span>
                    <span> {val->Belt.Float.toString->React.string} </span>
                  </div>
                }
              },
            )
            els->React.array
          }
        </div>
      }}
      <div className="w-4/12 h-32 flex flex-col overflow-y-auto">
        {switch fileContent {
        | None => <> </>
        | Some(f) =>
          f.frames
          ->Array.mapWithIndex((el, ix) => <Frame isSelected={ix == selectedIx} frame=el />)
          ->React.array
        }}
      </div>
      <div className="w-8/12 text-zinc-300 px-8 h-screen overflow-y-auto ">
        <pre className="text-zinc-300 w-full">
          {switch fileContent {
          | None => <> </>
          | Some(f) =>
            switch Js.Dict.get(f.files, Belt.Option.getUnsafe(f.frames[selectedIx]).file_name) {
            | None => <span> {React.string("[FILE NOT FOUND]")} </span>
            | Some(code) =>
              code
              ->Js.String2.split("\n")
              ->Array.mapWithIndex((el, ix) => {
                let is_selected = ix == Belt.Option.getUnsafe(f.frames[selectedIx]).line_no - 1

                if is_selected {
                  <React.Fragment key={ix->Belt.Int.toString}>
                    <span ref={ReactDOM.Ref.domRef(selectedLineRef)} className="bg-red-500">
                      {el->React.string}
                    </span>
                    <br />
                  </React.Fragment>
                } else {
                  <React.Fragment key={ix->Belt.Int.toString}>
                    <span> {el->React.string} </span>
                    <br />
                  </React.Fragment>
                }
              })
              ->React.array
            }
          }}
        </pre>
      </div>
    </div>
  </div>
}
