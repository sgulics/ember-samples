class Todo < ActiveRecord::Base
  attr_accessible :done, :title

  def self.filter(hash)
    if hash.blank? or hash.empty?
      scoped
    else
      sql = hash.map do | column, value|
        if columns_hash[column.to_s].type == :integer
          if (column == "id" and value.to_i > 0) or (column != "id")
            sanitize_sql ["#{column} = ?", value.to_i]
          end
        elsif value.present?
          sanitize_sql ["#{column} LIKE ?", "%#{value}%"]
        end
      end.compact.join(" or ")
      where(sql)
    end
  end
end
