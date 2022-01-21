
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

  # Send all peers the list of neighbours (includes themselves)
  for peer <- peers do
    send peer, { :peer_list, peers }
  end

  # Send the first peer a hello message
  [first_peer | _tail ] = peers
  send first_peer, { :hello }

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

end # Flooding

