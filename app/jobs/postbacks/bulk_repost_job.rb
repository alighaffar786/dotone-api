class Postbacks::BulkRepostJob < EntityManagementJob
  def perform(ids = [])
    Postback.where(id: ids).find_each do |postback|
      catch_exception { postback.retrigger! }
    end
  end
end
