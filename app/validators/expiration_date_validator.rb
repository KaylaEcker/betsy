class ExpirationDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)

    return if record.status == "pending"

    if record.cc_expiration == nil
      return record.errors[:cc_expiration] << 'expiration date can\'t be blank'
    end

    unless value =~ /\A(0[1-9]|1[0-2]|[1-9])\/(20[0-9][0-9]|[0-9][0-9])\z/
      return record.errors[:cc_expiration] << 'invalid expiration date format'
    end

    if value[3..4].to_i < DateTime.now.year.to_s[2..3].to_i || (value[3..4].to_i ==  DateTime.now.year.to_s[2..3].to_i && value[0..1].to_i <= DateTime.now.month.to_i)
      record.errors[:cc_expiration] << 'expiration date can\'t be in the past'
    end
  end
end
