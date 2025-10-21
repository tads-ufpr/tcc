json.extract! notice, :id, :apartment_id, :creator_id, :notice_type, :status, :description, :title, :type_info, :created_at, :updated_at
json.url notice_url(notice, format: :json)
