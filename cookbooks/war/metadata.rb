maintainer       "Cometera"
maintainer_email "apanasenko@griddynamics.com"
license          "All rights reserved"
description      "Installs/Configures war"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.4"

%w{ debian ubuntu centos suse fedora redhat }.each do |os|
  supports os
end

%w{ openssl mysql tomcat haproxy }.each do |cb|
  depends cb
end

attribute "war/db/database",
          :display_name => "War MySQL database",
          :description => "war will use this MySQL database to store its data.",
          :default => "jpetstore"

attribute "war/db/user",
          :display_name => "war MySQL user",
          :description => "war will connect to MySQL using this user.",
          :default => "jpetstore"

attribute "war/db/password",
          :display_name => "war MySQL password",
          :description => "Password for the war MySQL user.",
          :default => "jpetstore"
