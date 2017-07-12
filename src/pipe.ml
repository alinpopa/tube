module type Material = sig
  type t
  val in_chan : Lwt_io.input_channel
  val out_chan : Lwt_io.output_channel
end

module type Pipe = sig
  type t
  type reader = Reader of (unit -> t Lwt.t)
  type writer = Writer of (t -> unit Lwt.t)
  val create : unit -> reader * writer
  val write : t -> writer -> unit Lwt.t
  val read : reader -> t Lwt.t
end

module Make(M : Material) : (Pipe with type t = M.t) = struct
  type t = M.t

  type reader = Reader of (unit -> t Lwt.t)
  type writer = Writer of (t -> unit Lwt.t)

  let create () : (reader * writer) =
    let out_fun = fun (x : t) : (unit Lwt.t) ->
      Lwt_io.write_value M.out_chan x in
    let in_fun = fun () : (t Lwt.t) ->
      Lwt_io.read_value M.in_chan in
    (Reader in_fun, Writer out_fun)

  let write v w =
    match w with Writer f -> f v

  let read r =
    match r with Reader f -> f ()
end
