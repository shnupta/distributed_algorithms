
# distributed algorithms, n.dulay, 10 jan 22
# lab3 - broadcast algorithms

# v1 - elixir broadcast

defmodule Broadcast do

def start do 
  config = Helper.node_init()
  start(config, config.start_function) 
end # start/0

defp start(_,      :cluster_wait), do: :skip
defp start(config, :cluster_start) do
  IO.puts "--> Broadcast at #{Helper.node_string()}"

  peers = spawn_peers(config, [], config.n_peers - 1) 
  IO.puts "-> Peers = #{inspect(peers)}"

  for peer <- peers do
    send peer, { :bind, peers }
  end

  for peer <- peers do
    send peer, { :broadcast, 1000, 3000 }
  end

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

end # Broadcast

