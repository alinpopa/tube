module type Material = sig
  type t
end

module type Pipe = sig
  type t
  type reader
  type writer
  val create : unit -> reader * writer
  val write : t -> writer -> unit Lwt.t
  val read : reader -> t Lwt.t
end

module Make(M : Material) : (Pipe with type t = M.t) = struct
  type t = M.t

  type reader = Lwt_io.input_channel
  type writer = Lwt_io.output_channel

  let create () = Lwt_io.pipe ()

  let write v chan = Lwt_io.write_value chan v
  let read chan = Lwt_io.read_value chan
end