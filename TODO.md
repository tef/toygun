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

- [ ] attrs
	- [ ] `field :name, Class` in 
	- [ ] s/attrs/json_attrs/
	- [ ] attr schemas are versioned (backfil/write-up)
	- [ ] attrs work with STI
	- [ ] encrypted attrs


- [ ] resources
	- [x] spec resource
	- [x] bake in resource lifecycle
	- [x] redis 
	- [x] test harness
	- [ ] redis lock
	- [ ] worker / clock (copy yobukos)
	- [ ] encrypted queues

- [ ] tasks 
	- [ ] should_start? should_stop?
	- [ ] task triggers & subclasses lookup/fixes for task triggers
	- [ ] timeouts /panics

- [ ] states
	- [ ] customizable archival / expiry
	- [ ] task.start race from new to first state
	- [ ] use upserts

- [ ] api server / client
	- [ ] server using decorated json
	- [ ] reflection for methods, state, associations
 	- [ ] client using decorated json
	- [ ] html interface
	- [ ] bouncer
	- [ ] cli client
	- [ ] caching

- [ ] aws example code
- [ ] logging
