-module(echo_worker_sup).
-behaviour(supervisor).

-define(SERVER, ?MODULE).

-export([start_link/0]).
-export([init/1,
	 start_worker/1]).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_worker(Sock) ->
    supervisor:start_child(?MODULE, [Sock]).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

init([]) ->
    EchoWorker = #{id => echo_worker,
		   restart => transient,
		   start => {echo_worker, start_link, []}},

    Children = [EchoWorker],

    RestartStrategy = {simple_one_for_one, 1, 1},

    {ok, {RestartStrategy, Children}}.
