user "random" do
  supports :manage_home => true
  comment "Random User"
  uid 1234
  gid "users"
  home "/home/random"
  shell "/bin/bash"
  password "$1$JJsvHslV$szsCjVEroftprNn4JHtDi."
end

eye_app "sleep_random" do
  start_command "/bin/sleep 10000"
  stop_signals "[:term, 10.seconds, :kill]"
  stop_grace "20.seconds"
  reload true
  pid_file "/var/tmp/sleep_random.pid"
  user_srv true
  user_srv_uid "random"
  user_srv_gid "users"
  home_dir '/home/random'
  daemonize true
end
