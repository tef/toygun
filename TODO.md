# bootstrap
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

# foundation layer

- [ ] scheduler
	- [x] redis
	- [x] test harness
	- [x] redis queue
	- [x] redis lock
	- [x] worker / clock (send uuids in queue)
	- [x] encoded queues {header:v, header:v, body: {msg}}
	- [ ] ttl in header
	- [ ] encrypted queues
	- [ ] scheduler (registry) / try_exclusively
	- [ ] single worker (inspecting scheduler)
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
	- [x] fields operator
	- [x] sti support / subclassing
	- [x] field uses custom encoder to handle Resources, Tasks stored in attrs
	- [ ] field names are checked on save/restore (and thus create/transition)
	- [ ] field schemas are versioned (backfil/write-up)
	- [ ] `field :name, type: Class` optional typecheck
	- [ ] encrypted fields

- [ ] encryption (aka attr_vault)
	- [x] fernet
	- [ ] keyring/Config/rotation {0:fernet_key, 1:...}
	- [ ] EncryptedQueue
	- [ ] encrypted_field

- [ ] api server / client
	- [x] router
	- [ ] server routes to live objects (use sinatra and put in pliny router)
	- [ ] live obejcts get serialized with methods (custom encoder)
		using  reflection for fields, state, associations
 	- [ ] client using decorated json
	- [ ] html interface
	- [ ] breakdown pages / pagination / dataset results
	- [ ] bouncer/auth
	- [ ] cli client / slack bot
	- [ ] caching

- [ ] logging / metrics / errors
	- [ ] log table
	- [ ] notices
	- [ ] queue/tick metrics (max ticks, worker throughput)
	- [ ] error handling / rollbar
	- [ ] notifications

# framework

- [ ] alarms/panics
	- [ ] task or resource can have multiple types of alarm attached
	- [ ] active / snooze / closed life cycle
	- [ ] email, pd, slack
	  i.e task panic/alarm merge

- [ ] states
	- [x] move tick / state def to tasks
	- [x] task.start race from new to first state
	- [ ] customizable archival / expiry
	- [ ] use upserts and avoid advisory locking
	- [ ] start_every (using bucket) / scheduler
	- [ ] circuit breaking
	- [ ] renames
-	- [ ] panic support

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
	- [x] tasks class method
	- [ ] panic state
	- [ ] on_panic :escalate in tasks? maybe panic as exception
	      model, i.e task panics goes up ownership chain until handled
	- [ ] tasks is *active* tasks
	- [ ] task :__new__, task :__stop__ as overrides for start/stop behaviour

# environment/ecosystem/support/examples

- [ ] docs
	- [ ] directory readmes, project root readme
	- [ ] task.md / state.md esque things

- [ ] build
	- [ ] single_worker (clock+worker)
	- [ ] bin/setup bin/teardown
	- [ ] gem / app
	- [ ] split into toygun and app
	- [ ] activesupport date time (ugh)

- [ ] plugins / layering
	- [x] create resources directory
	- [x] attr becomes a sequel plugin
	- [ ] layers: modules (state), plugins (attr&renamable sti), models (resources/tasks)
	- [ ] resource as a plugin eventually
	- [ ] leave open door for custom resource/task combos.


- [ ] maybe
	- [ ] (aws?) example code
	- [ ] something stateless or managed? rds? memcache
	- [ ] heroku addon?

	maybe foo.task.start foo.task.running? Foo.create() start sets state to new & calls create
	then if __new__ transition to latest in tick
