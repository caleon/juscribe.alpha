module UsersHelper
  def aim_link(user)
    "aim:goim?screenname=#{user.social_networks[:aim]}"
  end
  
  def facebook_link(user)
    "http://www.facebook.com/profile.php?id=#{user.social_networks[:facebook]}"
  end
  
  def myspace_link(user)
    "http://www.myspace.com/#{user.social_networks[:myspace]}"
  end
  
  def linkedin_link(user)
    "http://www.linkedin.com/in/#{user.social_networks[:linkedin]}"
  end
  
  def msn_link(user)
    "msnim:chat?contact=#{user.social_networks[:msn]}"
  end
  
  def yim_link(user)
    "ymsgr:sendIM?#{user.social_networks[:yim]}"
  end
  
  def twitter_link(user)
    "http://www.twitter.com/#{user.social_networks[:twitter]}"
  end
  
  def social_network_el(network, user, opts={})
    url = h(instance_eval("#{network}_link(user)"))
    content_tag :li, link_to(image_tag('shim.gif', :class => "social_network-#{network}"), url, :target => (url.match(/http\:/) ? '_new' : nil), :title => "Go to #{user.display_name}'s #{network.to_s.humanize}"), :class => opts[:class] || 'social_network' if user.send("#{network}?")
  end
  
end
