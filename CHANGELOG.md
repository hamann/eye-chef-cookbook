eye CHANGELOG
=============

This file is used to list changes made in each version of the eye cookbook.

0.7.1
-----
- [hamann] lazy loading attribute doesn't work as expected, replacing it by new user_srv_home option

0.7.0
-----
- [hamann] additional parameters for eye_app definition to control service on configuration changes (default: `enable`). Changes previous default behaviour of enabling, reloading and restarting

0.6.2
-----
- [hamann] lazy load attribute for user home to prevent error if user doesn't exist at compile time
- [hamann] update eye(-http) gem to 0.6.2

0.6.0
-----
- [hamann] recipe to install eye-http
- [hamann] `eye_app`: loading all configuration files ending with _config.rb

0.5.0
-----
- [hamann] - Update eye gem to 0.6.1
- [ryansch] - Cache result of method calls for block scope

0.4.0
-----
- Respect the service group when starting services
- Use exit code of `eye info` to check if process is running
- Update eye gem to 0.5.2

0.3.1
-----
- [hamann] - Update eye gem to 0.5.1

0.0.1
-----
- [hamann] - Initial release of eye
