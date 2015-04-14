-module(toy_chat_room).

-export([start/1]).

start(Env) -> 
	Newenv = receive
		{relay, Message, Alias} -> 
			lists:foreach(fun(Pid) -> Pid ! {message, Alias, Message} end, maps:get(subscribers, Env)),
			Env;
		{subscribe, Replyto} -> 
			Replyto ! {subscribed, maps:get(name, Env)},
			Env#{subscribers => lists:append(maps:get(subscribers, Env, []), [Replyto])};
		{unsubscribe, Replyto} -> 
			Replyto ! {unsubscribed, maps:get(name, Env)},
			Env#{subscribers => lists:delete(Replyto, maps:get(subscribers, Env, []))};
		{stop} -> 
			maps:get(parent, Env) ! {delete, maps:get(name, Env)},
			exit(alike)
	end,
	toy_chat_room:start(Newenv).
