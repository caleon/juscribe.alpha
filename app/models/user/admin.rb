class User::Admin < User
  # This is auto loaded by Rails load_path conventions. An Admin has access to everything
  # and can edit everything, but cannot destroy. Only a wheel can without restrictions.
  # Type column in the Users table will use 'Admin' but must reference class in code by
  # User::Admin instead of just Admin.
end