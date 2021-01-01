# Step1. parse *github* domain ip address
# Step2. generate new /etc/hosts content
# Step3. execute command to update /etc/hosts

puts "Step1. parse *github* domain ip address"
github_domains = %w(
    github.com
    gist.github.com
    api.github.com
    assets-cdn.github.com
    raw.githubusercontent.com
    gist.githubusercontent.com
    cloud.githubusercontent.com
    camo.githubusercontent.com
    avatars0.githubusercontent.com
    avatars1.githubusercontent.com
    avatars2.githubusercontent.com
    avatars3.githubusercontent.com
    avatars4.githubusercontent.com
    avatars5.githubusercontent.com
    avatars6.githubusercontent.com
    avatars7.githubusercontent.com
    avatars8.githubusercontent.com
    user-images.githubusercontent.com
    github.githubassets.com
)

domain_ips = []
github_domains.each_with_index do |domain, index|
    ipaddress = "#{domain}.ipaddress.com"
    ipaddress_html = `curl -s -L #{ipaddress}`
    puts "#{index+1}/#{github_domains.size} parse #{domain}..."
    ip_list = ipaddress_html.scan(/<ul class="comma-separated"><li>(\d+(?:\.\d+){3})<\/li><\/ul>/)
    domain_ips.push("#{ip_list.flatten[0] || '#'} #{domain}")
end

new_github_domain_config = <<-EOF
# GitHub Start
#{domain_ips.join("\n")}
# GitHub End
EOF

puts "\nStep2. generate new /etc/hosts content"
etc_hosts_content = IO.read('/etc/hosts')
old_etc_hosts_name = "etc-hosts.old.#{Time.now.strftime('%y%m%d%H%M%S')}"
File.open(old_etc_hosts_name, 'w:utf-8') { |file| file.puts(etc_hosts_content) }

old_github_domain_config = etc_hosts_content.scan(/(# GitHub Start\n(?:(?:^.*?$\n)+)# GitHub End)/).flatten[0]
etc_hosts_content.gsub!(old_github_domain_config, "")
etc_hosts_content = [etc_hosts_content, new_github_domain_config].join("\n")
etc_hosts_content.gsub!(/\n{3,}/, "\n\n")

new_etc_hosts_name = "etc-hosts.new.#{Time.now.strftime('%y%m%d%H%M%S')}"
File.open(new_etc_hosts_name, 'w:utf-8') { |file| file.puts(etc_hosts_content) }
puts "# old: #{old_etc_hosts_name}"
puts "# new: #{new_etc_hosts_name}"

puts "\nStep3. execute command to update /etc/hosts"
puts "\ncat #{new_etc_hosts_name} | sudo tee /etc/hosts\n\n"

