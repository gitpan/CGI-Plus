#!/usr/bin/perl -w
use strict;

## TESTING
# BEGIN { system '/usr/bin/clear' }
# use Debug::ShowStuff ':all';
# use Debug::ShowStuff::ShowVar;
# forcetext();

use CGI::Plus;
use Test;
BEGIN { plan tests => 36 };

# general purpose variable
my ($val, $org, $new, $got, $should);


# stubs for comparison subroutines
sub err;
sub comp;
sub comp_bool;
sub is_def;


#------------------------------------------------------------------------------
# test environment variables
#
$ENV{'CONTEXT_DOCUMENT_ROOT'} = '/var/www/html';
$ENV{'CONTEXT_PREFIX'} = '';
$ENV{'DOCUMENT_ROOT'} = '/var/www/html';
$ENV{'GATEWAY_INTERFACE'} = 'CGI/1.1';
$ENV{'HTTP_ACCEPT'} = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
$ENV{'HTTP_ACCEPT_ENCODING'} = 'gzip, deflate';
$ENV{'HTTP_ACCEPT_LANGUAGE'} = 'en-us,en;q=0.5';
$ENV{'HTTP_CONNECTION'} = 'keep-alive';
$ENV{'HTTP_COOKIE'} = 'cookie_single_val=pH3FdqRbvd; cookie_multiple_vals=v&xD5wnHLJNv&j&3';
$ENV{'HTTP_HOST'} = 'www.example.com';
$ENV{'HTTP_USER_AGENT'} = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:14.0) Gecko/20100101 Firefox/14.0.1';
$ENV{'LD_LIBRARY_PATH'} = '/usr/local/apache2/lib';
$ENV{'MACHINE_NAME'} = 'Idocs';
$ENV{'PATH'} = '';
$ENV{'QUERY_STRING'} = 'x=2&y=1&y=2';
$ENV{'REMOTE_ADDR'} = '999.999.999.999';
$ENV{'REMOTE_PORT'} = '39177';
$ENV{'REQUEST_METHOD'} = 'GET';
$ENV{'REQUEST_SCHEME'} = 'http';
$ENV{'REQUEST_URI'} = '/cgi-plus/?x=2&y=1&y=2';
$ENV{'SCRIPT_FILENAME'} = '/var/www/html/miko/self_link/index.pl';
$ENV{'SCRIPT_NAME'} = '/miko/self_link/index.pl';
$ENV{'SERVER_ADDR'} = '64.124.102.16';
$ENV{'SERVER_ADMIN'} = 'miko@example.com';
$ENV{'SERVER_NAME'} = 'www.example.com';
$ENV{'SERVER_PORT'} = '80';
$ENV{'SERVER_PROTOCOL'} = 'HTTP/1.1';
$ENV{'SERVER_SIGNATURE'} = '';
$ENV{'SERVER_SOFTWARE'} = 'Apache/2.4.2 (Unix)';
$ENV{'SHOWSTUFF'} = '1';
#
# test environment variables
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# main body
#
do {

	#------------------------------------------------------------------------------
	##- get cgi object
	#
	do {
		my $cgi = CGI::Plus->new();
		is_def '$cgi', $cgi;
	};
	#
	# get cgi object
	#------------------------------------------------------------------------------


	#------------------------------------------------------------------------------
	##- params
	#
	do {
		my (@ys);
		my $cgi = CGI::Plus->new();
		
		# single param
		comp $cgi->param('x'), 2;
		
		# multiple params
		@ys = $cgi->param('y');
		comp scalar(@ys), 2;
	};
	#
	# params
	#------------------------------------------------------------------------------


	#------------------------------------------------------------------------------
	##- csrf
	#
	do {
		my ($csrf_value);
		my $cgi = CGI::Plus->new();
		
		# set csrf
		comp_bool $cgi->csrf(), 0;
		comp_bool $cgi->csrf(1), 1;
		comp_bool $cgi->csrf(), 1;
		
		# get csrf value
		$csrf_value = $cgi->oc->{'csrf'}->{'values'}->{'v'};
		is_def '$csrf_value', $csrf_value;
		
		# csrf name
		comp $cgi->csrf_name, 'csrf';
		
		# csrf form field
		comp $cgi->csrf_field, qq|<input type="hidden" name="csrf" value="$csrf_value">|;
		
		# csrf URL param
		comp $cgi->csrf_param, qq|csrf=$csrf_value|;
		
		# csrf_check: should return false
		comp_bool $cgi->csrf_check(), 0;
	};
	#
	# csrf
	#------------------------------------------------------------------------------


	#------------------------------------------------------------------------------
	##- self_link
	#
	do {
		my ($url);
		my $cgi = CGI::Plus->new();
		
		# get current url
		$url = $cgi->self_link();
		if ($url =~ m|x=2|s) {ok(1)} else {ok(0); die 'did not get param x=2'}
		if ($url =~ m|y=1|s) {ok(1)} else {ok(0); die 'did not get param y=1'}
		if ($url =~ m|y=2|s) {ok(1)} else {ok(0); die 'did not get param y=2'}
		
		# set new value for x
		$url = $cgi->self_link(params=>{x=>3});
		if ($url =~ m|x=3|s) {ok(1)} else {ok(0); die 'did not get param x=3'}
		if ($url =~ m|y=1|s) {ok(1)} else {ok(0); die 'did not get param y=1'}
		if ($url =~ m|y=2|s) {ok(1)} else {ok(0); die 'did not get param y=2'}
		
		# set new value for y
		$url = $cgi->self_link(params=>{y=>3});
		if ($url =~ m|x=2|s) {ok(1)} else {ok(0); die 'did not get param x=2'}
		if ($url =~ m|y=3|s) {ok(1)} else {ok(0); die 'did not get param y=3'}
		
		# should only have one y param
		$url =~ s|y=3||s;
		if ($url !~ m|y=|s) {ok(1)} else {ok(0); die 'should not have y param'}
		
		# set new valus for y
		$url = $cgi->self_link(params=>{y=>[5,6]});
		if ($url =~ m|x=2|s) {ok(1)} else {ok(0); die 'did not get param x=2'}
		if ($url =~ m|y=5|s) {ok(1)} else {ok(0); die 'did not get param y=5'}
		if ($url =~ m|y=6|s) {ok(1)} else {ok(0); die 'did not get param y=6'}
		
		# remove all params
		$url = $cgi->self_link(clear_params=>1);
		comp $url, '/cgi-plus/';
		
		# clear params, add new param
		$url = $cgi->self_link(clear_params=>1, params=>{j=>7});
		comp $url, '/cgi-plus/?j=7';
	};
	#
	# self_link
	#------------------------------------------------------------------------------


	#------------------------------------------------------------------------------
	##- incoming cookies
	#
	do {
		my ($ic, $cookie);
		my $cgi = CGI::Plus->new();
		
		# get incoming cookies
		$ic = $cgi->ic();
		is_def '$ic', $ic;
		
		# values
		# $ENV{'HTTP_COOKIE'} = 'cookie_single_val=pH3FdqRbvd; cookie_multiple_vals=v&xD5wnHLJNv';
		
		# single value cookie
		$cookie = $ic->{'cookie_single_val'};
		comp $cookie->{'value'}, 'pH3FdqRbvd';
		
		# multiple value cookie
		$cookie = $ic->{'cookie_multiple_vals'};
		comp $cookie->{'values'}->{'v'}, 'xD5wnHLJNv';
	};
	#
	# incoming cookies
	#------------------------------------------------------------------------------


	#------------------------------------------------------------------------------
	##- resend_cookie
	#
	do {
		my ($old_cookie, $new_cookie);
		my $cgi = CGI::Plus->new();
		
		# get original cookie
		$old_cookie = $cgi->ic->{'cookie_multiple_vals'};
		is_def '$old_cookie', $old_cookie;
		
		# get resent cookie
		$new_cookie = $cgi->resend_cookie('cookie_multiple_vals');
		is_def '$new_cookie', $new_cookie;
		
		# should not be same object
		if ("$old_cookie" eq "$new_cookie") {
			ok(0);
			die "new and old cookies should not be same objects";
		}
		
		# compare values
		comp $old_cookie->{'values'}->{'v'}, $new_cookie->{'values'}->{'v'};
	};
	#
	# resend_cookie
	#------------------------------------------------------------------------------
	
	
	#------------------------------------------------------------------------------
	##- new_send_cookie
	#
	do {
		my ($cookie, %headers);
		my $cgi = CGI::Plus->new();
		
		# new cookie with multiple values
		$cookie = $cgi->new_send_cookie('new_cookie');
		is_def '$cookie', $cookie;
		is_def "\$cookie->{'values'}", $cookie->{'values'};
		$cookie->{'values'}->{'x'} = 100;
		
		# get headers
		%headers = headers($cgi);
		
		# cookies should include new_cookie
		FIND_COOKIE: {
			foreach my $cookie (@{$headers{'Set-Cookie'}}) {
				if ($cookie =~ m|^new_cookie=x&100;|s) {
					ok(1);
					last FIND_COOKIE;
				}
				
				ok(0);
				die 'did not get new_cookie';
			}
		}
	};
	#
	# new_send_cookie
	#------------------------------------------------------------------------------
	
	
	#------------------------------------------------------------------------------
	##- set_header
	#
	do { ##i
		my (%headers);
		my $cgi = CGI::Plus->new();
		
		# set new header
		$cgi->set_header('myheader', 'whatever');
		
		# get headers
		%headers = headers($cgi);
		
		# chould have new header
		comp $headers{'Myheader'}->[0], 'whatever';
	};
	#
	# set_header
	#------------------------------------------------------------------------------


	#------------------------------------------------------------------------------
	##- set_content_type
	#
	do {
		my (%headers);
		my $cgi = CGI::Plus->new();
		
		# set new header
		$cgi->set_content_type('text/whatever');
		# println $cgi->header_plus;
		
		# get headers
		%headers = headers($cgi);
		
		# should have new header
		comp $headers{'Content-Type'}->[0], 'text/whatever; charset=ISO-8859-1';
	};
	#
	# set_content_type
	#------------------------------------------------------------------------------
	
};
#
# main body
#------------------------------------------------------------------------------



###############################################################################
# end of tests
###############################################################################



#------------------------------------------------------------------------------
# err
#
sub err {
	my ($function_name, $err) = @_;
	
	print STDERR $function_name, ': ', $err, "\n";
	ok(0);
	exit;
}
#
# err
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# comp
#
sub comp {
	my ($is, $shouldbe) = @_;
	
	if(! equndef($is, $shouldbe)) {
		print STDERR 
			"\n",
			"\tis:         ", (defined($is) ?       $is       : '[undef]'), "\n",
			"\tshould be : ", (defined($shouldbe) ? $shouldbe : '[undef]'), "\n\n";	
		ok(0);
		exit;
	}
	
	# else ok
	ok(1);
}
#
# comp
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# comp_bool
#
sub comp_bool {
	my ($is, $shouldbe) = @_;
	
	if( $is && $shouldbe ) {
		ok(1);
		return 1;
	}
	
	if( (! $is) && (! $shouldbe) ) {
		ok(1);
		return 1;
	}
	
	# else not ok
	print STDERR
		"different boolean values:\n",
		"is:     ",     ($is       ? 'true' : 'false'), "\n",
		"should: ", ($shouldbe ? 'true' : 'false'), "\n";
	ok(0);
	exit;
}
#
# comp_bool
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# equndef
#
sub equndef {
	my ($str1, $str2) = @_;
	
	# if both defined
	if ( defined($str1) && defined($str2) )
		{return $str1 eq $str2}
	
	# if neither are defined 
	if ( (! defined($str1)) && (! defined($str2)) )
		{return 1}
	
	# only one is defined, so return false
	return 0;
}
#
# equndef
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# is_def
#
sub is_def {
	my ($name, $var) = @_;
	
	# if not defined, throw error
	if (! defined $var) {
		ok(0);
		die qq|$name not defined|;
	}
	
	# else ok
	ok(1);
}
#
# is_def
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# headers
#
sub headers {
	my ($cgi) = @_;
	my (%rv, $raw, @lines);
	
	# get raw headers
	$raw = $cgi->header_plus();
	
	# remove trailing space
	$raw =~ s|\s+$||s;
	
	# get lines
	@lines = split(m|[\n\r]|, $raw);
	@lines = grep {m|\S|s} @lines;
	
	# loop through lines
	LINE_LOOP:
	foreach my $line (@lines) {
		my ($n, $v);
		
		# parse into name and value
		($n, $v) = split(m|\s*:\s*|, $line, 2);
		
		# ensure existence of header element
		$rv{$n} ||= [];
		
		# add value
		push @{$rv{$n}}, $v;
	}
	
	# return
	return %rv;
}
#
# headers
#------------------------------------------------------------------------------
