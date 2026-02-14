-module(zipbeam_ffi).
-export([create_in_memory/1, open/1, close/1, files/1, get/2]).

-include("../include/zipbeam_File.hrl").
-include_lib("kernel/include/file.hrl").
-include_lib("stdlib/include/zip.hrl").

open(Zip) ->
    case zip:zip_open(Zip, [memory]) of
        {ok, Handle} -> {ok, Handle};
        {error, _} -> {error, nil}
    end.

close(Handle) ->
    _ = zip:zip_close(Handle),
    nil.

files(Handle) ->
    % The Erlang zip is based around a process, for some reason. It also goes
    % against best practices and does not use gen_server or even timeouts, so 
    % if you try to use it after the process exits then it hangs forever.
    % This check attempts to prevent that, but there is a race condition here.
    % Good luck.
    case erlang:is_process_alive(Handle) of
        false ->
            {error, nil};
        true ->
            case zip:zip_list_dir(Handle) of
                {ok, [#zip_comment{} | Files]} ->
                    {ok, lists:map(fun convert_file/1, Files)};
                {error, _} ->
                    {error, nil}
            end
    end.

create(Name, Files, Options) ->
    F = fun({A, B}) ->
        {unicode:characters_to_list(A), B}
    end,
    zip:zip(Name, lists:map(F, Files), Options).

create_in_memory({zip_builder, Files}) ->
    {ok, {_, Data}} = create(<<"archive.zip">>, Files, [memory]),
    Data.

convert_file(#zip_file{name = Path, info = #file_info{size = Size}}) ->
    #file{
        path = unicode:characters_to_binary(Path),
        size_bytes = Size
    }.

get(Handle, Name) ->
    % The Erlang zip is based around a process, for some reason. It also goes
    % against best practices and does not use gen_server or even timeouts, so 
    % if you try to use it after the process exits then it hangs forever.
    % This check attempts to prevent that, but there is a race condition here.
    % Good luck.
    case erlang:is_process_alive(Handle) of
        false ->
            {error, nil};
        true ->
            case zip:zip_get(Name, Handle) of
                {ok, {_, Data}} -> {ok, Data};
                {error, file_not_found} -> {error, nil}
            end
        end.
