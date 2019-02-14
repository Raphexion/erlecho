%%%-------------------------------------------------------------------
%% @doc erlecho top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erlecho_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

init([]) ->
    ErlEchoServer = #{id => echo_server,
		      start => {echo_server, start_link, []}},

    ErlEchoWorkerSup = #{id => echo_worker_sup,
			 type => supervisor,
			 start => {echo_worker_sup, start_link, []}},

    Children = [ErlEchoServer,
		ErlEchoWorkerSup],

    RestartStrategy = {one_for_one, 1, 1},

    {ok, {RestartStrategy, Children}}.
