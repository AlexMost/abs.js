Rx = require 'rx'


liftCbToRx = (f) ->
	###
	Lifts function with callback to Rx observable.
	Works by same logic as simple nodejs style callback functions.
	###

	(i, idx, obs) ->
		Rx.Observable.create (observer) ->
			f i, (err, result) ->
				(observer.onError err) if err
				observer.onNext result
				observer.onCompleted()


module.exports = {liftCbToRx}
