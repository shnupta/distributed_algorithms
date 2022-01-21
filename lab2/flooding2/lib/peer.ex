
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  def start(peer_id) do
    IO.puts "-> Peer at #{Helper.node_string()} with ID #{peer_id}"
    receive do
      { :peers_list, peers } -> 
        next(peer_id, peers, 0)
    end
  end

  defp next(peer_id, peers, msg_count) do
    receive do
      { :hello } -> 
        if msg_count == 0 do
          forward(peers)
        end
        next(peer_id, peers, msg_count + 1)   
    after
      1_000 -> 
        IO.puts "-> Peer #{peer_id} PID #{inspect(self())} Messages seen = #{msg_count}"
        next(peer_id, peers, msg_count)
    end
  end

  def forward(peers) do
    unless peers == [] do
      [next_peer | other_peers] = peers
      send next_peer, { :hello }
      forward(other_peers)
    end
  end
end # Peer

