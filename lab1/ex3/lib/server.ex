
# distributed algorithms, n.dulay, 10 jan 22
# simple client-server, v1

defmodule Server do
 
def start do 
  IO.puts "-> Server at #{Helper.node_string()}"
  next()
end # start
 
defp next do
  receive do
    { :circle, client_id, radius } -> 
      send client_id, { :result, 3.14159 * radius * radius }
    { :square, client_id, side } -> 
      send client_id, { :result, side * side }
    { :triangle, client_id, a, b, c } ->
      s = (a + b + c) / 2.0
      send client_id, { :result,  Helper.sqrt(s * (s-a) * (s-b) * (s-c))}
  end # receive
  next()
end # next

end # Server

