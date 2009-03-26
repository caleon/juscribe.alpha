custom_date_formats = { 
  :concise => "%d.%b.%y", 
  :this_year => "%b %e at %l:%M%p",
  :not_this_year => "%b %e, %Y at %l:%M%p",
  :medium => "%b %e, %Y" 
} 
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(custom_date_formats)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(custom_date_formats)