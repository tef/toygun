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
- [x] redis
- [x] test harness
- [x] redis queue
- [x] redis lock
- [x] worker / clock (send uuids in queue)
- [x] encoded queues {header:v, header:v, body: {msg}}
- [x] encrypted queues
- [x] ttl in header
- [x] `field :name` generates getter/setter, no diff between nil value and del key
	notes, and just uses #modified!
- [x] attrs is a sequel plugin
- [x] hide the json field, and only allow it through accessors
	sequel :composition on json_attrs/attrs
- [x] fields operator
- [x] sti support / subclassing
- [x] field uses custom encoder to handle Resources, Tasks stored in attrs
- [x] encrypted fields
- [x] fernet
- [x] config glue
- [x] keyring/Config/rotation {0:fernet_key, 1:...}
- [x] EncryptedQueue
- [x] encrypted_field
- [x] move tick / state def to tasks
- [x] task.start race from new to first state
- [x] spec resource
- [x] bake in resource lifecycle
- [x] parenting
- [x] datasets
- [x] tasks class method

# foundation layer

- [ ] scheduler
	- [ ] scheduler (dataset/queue registry) / try_exclusively
	- [ ] timeouts
	- [ ] threading
	- [ ] single worker (inspecting scheduler)
	- [ ] worker partitoning / priority / worker leases
	- [ ] rate limiting / tick quotas (time usage ala cpu scheduling)
	- [ ] error handling
	- [ ] Tickable

- [ ] json attrs
	- [ ] field names are checked on save/restore (and thus create/transition)
		maybe move things found into a "__lost_found__" attr
		don't let unknown fields get written down
	- [ ] field schemas are versioned (backfil/write-up)
	- [ ] `field :name, type: Class` optional typecheck

- [ ] api server / client
	- [x] router
	- [ ] actions / inspection of tasks/fields
	- [ ] return instances with fields, tasks, actions
 	- [ ] http client
	- [ ] html interface
	- [ ] breakdown pages / pagination / dataset results
	- [ ] bouncer / auth
	- [ ] cli client / slack bot
	- [ ] caching
	- [ ] py/js api 

- [ ] logging / metrics / errors
	- [ ] log table
	- [ ] notices/events/messages
	- [ ] queue/tick metrics (max ticks, worker throughput)
	- [ ] error handling / rollbar
	- [ ] notifications

- [ ] states
	- [ ] timeout on pause, go to TIMEOUT 
	- [ ] __exit__ state for cleanup (alarms, also aborts (deallocating)
	- [ ] triggers? (alarm checks, task ticks)
	      idea of Tickable, and you inspect rather than call tick
	- [ ] customizable archival / expiry
	- [ ] use upserts and avoid advisory locking
	- [ ] start_every (using bucket) / scheduler
	- [ ] circuit breaking
	- [ ] renames

- [ ] errors, alarms
	before: resources had alarms (as tasks)
		tasks had task panics (by action)
	instead:
		tasks have errors
			uuid, resource_uuid, task_uuid, error_name, timestamp, attrs
		resources have error reporters
			uuid, resource_uuid, action, task_uuid, error_uuid?, state, attrs

	maybe error stored as obj in attrs, not table
	or err stored in transitions

	subclass error to make custom errors in tasks
		class MissingPrimary < Err ... end
	task errors by calling panic with class
		panic Class, "message"
		default err for string panics
	task transitions to panic state, creates error
		saves error in attrs, clear on transition out
		(or move to last_error)

	so, resource tick can do something if task is in panic
	
	tasks define alarms :error, :timeout,	
	task alarms get passed in active task if it exists
	alarm :failover_error do failover_task.state == ERROR end		

	resources can have alarms
		like taskpanics, but with a link to resource + optionally
		task or error. state machine indicates success of 
		alarm process (like pager duty)
		open/close/ignore/unignore methods
	alarms can have triggers/start when/stop/when


	defining a task creates an alarm for that task
		alarm checks if task is running + in panic/timeout
		pulls error out + opens alarm
		alarm :
		
	should allow: task_stuck alarms
# framework/model

- [ ] availability / restarting life cycle
	online/offline/uncertain/known_offline
	restarting 

- [ ] message templates

- [ ] tasks
	- [ ] Foo.task is shorthand for T < Task, Foo.add_task(T, :name)
	- [ ] should_start? should_stop?
	- [ ] rate limits ? every n.hours? repeating jobs?
	- [ ] task triggers & subclasses lookup/fixes for task triggers
	- [ ] specs for duplicates, leaks in past
	- [ ] missing transition etc

- [ ] resources
	- [ ] panic state
	- [ ] on_panic :escalate in tasks? maybe panic as exception
	      model, i.e task panics goes up ownership chain until handled
	- [ ] tasks is *active* tasks
	- [ ] task :__new__, task :__stop__ as overrides for start/stop behaviour
	- [ ] archival, task :__gc__ cleans up old tasks/transitions/errors

- [ ] tickets ?
	i.e notices/notifications

# environment/ecosystem/support/examples


- [ ] specs
	- [ ] queue
	- [ ] task
	- [ ] resource
	- [ ] state
	- [ ] codec / secret
	- [ ] clock
	- [ ] worker

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
	- [ ] state module becomes a plugin, takes transition table, field name argumentss
	- [ ] resource (tickable+attrs+state+task+scheduler) becomes an example model
	- [ ] layers: modules (state), plugins (attr), models (resources/tasks)
	- [ ] resource as a plugin eventually
	- [ ] leave open door for custom resource/task combos.


- [ ] maybe
	- [ ] (aws?) example code
	- [ ] something stateless or managed? rds? memcache
	- [ ] heroku addon?

	maybe foo.task.start foo.task.running? Foo.create() start sets state to new & calls create
	then if __new__ transition to latest in tick

	transition foo, "a message to log"

- ideas

	monitoring/alerting/playbooks/recovery progression

	i.e install it, monitor things, categorise services

	then provision/automate

deconstructing an object to allow it to be
	serializable
	re-entrant
- resources as objects
- tasks as methods
- fields as attributes
- panics as exceptions


