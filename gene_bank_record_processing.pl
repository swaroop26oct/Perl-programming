#!/usr/loal/bin/perl

# File Name: nkengunt_prog3.pl
# Name: Nagaswaroop Kengunte Nagaraj
# Date: 07 November 2016

{
	use strict;
	use warnings;

# Declaring and initializing variables
	my $fh; # variable to store filehandle
	my $record;
	my $title='';
	my $abstract='';
	my $library = 'paraneuroplastic_syndrome_result.txt';

#Calling the subroutine Open_file to check and open a file if present.
	$fh = open_file($library);

#Opening a file to write the final output to an external output file
	open(FILEWRITE,'>','counts.txt') or die "Cannot open mydna_revcomp.txt,$!";

#Performing actions by getting the data from the file
	while($record = get_next_record($fh))
	{
	
#extracting the title and abstract fields from the file read 
		($title,$abstract) = get_title_and_abstract($record);
		
		if($abstract =~ /^AB/g)         #Checking if there is an abstract field present in the data read
		{
			$abstract =~s/AB\s\s-\s//;  #Making the abstract field more readable for further actions
			print FILEWRITE "\n\n*******TITLE******\n";            #Writing the title and abstract to the output file
			print FILEWRITE "\n$title";
			print FILEWRITE "\n*******ABSTRACT*******\n";
			print FILEWRITE "\n$abstract";
    
			my @lines;
	
			@lines = split(" ",$abstract);      #Splitting the abstract obtained into single words and storing it in an arrray
		
			print FILEWRITE "\n*******LINE******\n";
			print FILEWRITE "@lines \n\n";
			count_words(@lines);        #Calling the subroutine count_words to count the number of times each word has occured in the abstract.
		}
		else                  #If we found data without an abstract field do nothing with it and just print the title field to external output file.
		{
			print FILEWRITE "\n\n*******TITLE******\n";
			print FILEWRITE "\n$title";
			print FILEWRITE "\n*******ABSTRACT*******\n";
			#print FILEWRITE "\n$abstract \n\n";		
		}
	}
	close FILEWRITE;
	exit;
}


#################################################################################
#Subroutines begin from here

#Subroutine to open a file and returning a filehandlle
sub open_file
{
	my($filename)=@_;
	my $fh;
	open($fh,$filename) or die "Cannot open $filename,$!";
	return $fh;
}

#Subroutine to get the next record in the data
sub get_next_record
{
	my($fh)=@_;
	my($offset);
	my($record)='';
	my$input_sep=$/;
	$/="";              #Reading the data and storing it in a scalar variable
	$record=<$fh>;
	$/=$input_sep;
	return $record;
}

#Subroutine to extract title and abstract
sub get_title_and_abstract
{
	my($record)=@_;
	my($title)='';
	my($abstract)='';
	
	$record=~/(^TI\s\s-\s.+\n(^\s.*\n)*)/m;     #Regular expression to obtain the title part of the data 
	$title=$1;
	
	$record=~/(^AB\s\s-\s.+\n(^\s.*\n)*)/m;  	#Regular expression to obtain the abstract part of the data
	$abstract=$1;

	return ($title,$abstract);
}

#Subroutine to count the number of words in the abstract field
sub count_words
{
	my(@lines)=@_;
	my(@a);
	my%result;
	
	foreach my$word(@lines)
	{
		my$count=0;
		if(exists $result{$word})            #If a word already exist then increase the value of the hash
		{
			$count=$result{$word};
			$count+=1;
			$result{$word}=$count;
		}
		else                 #If a word is not already present in the hash then give the key as the word and initialize the value as 1.
		{
			$result{$word}=$count+1;
		}
	}
	foreach my$key(sort keys %result)       #Printing the hash values to the output file
	{
		print FILEWRITE "$key\t";
		print FILEWRITE "$result{$key}\n";
	}
}