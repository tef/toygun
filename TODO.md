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

- [ ] json attrs
	- [ ] `field :name` generates getter/setter, no diff between nil value and del key
		notes, pouch just uses #modified!
	- [ ] `field :name, Class` optional typecheck / proc
	- [ ] field uses custom encoder to handle Resources, Tasks stored in attrs
	- [ ] s/attrs/json_attrs/
	- [ ] fields are checked in start/transition
	- [ ] field schemas are versioned (backfil/write-up)
	- [ ] attrs work with STI
	- [ ] encrypted attrs

- [ ] encoding
	- [ ] custom encoder/decoders
	- [ ] redis queue uses custom encoder (sends over versioned message)
	- [ ] attrs uses custom encoder (versioned attrs)
	- [ ] api uses custom encoder (urls)

- [ ] encryption
	- [ ] fernet
	- [ ] keyring/Config
	- [ ] decorated json object {'Vault':[key_id, secret]

- [ ] scheduler
	- [x] redis 
	- [x] test harness
	- [x] redis queue
	- [x] redis lock
	- [ ] worker / clock
	- [ ] scheduler / try_exclusively
	- [ ] encoded queues / encrypted queues using attrs like thing to make json string
	- [ ] worker partitoning / priority / worker leases
	- [ ] logs/notices

- [ ] tasks 
	- [ ] should_start? should_stop?
	- [ ] task triggers & subclasses lookup/fixes for task triggers
	- [ ] timeouts / panics
	- [ ] specs for duplicates, leaks in past

- [ ] states
	- [ ] customizable archival / expiry
	- [ ] task.start race from new to first state
	- [ ] use upserts and avoid advisory locking
	- [ ] start_every (using bucket) / scheduler
	- [ ] circuit breaking

- [ ] resources
	- [x] spec resource
	- [x] bake in resource lifecycle
	- [ ] parenting 
	- [ ] datasets

- [ ] api server / client
	- [ ] server using decorated json
	- [ ] reflection for methods, state, associations
 	- [ ] client using decorated json
	- [ ] html interface
	- [ ] breakdown pages
	- [ ] bouncer
	- [ ] cli client
	- [ ] caching

- [ ] logging
	- [ ] log table
	- [ ] queue/tick metrics (max ticks, worker throughput)
	- [ ] error handling

- [ ] (aws?) example code

- [ ] docs
