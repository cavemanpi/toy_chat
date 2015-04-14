-module(toy_chat_server).

-export([start/0, listen/1]).

start() -> 
	spawn_link(toy_chat_server, listen, [#{}]).

listen(Env) ->
	Newenv = receive 
		{create, Name, Replyto} -> 
			Newroom = spawn_link(toy_chat_room, start, [#{parent => self(), name => Name, subscribers => []}]),
			Newroom ! { subscribe, Replyto },
			Env#{ rooms => maps:put(Name, Newroom, maps:get(rooms, Env, #{}))};
		{list, Replyto} ->
			Replyto ! {ok, maps:get(rooms, Env, #{})},
			Env;
		{kill, Name} -> 
			Roompid = maps:get(Name, maps:get(rooms, Env, #{})),
			Roompid ! {stop},
			Env#{ rooms => maps:remove(Name, maps:get(rooms, Env, #{}))};
		{delete, Name} -> 
			Env#{ rooms => maps:remove(Name, maps:get(rooms, Env, #{}))};
		{stop} -> 
			exit(rogue)
	end,
	listen(Newenv).
