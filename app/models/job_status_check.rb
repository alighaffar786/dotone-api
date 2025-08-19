class JobStatusCheck < DatabaseRecords::PrimaryRecord
  include ConstantProcessor

  STATUSES = [
    'In Progress',
    'Completed',
    'Error',
  ].freeze

  JOB_TYPES = ['CjFinalizeJob'].freeze

  define_constant_methods(STATUSES, :status)
  define_constant_methods(JOB_TYPES, :job_type)

  validates :status, :job_type, presence: true
  validates :status, inclusion: { in: STATUSES, allow_nil: false }
  validates :job_type, inclusion: { in: JOB_TYPES, allow_nil: false }

  def self.watch(job_type, request_data)
    job = JobStatusCheck.in_progress.create(job_type: job_type, request_data: request_data)

    yield

    job.update(status: JobStatusCheck.status_completed)
  rescue Exception => e
    job.update(status: JobStatusCheck.status_error)
    raise e
  end

  def self.cj_finalize_in_progress?
    cj_finalize_job.in_progress.exists?
  end
end
