class AppointmentDateValidator < ActiveModel::Validator

  def validate(record)
    set_appointments_to_test_against
    is_start_time_formatted?(record)
    is_end_time_formatted?(record)
    is_end_after_start?(record)
    @upcoming_appts.each do |appt|
      does_start_time_conflict?(record, appt)

      does_end_time_conflict?(record, appt)
      do_times_surround_another?(record, appt)
    end
  end

  def set_appointments_to_test_against
    now_until_future = Time.now..(Time.now + 50.years)
    @upcoming_appts = Appointment.where(start_time: now_until_future)
  end

  def is_start_time_formatted?(record)
    if record.start_time < Time.now
      record.errors[:base] << "Start time is either (a) not properly " +
      "formatted, or (b) in the past."
    end
  end

  def is_end_time_formatted?(record)
    if record.end_time < Time.now
      record.errors[:base] << "End time is either (a) not properly " +
      "formatted, or (b) in the past."
    end
  end

  def is_end_after_start?(record)
    if record.start_time >= record.end_time
      record.errors[:base] << "End time must be after start time."
    end
  end

  def does_start_time_conflict?(record, appt)
    if record.start_time >= appt.start_time && record.start_time < appt.end_time
      # invalid
      if record.id != appt.id
        record.errors[:base]  << "Start time occurs during another appointment."
      end
    end
  end

  def does_end_time_conflict?(record, appt)
    if record.end_time > appt.start_time && record.end_time <= appt.end_time
      # invalid
      if record.id != appt.id
        record.errors[:base] << "End time occurs during another appointment."
      end
    end
  end

  def do_times_surround_another?(record, appt)
    if record.start_time <= appt.start_time && record.end_time >= appt.end_time
      # invalid
      if record.id != appt.id
        record.errors[:base] << "Times overlap another appointment."
      end
    end
  end

end
