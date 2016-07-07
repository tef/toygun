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

- [ ] statable
	- [ ] add resource
	- [ ] spec resource
	- [ ] resource lifecycle
	- [ ] worker / clock / lock
bugs
- [ ] task.start race from new to first state
- [ ] subclasses lookup/fixes
- [ ] internal attrs have internal names
- [ ] use upserts

statable

- [ ] redis & test harness
- [ ] try exclusively
- [ ] worker / clock

automata
- [ ] timeouts /panics
- [ ] jsonb/attr parser/schema
- [ ] fernet encrypt/decrypt
- [ ] panic_state/stop_state

- browser
- [ ] fields / attrs / encoding
- [ ] decorated json api
- [ ] html interface
