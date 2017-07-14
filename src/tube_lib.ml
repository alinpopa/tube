module type Pipe = sig
  type t
  type reader
  type writer
  val create : unit -> reader * writer
  val write : t -> writer -> unit Lwt.t
  val read : reader -> t Lwt.t
end

module Make(Material : sig type t end) : (Pipe with type t = Material.t) = struct
  type t = Material.t

  type reader = Lwt_io.input_channel
  type writer = Lwt_io.output_channel

  let create () = Lwt_io.pipe ()

  let write v chan =
    let open Lwt.Infix in
    let (i, o) = Lwt_io.pipe () in
    Lwt_io.write_value ~flags:[Marshal.Closures] chan (v, o) >>= fun _ ->
    Lwt_io.read_value i >>= fun _ ->
    Lwt.return ()

  let read chan =
    let open Lwt.Infix in
    Lwt_io.read_value chan >>= fun (v, o) ->
    Lwt_io.printl "Got some data..." >>= fun _ ->
    Lwt_io.write_value o v >>= fun _ ->
    Lwt.return v
end

module BoolPipe = Make(struct type t = bool end)
module StringPipe = Make(struct type t = string end)
module IntPipe = Make(struct type t = int end)
module CharPipe = Make(struct type t = char end)
