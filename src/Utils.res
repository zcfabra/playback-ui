
module Utils = {
  let keepOks = arr => {
    arr
    ->Array.filter(el =>
      switch el {
      | Error(_) => false
      | Ok(_) => true
      }
    )
    ->Array.map(el =>
      switch el {
      | Ok(val) => val
      | Error(_) => assert(false)
      }
    )
  }
}