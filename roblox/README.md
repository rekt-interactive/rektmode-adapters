# rektmode-roblox
Rektmode.gg API adapter for Roblox

This repo contains two scripts:

1. Rektmode api adapter (rektmode-api.lua)
2. Example script for submitting basic scores to rektmode.

## Rektmode api adapter 

It is a very simple library that contains olny two methods:

1. Init(apiKey, env) 

The base method for api initiallization, receives your API KEY and Rektmode Environment name as params

2. SubmitScores(scores)

The only one method to submit all the game scores. It is a simple http post request with required headers.

## Rektmode Manager Example

This is a basic rektmode api controller for a game. 
In this example you can see the simple module script, that can be imported to any module in the game.
This module implemets 4 methods:

1. Initialize() - we should provide an API KEY

2. ProcessTimePlayed() - the basic realization of "Time Played" score. After calling this method, the script starts sending the amount of time played by the player in hours every 20 seconds.

3. ProcessMatchScores() - After each match, it sends the players' scores. Please note the 'legit_from' parameter, which usually requires passing the timestamp of the match's start in the UTC time zone. This is important to prevent players from cheating by starting the game before the tournament begins.

4. ProcessRoundScores() - This method, essentially, is the same, but it is called after each played round in a match. Such scores and metrics are more responsive and dynamic because they do not require a fully played match.

## Conclusion
This code is sufficient to fully integrate a multiplayer PvP game with Rektmode.

Always remember that you can add new types of scores and metrics to meet all the needs and nuances of your game. Flexibility and customization are essential to providing a great gaming experience. If you need any assistance in implementing new features or have any questions, feel free to reach out for help. Happy gaming!

## Documentation

Please, feel invited to familiarize yourself with the complete documentation:

[Swagger](https://api.rektmode.gg/v1/docs)
 
[Notion](https://www.notion.so/rektinteractive/REKTMode-developer-documentation-f66f478ca1d7461b8a1250378cdb7aac)
