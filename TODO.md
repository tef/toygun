- [x] pliny template
- [x] prune pliny
- [x] subtask.rb
- [x] fix task leak in start / tasks should be unique per invocation
- [x] indexes
- [x] **args
- [x] fix race condition in transition
- [x] s/foreign/parent
- [x] __internal__ states / __internal__ config
- [x] split out files, duplicate logic (state.rb, resource.rb, task.rb)
- [x] def_task
- [x] datasets
- [x] resource
- [x] codec / specs for decorated json
- [x] internal attrs have internal names



- [ ] scheduler
	- [x] redis
	- [x] test harness
	- [x] redis queue
	- [x] redis lock
	- [x] worker / clock (send uuids in queue)
	- [ ] encoded queues {header:v, header:v, body: {msg}}
	- [ ] ttls
	- [ ] encrypted queues
	- [ ] scheduler (registry) / try_exclusively
	- [ ] timeouts
	- [ ] threading
	- [ ] worker partitoning / priority / worker leases
	- [ ] rate limiting
	- [ ] error handling

- [ ] json attrs
	- [x] `field :name` generates getter/setter, no diff between nil value and del key
		notes, and just uses #modified!
	- [x] attrs is a sequel plugin
	- [x] hide the json field, and only allow it through accessors
		sequel :composition on json_attrs/attrs
	- [x] field uses custom encoder to handle Resources, Tasks stored in attrs
	- [ ] field names are checked on save/restore
	- [ ] sti support / subclassing
	- [ ] encrypted fields
	- [ ] `field :name, type: Class` optional typecheck
	- [ ] field schemas are versioned (backfil/write-up)

- [ ] encryption
	- [x] fernet
	- [ ] keyring/Config
	- [ ] EncryptedQueue
	- [ ] encrypted_field

- [ ] encoding
	- [x] custom encoders for fields in hash
	- [x] attrs uses custom encoder
	- [ ] redis queue uses custom encoder (sends over versioned message)
	- [ ] api uses custom encoder (urls)

- [ ] states
	- [ ] timeouts / panics
	- [ ] customizable archival / expiry
	- [ ] task.start race from new to first state
	- [ ] use upserts and avoid advisory locking
	- [ ] start_every (using bucket) / scheduler
	- [ ] circuit breaking
	- [ ] renames

- [ ] tasks
	- [ ] should_start? should_stop?
	- [ ] rate limits ? every n.hours? buckets?
	- [ ] task triggers & subclasses lookup/fixes for task triggers
	- [ ] specs for duplicates, leaks in past
	- [ ] missing transition etc

- [ ] resources
	- [x] spec resource
	- [x] bake in resource lifecycle
	- [x] parenting
	- [x] datasets
	- [ ] panic state
	- [ ] on_panic :escalate in tasks? maybe panic as exception
	      model, i.e task panics goes up ownership chain until handled

- [ ] api server / client
	- [ ] server using decorated json / remote datasets / remote objects
	- [ ] reflection for methods, state, associations
 	- [ ] client using decorated json
	- [ ] html interface
	- [ ] breakdown pages
	- [ ] bouncer
	- [ ] cli client
	- [ ] caching

- [ ] logging / metrics / errors
	- [ ] log table
	- [ ] queue/tick metrics (max ticks, worker throughput)
	- [ ] error handling / rollbar
	- [ ] notifications


- [ ] docs
	- [ ] directory readmes, project root readme
	- [ ] task.md / state.md esque things

- [ ] build
	- [ ] bin/setup bin/teardown
	- [ ] gem / app
	- [ ] split into toygun and app
	- [ ] activesupport date time (ugh)

- [ ] plugins / layering
	- [x] create resources directory
	- [x] attr becomes a sequel plugin
	- [ ] state etc is still methods  (passing in transition table)
	- [ ] layers: modules (state), plugins (attr), models (resources/tasks)
	- [ ] resource as a plugin?
	- [ ] leave open door for custom resource/task combos.

	sti plugin with renames + task stuff
	so like Resource should be resource, Resource::Task should be resource:task_name
	maybe foo.task.start foo.task.running? Foo.create() start sets state to new & calls create
	then if __new__ transition to latest in tick

- [ ] (aws?) example code
