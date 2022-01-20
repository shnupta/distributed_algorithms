
# distributed algorithms, n.dulay, 10 jan 22
# simple client-server, v1

defmodule ClientServer do

def start do 
  config = Helper.node_init()
  start(config, config.start_function) 
end # start

defp start(config, :single_start) do
  IO.puts "-> ClientServer at #{Helper.node_string()}"
  server = Node.spawn(:'clientserver_#{config.node_suffix}', Server, :start, [])
  Process.sleep(5)
  for n <- 1..config.clients do
    _client = Node.spawn(:'clientserver_#{config.node_suffix}', Client, :start, [server, n])
  end
end # start

defp start(_,      :cluster_wait), do: :skip
defp start(config, :cluster_start) do
  IO.puts "-> ClientServer at #{Helper.node_string()}"
  server = Node.spawn(:'server_#{config.node_suffix}', Server, :start, [])
  Process.sleep(5)
  for n <- 1..config.clients do
    _client = Node.spawn(:'client#{n}_#{config.node_suffix}', Client, :start, [server, n])
  end
end # start

end # ClientServer

