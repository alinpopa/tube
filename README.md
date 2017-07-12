## Ok, really nothing to see here, some Pipe abstraction on top of Lwt_io channels

## Why did I do this thing, and not using directly Lwt_io channels (or even better, Async Pipes)?

Because of things like this https://github.com/ocsigen/lwt/issues/345  
Quite easy to do it wrong, so for very basic operations when working with local data,   
we can use this (I surely am), brings a little bit more of a type safety  
into all that write/read value to channels.  

## How to build:

```
opam install jbuilder core lwt
make
```

How to use:

```
let (i, o) = Lwt_io.pipe ();;
module StringMaterial = struct
  type t = string
  let in_chan = i
  let out_chan = o
end;;
module Pipe = Pipe.Make(StringMaterial);;
let (reader, writer) = Pipe.create ();;
Pipe.write "something" writer;;
Lwt.(Pipe.read reader >>= fun s -> Lwt_io.printlf "My fancy value: %s" s);;
```
