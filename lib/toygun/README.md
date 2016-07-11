mechanics:

init.rb - empty module

codec.rb  - encoder/decoder (handles dumping objects into json

locks.rb - the locking in redis/pg

queue.rb - the redis queue with a bit of encoding/decoding

state.rb - the state machine methods

resource.rb - a database table that maps to subclasses, with some fields stuffed in jsonb, and a state field

tasks.rb - like resources, but mini state machines that hang off resources

subtasks.rb - some boilerplate for tests

vault.rb - empty but placeholder for crypto

worker.rb - while loop to call tick on uuids in queue

clock.rb - while loop to place uuids on queue
