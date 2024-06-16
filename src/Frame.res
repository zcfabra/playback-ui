open Playback

@react.component
let make = (~frame: Playback.frame, ~isSelected: bool) => {
  <div
    className={`w-full flex items-center space-x-4 text-sm text-zinc-300 ${isSelected
        ? "bg-red-500"
        : ""}`}>
    <span className="text-zinc-500 text-xs"> {frame.file_name->React.string} </span>
    <span className="text-md"> {frame.func_name->React.string} </span>
    <span> {frame.line_no->Belt.Int.toString->React.string} </span>
  </div>
}
