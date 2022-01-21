
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  def start(peer_id) do
    IO.puts "-> Peer at #{Helper.node_string()} with ID #{peer_id}"
    receive do
      { :peers_list, peers } -> 
        next(peer_id, peers, 0, peer_id)
    end
  end

  defp next(peer_id, peers, msg_count, parent) do
    receive do
      { :hello, from } -> 
        if msg_count == 0 do
          forward(peers, peer_id)
          next(peer_id, peers, msg_count+1, from)
        else
          next(peer_id, peers, msg_count+1, parent)   
        end
    after
      1_000 -> 
        IO.puts "-> Peer #{peer_id} PID #{inspect(self())} Parent #{parent} Messages seen = #{msg_count}"
        next(peer_id, peers, msg_count, parent)
    end
  end

  def forward(peers, peer_id) do
    unless peers == [] do
      [next_peer | other_peers] = peers
      send next_peer, { :hello, peer_id }
      forward(other_peers, peer_id)
    end
  end
end # Peer

