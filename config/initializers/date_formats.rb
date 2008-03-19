custom_date_formats = { 
  :concise => "%d.%b.%y", 
  :medium => "%b %e, %Y" 
} 
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(custom_date_formats)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(custom_date_formats)