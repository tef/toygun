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

- [ ] task/resource attrs
	- [ ] `field :name` generates getter/setter, no diff between nil value and del key
	- [ ] `field :name, Class` optional typecheck / proc
	- [ ] field uses custom encoder to handle Resources, Tasks stored in attrs
	- [ ] s/attrs/json_attrs/
	- [ ] field schemas are versioned (backfil/write-up)
	- [ ] attrs work with STI
	- [ ] encrypted attrs

- [ ] encoding
	- [ ] custom encoder/decoders
	- [ ] redis queue uses custom encoder (sends over versioned message)
	- [ ] attrs uses custom encoder (versioned attrs)
	- [ ] api uses custom encoder (urls)

- [ ] resources
	- [x] spec resource
	- [x] bake in resource lifecycle
	- [x] redis 
	- [x] test harness
	- [x] redis queue
	- [x] redis lock
	- [ ] scheduler / try_exclusively
	- [ ] tick queue / worker / clock / clockwork (copy yobukos)
	- [ ] encoded queues / encrypted queues using attrs like thing to make json string
	- [ ] worker partitoning / priority / worker leases
	- [ ] parenting 
	- [ ] datasets
	- [ ] logs/notices

- [ ] tasks 
	- [ ] should_start? should_stop?
	- [ ] task triggers & subclasses lookup/fixes for task triggers
	- [ ] timeouts / panics

- [ ] states
	- [ ] customizable archival / expiry
	- [ ] task.start race from new to first state
	- [ ] use upserts and avoid advisory locking
	- [ ] bucket starting
	- [ ] circuit breaking


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

- [ ] aws example code
