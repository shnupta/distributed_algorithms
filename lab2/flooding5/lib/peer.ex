
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  def start(peer_id) do
    IO.puts "-> Peer at #{Helper.node_string()} with ID #{peer_id}"
    receive do
      { :peers_list, peers } -> 
        next(peer_id, peers, 0, nil, peer_id, 0)
    end
  end

  defp next(peer_id, peers, hello_count, parent, parent_id, child_count) do
    receive do
      { :hello, from_id, from } -> 
        if hello_count == 0 do
          send from, { :child, 1 } # Tell your parent you are a child
          forward(peers, peer_id)
          next(peer_id, peers, hello_count+1, from, from_id, child_count)
        else
          next(peer_id, peers, hello_count+1, parent, parent_id, child_count)   
        end
      { :child, count } -> 
        send parent, { :child, count } # Pass your children's counts to your parent
        next(peer_id, peers, hello_count, parent, parent_id, child_count+count)
    after
      1_000 -> 
        IO.puts "-> Peer #{peer_id} PID #{inspect(self())} Parent #{parent_id} Messages seen = #{hello_count} Children = #{child_count}"
        next(peer_id, peers, hello_count, parent, parent_id, child_count)
    end
  end

  def forward(peers, peer_id) do
    unless peers == [] do
      [next_peer | other_peers] = peers
      send next_peer, { :hello, peer_id, self() }
      forward(other_peers, peer_id)
    end
  end
end # Peer

