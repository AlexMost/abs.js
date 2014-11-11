Rx = require 'rx'
parse_config = require './config_parser'
{get_recipe_data} = require 'recipejs'
{liftCbToRx} = require './lib'


module_to_observable = (config, recipe, mod) ->
	console.log '----- module -------', mod.name
	Rx.Observable.create (observer) ->
		observer.onNext mod
		observer.onCompleted()


abs = (config) -> (recipe_path) ->

	config_source = Rx.Observable.return (parse_config config)
	recipe_source = (liftCbToRx get_recipe_data) recipe_path
	config_and_recipe_source = Rx.Observable.concat(config_source, recipe_source).toArray().first()

	modules_source = config_and_recipe_source.map(([config, recipe]) ->

		modules = recipe.modules.map (m) ->
			module_to_observable config, recipe, m

		Rx.Observable.fromArray(modules))
		.flatMap((x) -> x).concatAll()

	bundles_source = Rx.Observable.fromArray(
		recipe_source.map((r) -> r.bundles).first())

	modules_source.subscribe(
		(m) -> console.log m
		(er) -> console.log 'err', er
		() -> console.log 'done'
	)


module.exports = abs