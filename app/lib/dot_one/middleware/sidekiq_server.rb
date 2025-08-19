module DotOne::Middleware
  class SidekiqServer
    def call(_worker, job, _queue)
      RequestLocals.set_current_store_id(job['jid'])

      if job.key?('current_user_type') && job.key?('current_user_id')
        set_current_user(job['current_user_type'], job['current_user_id'])
      end

      yield
    ensure
      RequestLocals.clear!
      RequestLocals.set_current_store_id(nil)
    end

    private

    def set_current_user(user_type, user_id)
      RequestLocals.store[:current_user] = user_type.constantize.find(user_id)
    end
  end
end
