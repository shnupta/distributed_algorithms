defmodule Peer do

def start(my_id) do
  receive do
    { :bind, peer_list } -> 
      next(my_id, peer_list)
  end
end # start

defp next(my_id, peer_list) do
  receive do
    { :broadcast, max_broadcasts, timeout } ->
      # Create a list of empty counts for each peer (including self)
      # that represent the number of messages broadcast and sent
      messages = for _ <- peer_list, do: {0, 0}
      broadcast(my_id, peer_list, max_broadcasts, timeout, messages)
  end
end # next

defp broadcast(my_id, peer_list, max_broadcasts, timeout, messages) do
  if max_broadcasts > 0 do
    new_delivered_messages = deliver_to_peers(my_id, peer_list, messages)
    receive do
      { :deliver, _peer, peer_id } ->
        new_messages = receive_from_peer(new_delivered_messages, peer_id)
        broadcast(my_id, peer_list, max_broadcasts - 1, timeout, new_messages)
    after 
      timeout -> print_messages(my_id, messages)
    end
  else
    receive do
      { :deliver, _peer, peer_id } ->
        new_messages = receive_from_peer(messages, peer_id)
        broadcast(my_id, peer_list, max_broadcasts, timeout, new_messages)
    after 
      timeout -> print_messages(my_id, messages)
    end
  end
end # broadcast

defp print_messages(my_id, messages) do
  IO.puts("Peer#{my_id}: " <> Enum.map_join(messages, " ", &(inspect(&1))))
end # print_messages

defp deliver_to_peers(my_id, peer_list, messages) do
  Enum.each(peer_list, fn id -> send id, { :deliver, self(), my_id } end)
  Enum.map(messages, fn {s, r} -> {s+1, r} end)
end # deliver_to_peers

defp receive_from_peer(messages, peer_id) do
  {sent, received} = Enum.at(messages, peer_id)
  List.replace_at(messages, peer_id, {sent, received + 1})
end # receive_from_peer

end # Peer
