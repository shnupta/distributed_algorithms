
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

# flood message through 1-hop (fully connected) network

defmodule Flooding do

def start do 
  config = Helper.node_init()
  start(config, config.start_function) 
end # start/0

defp start(_,      :cluster_wait), do: :skip
defp start(config, :cluster_start) do
  IO.puts "-> Flooding at #{Helper.node_string()}"

  # Spawn peer processes
  peers = spawn_peers(config, [], config.n_peers - 1) 
  IO.puts "-> Peers = #{inspect(peers)}"

  # Bind peers according to network configuration
  bind(peers, 0, [1, 6])
  bind(peers, 1, [0, 2, 3])
  bind(peers, 2, [1, 3, 4])
  bind(peers, 3, [1, 2, 5])
  bind(peers, 4, [2])
  bind(peers, 5, [3])
  bind(peers, 6, [0, 7])
  bind(peers, 7, [6, 8, 9])
  bind(peers, 8, [7, 9])
  bind(peers, 9, [7, 8])

  # Send the first peer a hello message
  [first_peer | _tail ] = peers
  IO.puts "Sending #{inspect(first_peer)} a hello"
  send first_peer, { :hello, -1 }

end # start/2

defp spawn_peers(config, peers_list, peers_left) do
  peer = Node.spawn(:'peer#{peers_left}_#{config.node_suffix}', Peer, :start, [peers_left])
  new_peers_list = [peer | peers_list]
  if peers_left == 0 do
    new_peers_list
  else
    spawn_peers(config, new_peers_list, peers_left - 1)
  end
end

defp bind(peers, peer_id, neighbour_ids) do
  bind_neighbours(peers, peer_id, neighbour_ids, nil, [], 0)
end

defp bind_neighbours(peers, peer_id, neighbour_ids, peer, neighbours, i) do
  if peers == [] do 
    send peer, { :peers_list, neighbours }
  else
    [peers_head | peers_tail] = peers
    cond do
      i == peer_id && neighbour_ids == [] -> send peers_head, { :peers_list, neighbours }
      peer != nil && neighbour_ids == [] -> send peer, { :peers_list, neighbours }
      i == peer_id -> bind_neighbours(peers_tail, peer_id, neighbour_ids, peers_head, neighbours, i+1)
      true ->
        if neighbour_ids == [] do
          bind_neighbours(peers_tail, peer_id, neighbour_ids, peer, neighbours, i+1)
        else
          [neighbour_ids_head | neighbour_ids_tail] = neighbour_ids
          if i == neighbour_ids_head do
            bind_neighbours(peers_tail, peer_id, neighbour_ids_tail, peer, [peers_head | neighbours], i+1)
          else
            bind_neighbours(peers_tail, peer_id, neighbour_ids, peer, neighbours, i+1)
          end
        end
    end
  end
end

end # Flooding

