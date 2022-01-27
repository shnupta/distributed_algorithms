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
      messages = for peer <- peer_list, do: {0, 0}
      broadcast(my_id, peer_list, max_broadcasts, timeout, messages)
  end
end # next

defp broadcast(my_id, peer_list, max_broadcasts, timeout, messages) do
  if max_broadcasts > 0 do
    new_delivered_messages = deliver_to_peers(my_id, peer_list, messages)
    # TODO: Continue from here
    receive do
      { :deliver, peer, peer_id } ->
        new_received_messages = receive_from_peer(new_delivered_messages, peer_id)
    end
    broadcast(my_id, peer_list, max_broadcasts - 1, timeout, new_messages)
  end
end # broadcast

defp deliver_to_peers(my_id, peer_list, messages) do
  if peer_list != [] do
    [peer | peer_rest] = peer_list
    [message_count | message_rest] = messages
    send peer, { :deliver, self(), my_id }
    {sent, received} = message_count
    updated_count = {sent + 1, received}
    [updated_count | deliver_to_peers(my_id, peer_rest, message_rest)]
  else
    messages
  end
end # deliver_to_peers

defp receive_from_peer(messages, peer_id) do
  [message_count | message_rest] = messages
  if peer_id == 0 do
    {sent, received} = message_count
    updated_count = {sent, received + 1}
    [updated_count | message_rest]
  else
    [message_count | receive_from_peer(message_rest, peer_id - 1)]
  end
end # receive_from_peer

end # Peer
