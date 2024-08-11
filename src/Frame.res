open Playback

type scrollIntoViewOptions = {
  behaviour: string,
  block: string,
  inline: string,
}

@send external scrollIntoView: (Dom.element, scrollIntoViewOptions) => unit = "scrollIntoView"


@react.component
let make = (~frame: Playback.frame, ~isSelected: bool) => {

  <div
    className={`w-full flex items-center space-x-4 text-sm text-zinc-300 ${isSelected
        ? "bg-red-500"
        : ""}`}>
    <span className="text-zinc-500 text-xs w-1/12">
      {frame.file_name
      ->Js.String2.split("/")
      ->Array.last
      ->Option.getOr("Hi")
      ->React.string}
    </span>
    <span className="w-1/12"> {frame.line_no->Belt.Int.toString->React.string} </span>
    <span className="text-md w-2/12"> {frame.fn_name->React.string} </span>
    <span className="text-md w-1/12"> {frame.frame_type->React.string} </span>
  </div>
}
