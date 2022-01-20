
# distributed algorithms, n.dulay, 10 jan 22
# simple client-server, v1

defmodule Client do

def start(server, id) do
  IO.puts "-> Client at #{Helper.node_string()} with ID #{id}"
  next(server, id)
  # receive do
  #   { :bind, server } -> next(server)
  # end # receive
end # start

defp next(server, id) do
  val = Helper.random(100)
  cond do
    val > 0 && val <= 33 ->
      send server, { :circle, self(), 1.0 }
    val > 33 && val <= 66 ->
      send server, { :square, self(), 2.0 }
    val > 66 ->
      send server, { :triangle, self(), 3.0, 3.0, 3.0 } 
  end
  receive do 
    { :result, area } -> IO.puts "Client #{id}: Area is #{area}" 
  end # receive
  Process.sleep(1000 * Helper.random(3))
  next(server, id)
end # next

end # Client

