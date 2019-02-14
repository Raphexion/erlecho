-module(echo_worker).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

%% =============================================================================
%% API
%% =============================================================================

start_link(Sock) ->
    gen_server:start_link(?MODULE, Sock, []).

%% ====================================================================
%% Behaviour
%% ====================================================================

init(Sock) ->
    {ok, #{sock => Sock}}.

handle_call(What, _From, State) ->
    lager:warning("call [~p] unsupported in ~p", [What, ?MODULE]),
    {reply, {error, What}, State}.

handle_cast(What, State) ->
    lager:warning("cast [~p] unsupported in ~p", [What, ?MODULE]),
    {noreply, State}.

handle_info({tcp, _Port, Data}, State=#{sock := Sock}) ->
    gen_tcp:send(Sock, Data),
    {noreply, State};

handle_info({tcp_closed, _Port}, State) ->
    {stop, normal, State}.

terminate(normal, #{sock := Sock}) ->
    gen_tcp:close(Sock);

terminate(_Reason, _State) ->
    ok.

code_change(_Vsn, State, _Extra) ->
    {ok, State}.
