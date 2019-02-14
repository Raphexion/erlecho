-module(echo_server).
-behaviour(gen_server).

-define(SERVER, ?MODULE).
-define(TCP_OPTIONS, [{active, true},
		      {packet, line},
		      {reuseaddr, true}]).

-export([start_link/0]).
-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

%% =============================================================================
%% API
%% =============================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%====================================================================
%% Behaviour
%%====================================================================

init(_) ->
    {ok, Port} = application:get_env(erlecho, echo_port),
    {ok, LSock} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    {ok, #{lsock => LSock}, 0}.

handle_call(What, _From, State) ->
    lager:warning("call [~p] unsupported in ~p", [What, ?MODULE]),
    {reply, error, State}.

handle_cast(What, State) ->
    lager:warning("cast [~p] unsupported in ~p", [What, ?MODULE]),
    {noreply, State}.

handle_info(timeout, State=#{lsock := LSock}) ->
    case gen_tcp:accept(LSock, 1000) of
	{ok, Sock} ->
	    {ok, Worker} = echo_worker_sup:start_worker(Sock),
	    gen_tcp:controlling_process(Sock, Worker);
	_ ->
	    ok
    end,
    {noreply, State, 0};

handle_info(_What, State) ->
    {noreply, State}.

terminate(normal, #{lsock := LSock}) ->
    gen_tcp:close(LSock);

terminate(_Reason, _State) ->
    ok.

code_change(_Vsn, State, _Extra) ->
    {ok, State}.
