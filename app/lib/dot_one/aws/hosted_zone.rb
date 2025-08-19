class DotOne::Aws::HostedZone
  include DotOne::Aws::Credential
  include DotOne::Aws::ResponseHandler

  attr_reader :client

  def client
    @client ||= Aws::Route53::Client.new(
      credentials: get_credentials,
    )
  end

  def poll_change(id)
    handle_response do
      poller = client.wait_until(:resource_record_sets_changed, { id: id }, {
        max_attempts: 5,
        delay: 5,
      })

      poller.change_info
    end
  end

  def create(params = {})
    handle_response do
      resp = client.create_hosted_zone({
        name: params[:name],
        caller_reference: params[:caller_reference],
        hosted_zone_config: {
          private_zone: false,
        },
      })

      {
        hosted_zone_id: resp.hosted_zone.id,
        name_servers: resp.delegation_set.name_servers,
      }
    end
  end

  def list
    handle_response do
      resp = client.list_hosted_zones
      resp.hosted_zones
    end
  end

  def get(id)
    handle_response do
      resp = client.get_hosted_zone(id: id)
      resp.hosted_zone
    end
  end

  def delete(id)
    handle_response do
      client.delete_hosted_zone(id: id)
    end
  end

  def list_records(hosted_zone_id)
    handle_response do
      resp = client.list_resource_record_sets(hosted_zone_id: cleanup_hosted_zone_id(hosted_zone_id))
      resp.resource_record_sets
    end
  end

  def add_record(record, hosted_zone_id)
    handle_response do
      resp = client.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: 'UPSERT',
              resource_record_set: {
                name: record[:name],
                type: record[:type],
                ttl: 300,
                resource_records: [
                  {
                    value: record[:value],
                  },
                ],
              },
            },
          ],
        },
        hosted_zone_id: cleanup_hosted_zone_id(hosted_zone_id),
      })

      resp.change_info
    end
  end

  def delete_record(record, hosted_zone_id)
    handle_response do
      arg = {
        name: record.name,
        type: record.type,
      }

      if record.alias_target
        arg.merge!(alias_target: record.alias_target)
      else
        arg.merge!(
          ttl: record.ttl,
          resource_records: record.resource_records,
        )
      end

      resp = client.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: 'DELETE',
              resource_record_set: arg,
            },
          ],
        },
        hosted_zone_id: cleanup_hosted_zone_id(hosted_zone_id),
      })

      resp.change_info
    end
  end

  def add_alias_target(record, hosted_zone_id)
    handle_response do
      resp = client.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: 'UPSERT',
              resource_record_set: {
                name: record[:name],
                type: 'A',
                alias_target: {
                  dns_name: record[:value],
                  hosted_zone_id: cleanup_hosted_zone_id(record[:hosted_zone_id]),
                  evaluate_target_health: true,
                },
              },
            },
          ],
        },
        hosted_zone_id: cleanup_hosted_zone_id(hosted_zone_id),
      })

      resp.change_info
    end
  end

  def delete_alias_target(record, hosted_zone_id)
    handle_response do
      resp = client.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: 'DELETE',
              resource_record_set: {
                name: record[:name],
                type: 'A',
                alias_target: {
                  dns_name: record[:value],
                  hosted_zone_id: cleanup_hosted_zone_id(record[:hosted_zone_id]),
                  evaluate_target_health: true,
                },
              },
            },
          ],
        },
        hosted_zone_id: cleanup_hosted_zone_id(hosted_zone_id),
      })

      resp.change_info
    end
  end

  private

  def cleanup_hosted_zone_id(hosted_zone_id)
    hosted_zone_id.gsub('/hostedzone/', '')
  end
end
