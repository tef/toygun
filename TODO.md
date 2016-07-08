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
	- [ ] scheduler (registry) / try_exclusively
	- [ ] encoded queues / encrypted queues using attrs like thing to make json string
	- [ ] worker partitoning / priority / worker leases
	- [ ] logs/notices
	- [ ] timeouts
	- [ ] threading


- [ ] json attrs
	- [ ] `field :name` generates getter/setter, no diff between nil value and del key
		notes, and just uses #modified!
	- [ ] `field :name, Class` optional typecheck
	- [ ] field uses custom encoder to handle Resources, Tasks stored in attrs
	- [ ] s/attrs/json_attrs/
	- [ ] `field ... do encode ... decode ... end`
	- [ ] fields are checked in start/transition
	- [ ] field schemas are versioned (backfil/write-up)
	- [ ] attrs work with STI
	- [ ] encrypted attrs

- [ ] encryption
	- [x] fernet
	- [ ] keyring/Config
	- [ ] encrypted_field
	- [ ] EncryptedQueue

- [ ] encoding
	- [ ] custom encoder/decoders for embedded objects
	- [ ] custom encoders for fields in hash
			
	- [ ] encrypted decorated json object {'Vault':[key_id, secret]}
	- [ ] redis queue uses custom encoder (sends over versioned message)
	- [ ] attrs uses custom encoder (versioned attrs)
	- [ ] api uses custom encoder (urls)

- [ ] states
	- [ ] customizable archival / expiry
	- [ ] task.start race from new to first state
	- [ ] use upserts and avoid advisory locking
	- [ ] start_every (using bucket) / scheduler
	- [ ] circuit breaking
	- [ ] renames

- [ ] tasks 
	- [ ] should_start? should_stop?
	- [ ] task triggers & subclasses lookup/fixes for task triggers
	- [ ] timeouts / panics
	- [ ] specs for duplicates, leaks in past
	- [ ] missing transition etc
	- [ ] glue to resources? i.e :resource not :parent (cf models layer)

- [ ] resources
	- [x] spec resource
	- [x] bake in resource lifecycle
	- [ ] parenting 
	- [ ] datasets
	- [ ] panic state: panic when tasks are panic
	- [ ] on_panic :escalate in tasks? maybe panic as exception
	      model, i.e task panics goes up ownership chain until handled

- [ ] layering
	- [ ] add in all members of schema into Models
	- [ ] state becomes a sequel plugin (passing in transition table)
	- [ ] attr becomes a sequel plugin
	- [ ] resource, task use plugins, move into models (& out of toygun)
	- [ ] layers: modules (state), plugins (attr), models (resources/tasks)
	- [ ] leave open door for custom resource/task combos.

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

- [ ] (aws?) example code

- [ ] docs
	- [ ] directory readmes, project root readme
	- [ ] task.md / state.md esque things

- [ ] bin/setup bin/teardown
- [ ] gem / app 
	- [ ] split into toygun and app
