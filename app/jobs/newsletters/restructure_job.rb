class Newsletters::RestructureJob < MaintenanceJob
  def perform
    Newsletter.restructure_attributes
  end
end
