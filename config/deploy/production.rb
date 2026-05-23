# Production server definition.
#
# A single server fills all three roles (web/app/db). When you split
# tiers, list each server with the roles it serves.
server "voicesforchrist.net",
  user:    "vfcnet",
  roles:   %w{web app db},
  primary: true
