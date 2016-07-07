- [x] pliny template
- [x] prune pliny
- [x] subtask.rb
- [x] fix task leak in start / tasks should be unique per invocation
- [x] indexes
- [x] **args
- [x] fix race condition in transition
- [x] s/foreign/parent

bugs
- [ ] task.start race from new to first state

statable
- [ ] split out files, duplicate logic (state.rb, resource.rb, task.rb)
- [ ] statable
- [ ] redis
- [ ] try exclusively
- [ ] worker / clock
- [ ] statable / clock / redis / statable.try_exclusively

automata
- [ ] __internal__ states / __internal__ config
- [ ] def_task
- [ ] subclasses lookup/fixes
- [ ] timeouts, panics, NEW
- [ ] jsonb/attr parser/schema
- [ ] panic_state/stop_state
- [ ] fernet encrypt/decrypt
- [ ] use upserts
- [ ] datasets

- browser
- [ ] decorated json api
- [ ] html interface
