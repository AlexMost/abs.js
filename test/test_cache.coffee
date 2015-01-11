{init_cache} = require '../src/cache'

cache_path = './test/fixtures/test_cache.json'
wrong_cache_path = './test/fixtures/testtt_cache.json'


exports.test_init_cache = (test) ->
    init_cache(cache_path)
    .subscribe(
        (cache) ->
            cache_dump = cache.read()

            test.deepEqual(
                cache_dump,
                {modules: "modules", bundles: "bundles"},
                "Wrong cache structure")

            test.ok(
                !cache.isEmpty(),
                "Must be false because cache is not empty")

            test.done()
        (err) ->
            test.ok(false,
                "Must not fail on parsing a valid cache file")
    )


exports.test_init_cache_failure = (test) ->
    init_cache(wrong_cache_path)
    .subscribe(
        (cache) ->
            cache_dump = cache.read()
            test.deepEqual(
                cache_dump, {}, "Must be empty object if not exists")
            test.ok(cache.isEmpty(), "Must be empty cache")
            test.done()
        (err) ->
            test.ok(false, "Must not fail on parsing a valid cache file")
    )