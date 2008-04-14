module UsersHelper
  def facebook_link(user)
    "http://www.facebook.com/profile.php?id=#{user.social_networks[:facebook]}"
  end
  
  def myspace_link(user)
    "http://www.myspace.com/" # STUBBED
  end
  
  def linkedin_link(user)
    "http://www.linkedin.com/in/#{user.social_networks[:linkedin]}"
  end
  
  def social_network_el(network, user, opts={})
    content_tag :li, link_to(image_tag('shim.gif', :class => "social_network-#{network}"), instance_eval("#{network}_link(user)"), :target => '_new', :title => "Go to #{user.display_name}'s #{network.to_s.humanize} page"), :class => opts[:class] || 'social_network' if user.send("#{network}?")
  end
  
end
