import angr
import angr.sim_options as so
import claripy

symbol = 0x10F44
find_addr = 0x10FF8

# Create a project with history tracking
p = angr.Project('./usr/sbin/asusdiscovery')
extras = {so.REVERSE_MEMORY_NAME_MAP, so.TRACK_ACTION_HISTORY}

# User input will be 300 symbolic bytes
user_arg = claripy.BVS("user_arg", 300*8)

# State starts at function address
start_addr = symbol
state = p.factory.blank_state(addr=start_addr, add_options=extras)

# Store symbolic user_input buffer
state.memory.store(0x500000, user_arg)
state.regs.r0 = 0x500000

# Run to exhaustion
simgr = p.factory.simgr(state)
simgr.explore(find=find_addr)

# Print each path and the inputs required
for path in simgr.unconstrained:
  print("{} : {}".format(path,hex([x for x in path.history.bbl_addrs][-1])))
  u_input = path.solver.eval(user_arg, cast_to=bytes)
  print(u_input)

