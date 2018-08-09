#!/usr/bin/perl -wT

#Programing assignment 4
#Nagaswaroop Kengunte Nagaraj

#URL: http://www.binf.gmu.edu/nkengunt/cgi-bin/nkengunt_cgi.pl


use warnings;
use strict;
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;


my $path = "/userhomes/students/nkengunt/634";  # path to program directory
my $prog = "new_cpg.pl";                        # the program we want to run
my $url = "/nkengunt/cgi-bin/nkengunt_cgi.pl";  # the URL of this script
my $dir = "/tmp/CGI-$$";                        # working directory
$ENV{PATH} = "/bin:/usr/bin";                   # makes it OK to run other programs

# Creating an HTML form with a FILE FIELD:
print header;
print start_html('A Web Interface'),
    h3("A Web Interface for $prog"),
    start_multipart_form(-target=>'_new'),  p,    #open the output in a new tab
    "Click the button to choose the input file:",
    br, filefield('filename'), p,
    reset, submit('submit','Submit File'), end_form;
# This part processes the form after the user clicks on "Submit"
if (defined param()) {
    
# get filehandle on file uploaded from internet
    my $filehandle = upload('filename');
    if (not defined $filehandle) {
        # the user did not enter a file name
        print p, strong("Please complete file field."), p,
              address( a({href=>$url}, "Try again."));
        exit;
    }

# copy uploaded file to working directory
    mkdir $dir or die "Can't create directory $dir\n";
    chdir $dir or die "Can't change to directory $dir\n";
    print hr, p, "Working directory = $dir", p;
    
    my $infile = "in";
    open FH, ">$infile" or die "Can't open $infile";
    while (<$filehandle>) {
        s/\r//g;     # convert end-of-line character to Unix
        print FH;
    }
    close $filehandle;
    close FH;

# display the input file on the web page
    print hr, p, "Input file = $infile", p;
    print_file($infile);
# run the program on the input file and save the output
    my $outfile = "out";
	
	my $fileread=$infile;

#Checking if the file exists or no, if the file is not found then print an error message
	unless(open(FILEREAD,$fileread))
	{
		print "File $fileread does not exist.\n Please enter the correct file name.\n";
	}

#Storing the contents of FILEREAD
	my @content=<FILEREAD>;
	chomp @content;
	close FILEREAD;

#Initialise the variables
	my@header=();
	my@sequence=();
	my$count=0;
	my$n=-1;

#Check for each line of the sequence if its a header or a sequence and update the number of header and sequences found.
	foreach my$line (@content)
	{
		chomp $line;
		if ($line =~ /^>/) 
		{
			$n++;         
			$header[$n] = $line; 
			$sequence[$n] = "";  
			$count=$count+1;
		}
		else {
			next if not @header; 
			$sequence[$n] .= $line;
		}
	}

#Remove all whitespaces
	for (my $i = 0; $i < $count; $i++)
	{
		$sequence[$i] =~ s/\s//g;
	}


# "$path/$prog" is the full path to the target Perl program
    my $command = "$path/$prog $infile > $outfile";
    
# run the given command
    print hr, p, "Executing: <PRE>$command</PRE>", p;
    system $command;

# display the output on the web page
    print hr, p, "Output:", p;
    print_file($outfile);
	print "Report for the file $fileread \n";

#Calling the subroutines using call by reference
	first(\@header,\@sequence,\$count);
	second(\@header,\@sequence,\$count);
	
# clean up (comment out when debugging)
    system "rm -rf $dir";

# provide a link to run the wrapper again
    print hr, p;
    print address( a({href=>$url},"Click here to run the program again."));
}
print end_html;
exit;


############################################################################################################################################
#SUBROUTINES START HERE

#Subroutine to print
sub print_file {
    my ($file) = @_;

    if (open(OUTFILE, "$file")) {
        my @output = <OUTFILE>;
        close OUTFILE;

        print "<PRE>";              # preformatted output
        foreach my $line (@output) {
            # convert any special HTML characters
	    # change "&" to "&amp;", "<" to "&lt;", ">" to "&gt;"
            $line = escapeHTML($line);
            print $line;
        }
        print '</PRE>';             # end preformatted output
    } else {
        print strong("<font color=red>Sorry,
           an error has occurred in reading the file \"$file\".</font>");
    }
}


#Subroutine to print the initial details of number of seq, total length of seq, Maximum and minimum length, avg of the sequences
sub first
{
	my ($header,$sequence,$count)=@_;
	
    print "<PRE>";              # preformatted output
	
	print "\nNumber of sequences:$$count\n";    
	
	my $combine= join('',@$sequence);   #Converting the array into a string              
	my$total=length $combine;           #Finding the length
	print "Total length of all sequences together is:$total\n";

#Finding the maximum and minimum sequence length in a gien file	
	my $big=0;
	for (my $i=0; $i<$$count;$i++)
	{
		if ($big > length @$sequence[$i])
			{
				$big=$big;
			}
		else
			{
				$big=length @$sequence[$i];
			}
	}
	print "Maximum sequence length is: $big\n";

	my $small=$big;
	for (my $i=0; $i<$$count;$i++)
	{
		if ($small < length @$sequence[$i])
			{
				$small=$small;
			}
		else
			{
				$small=length @$sequence[$i];
			}
	}
	print "Minimum sequence length is: $small\n";
	
	my $average= $total/$$count;
	print "Average length of the sequences is:$average\n";
    print "</PRE>";              # preformatted output

}


#Subroutine which gives the details about each sequence in a file
sub second	
{
    print "<PRE>";              # preformatted output

	my ($header,$sequence,$count)=@_;
	
	for (my $i = 0; $i < $$count; $i++)
	{
		print "@$header[$i]\n";							 #Printing each header followed by its details
		print "Length: ",length @$sequence[$i],"\n";     #Printing length of each sequence  
		count(@$sequence[$i]);
        print "<PRE>";              # preformatted output
	}
}


#Subroutine to count the number of A,C,G,T's in a given sequence
sub count
{
#Getting the argument values into the subroutine using '@_'
	my($dna)=@_;	
	
	my $total_length_DNA= length $dna;
#Initialising each base to zero
	my($count_A)=0;
	my($count_T)=0;
	my($count_C)=0;
	my($count_G)=0;	

#Counting the number of nucleotides respectively present in the DNA
	$count_A=($dna =~ tr/Aa//);
	my$frac_A= $count_A/$total_length_DNA;

	$count_T=($dna =~ tr/Tt//);
	my$frac_T= $count_T/$total_length_DNA;
	
	$count_G=($dna =~ tr/Gg//);
	my$frac_G= $count_G/$total_length_DNA;

	$count_C=($dna =~ tr/Cc//);
	my$frac_C= $count_C/$total_length_DNA;
	
#Printing count of the nucleotides, using printf to print the fractions upto only 2 decimal spaces
	print "A:$count_A"; printf " %0.2f",$frac_A,"\n";
	print "\nC:$count_C"; printf " %0.2f",$frac_C,"\n";
	print "\nG:$count_G"; printf " %0.2f",$frac_G,"\n";
	print "\nT:$count_T"; printf " %0.2f",$frac_T,"\n";

#Finding the CpG sequence in a string
	my$CG=0;
	while ($dna =~ /(CG)/ig)             #Matching the CG's (Case sensitive) in the string $dna
	{
		$CG++;
	}
	print "\nCpG:$CG";

#Calculating the fraction of CpG
	my $frac_CG= $CG/$total_length_DNA;
	printf " %0.2f\n",$frac_CG,"\n","\n";
}
