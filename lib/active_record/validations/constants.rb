# NOTE: Needs to have backslashes escaped.
REGEXP_STR = { # Defaults
               :id             => "\\d+",
               :permalink      => "[a-zA-Z0-9][-a-zA-Z0-9]+[a-zA-Z0-9]",
               :title          => "[^\\s].+[^\\s]",
               :name           => "[^\\s].+[^\\s]",
               :content        => "[^\\s].+[^\\s]",
               :body           => "[^\\s].+[^\\s]",
               # Main
               :main       => { :topic => "([-_a-zA-Z0-9]+)?" },
               # Model specific:
               :article    => { :permalink => "[a-zA-Z0-9][-a-zA-Z0-9]+[a-zA-Z0-9]" },
               :blog       => { :short_name => "([^\\s].+[^\\s])",
                                :permalink => "[A-Z0-9][-A-Z0-9]+[A-Z0-9]" },
               :gallery    => { :name => "([^\\s].+[^\\s])?" },
               :group      => { :permalink => "[a-zA-Z0-9][-a-zA-Z0-9]+[a-zA-Z0-9]" },
               :message    => { :subject => "[^\\s].+[^\\s]" },
               :permission_rule => { :name => "([^\\s].+[^\\s])?" },
               :picture    => { :name => "([^\\s].+[^\\s])?",
                                :caption => "([^\\s].+[^\\s])?"},
               :project    => {},
               :song       => { :artist => "[^\\s].+[^\\s]" },
               :tag        => {},
               :thoughtlet => { :location => "([^\\s].+[^\\s])?",
                                :content => "([^\\s].+[^\\s])?" },
               :user       => { :nick => "[a-zA-Z][_a-zA-Z0-9]+",
                                :first_name => "[a-zA-Z][-a-zA-Z'\\s]*[a-zA-Z]",
                                :middle_initial => "[a-zA-Z]?",
                                :last_name => "[a-zA-Z][-a-zA-Z'\\s]*[a-zA-Z]",
                                :email => "([^@\\s]+)@((?:[-a-zA-Z0-9]+\\.)+[a-zA-Z]{2,})" }
              }            

REGEX = Hash[*REGEXP_STR.to_a.map do |arr|
  [ arr[0], 
    if arr[1].is_a?(Hash)
      Hash[*arr[1].to_a.map{|arrr| [ arrr[0], /#{arrr[1]}/ ]}.flatten]
    else
      /#{arr[1]}/
    end ]
end.flatten]

REGEXP = Hash[*REGEXP_STR.to_a.map do |arr|
  [ arr[0],
    if arr[1].is_a?(Hash)
      Hash[*arr[1].to_a.map{|arrr| [ arrr[0], /^#{arrr[1]}$/ ]}.flatten]
    else
      /^#{arr[1]}$/
    end ]
end.flatten]
