class Postbacks::BulkReflectTimeJob < EntityManagementJob
  def perform(ids = [])
    Postback.where(id: ids).find_each do |postback|
      catch_exception { postback.reflect_time! }
    end
  end
end
