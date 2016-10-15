module Main exposing (..)

import Debug exposing (log)
import Html exposing (Html, li, text, ul)
import Html.App exposing (program)
import Http
import Task
import Json.Decode exposing (Decoder, at, int, list, object2, string, (:=))


type alias Person =
    { id : Int, name : String }


type alias People =
    List Person


type alias Model =
    People


type Msg
    = FetchFail Http.Error
    | FetchSucceed People


model : People
model =
    []


view : Model -> Html Msg
view people =
    ul [] (List.map (\person -> (li [] [ text person.name ])) people)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchSucceed people ->
            ( people, Cmd.none )

        FetchFail err ->
            log ("fetch fail: " ++ toString (err)) ( model, Cmd.none )


getPeople : Cmd Msg
getPeople =
    let
        url =
            "http://localhost:8000/people"
    in
        Task.perform FetchFail FetchSucceed (Http.get decodePeople url)


decodePeople : Decoder People
decodePeople =
    at [ "data" ] (list decodePerson)


decodePerson : Decoder Person
decodePerson =
    object2 Person
        ("id" := int)
        ("name" := string)


main : Program Never
main =
    program
        { init = ( model, getPeople )
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
