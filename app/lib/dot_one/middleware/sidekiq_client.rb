module DotOne::Middleware
  class SidekiqClient
    def call(_worker_class, job, _queue, _redis_pool = nil)
      # Set current user login in job payload
      user = RequestLocals.store[:current_user]
      if user
        job['current_user_type'] = user.class.name
        job['current_user_id'] = user.id
      end

      yield
    end
  end
end
