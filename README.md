# FindUnusedMethods

Unused method finder using PPI.

```
% carton exec -- bin/find-unused-methods.pl lib/**/** bin/*
lib/FindUnusedMethod.pm#L82     this_is_unused_method
```

## TODO

- Detect methods called from template engines, ex: `user.name`
- Detect methods dynamically called, ex: `$self->$method`
- Detect method called from frameworks, ex: `TheSchwartz::Worker#max_retries`