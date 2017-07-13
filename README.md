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
> module StringMaterial = struct type t = string end;;
module StringMaterial : sig type t = string end
>  module Pipe = Tube_lib.Make(StringMaterial);;
module Pipe :
	sig
		type t = string
		type reader = Tube__Tube_lib.Make(StringMaterial).reader
		type writer = Tube__Tube_lib.Make(StringMaterial).writer
		val create : unit -> reader * writer
		val write : t -> writer -> unit Lwt.t
		val read : reader -> t Lwt.t
	end
> let (reader, writer) = Pipe.create ();;
val reader : Pipe.reader = <abstr>
val writer : Pipe.writer = <abstr>
> Pipe.write "something" writer;;
- : unit = ()
> Lwt.(Pipe.read reader >>= fun s -> Lwt_io.printlf "My fancy value: %s" s);;
My fancy value: something
- : unit = ()
> Pipe.write 911 writer;;
Error: This expression has type int but an expression was expected of type
				string
```

or, for custom data types:

```
> type roman_numeral = I | II | III | IV | V | VI | VII | VIII | IX | X;;
type roman_numeral = I | II | III | IV | V | VI | VII | VIII | IX | X
> module RomanMaterial = struct type t = roman_numeral end;;
module RomanMaterial : sig type t = roman_numeral end
> module Pipe = Tube_lib.Make(RomanMaterial);;
module Pipe :
	sig
		type t = roman_numeral
		type reader = Tube__Tube_lib.Make(RomanMaterial).reader
		type writer = Tube__Tube_lib.Make(RomanMaterial).writer
		val create : unit -> reader * writer
		val write : t -> writer -> unit Lwt.t
		val read : reader -> t Lwt.t
	end
> let (reader, writer) = Pipe.create ();;
val reader : Pipe.reader = <abstr>
val writer : Pipe.writer = <abstr>
> Pipe.write IX writer;;
- : unit = ()
> Lwt.(Pipe.read reader >>= fun s ->
match s with
| IX -> Lwt_io.printl "9"
| _ -> Lwt_io.printl "Don't care...");;
9
- : unit = ()
> Pipe.write "not cool" writer;;
Error: This expression has type string but an expression was expected of type
				roman_numeral
```
